package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"time"

	"backend/models"
	"backend/websocket"
)

func GetProfile(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// In production, extract user ID from JWT token
		userID := r.URL.Query().Get("user_id")

		var user models.User
		err := db.QueryRow(`
			SELECT id, university_id, first_name, last_name, middle_name, user_type,
			       latitude, longitude, last_location_update, created_at, updated_at
			FROM users WHERE id = $1
		`, userID).Scan(
			&user.ID, &user.UniversityID, &user.FirstName, &user.LastName,
			&user.MiddleName, &user.UserType, &user.Latitude, &user.Longitude,
			&user.LastLocationUpdate, &user.CreatedAt, &user.UpdatedAt,
		)

		if err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(user)
	}
}

func UpdateLocation(db *sql.DB, hub *websocket.Hub) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// In production, extract user info from JWT token
		userID := r.URL.Query().Get("user_id")

		var location models.LocationUpdate
		if err := json.NewDecoder(r.Body).Decode(&location); err != nil {
			http.Error(w, "Invalid request", http.StatusBadRequest)
			return
		}

		// Update location in database
		_, err := db.Exec(`
			UPDATE users 
			SET latitude = $1, longitude = $2, last_location_update = $3, updated_at = $3
			WHERE id = $4
		`, location.Latitude, location.Longitude, time.Now(), userID)

		if err != nil {
			http.Error(w, "Failed to update location", http.StatusInternalServerError)
			return
		}

		// Get user info for broadcast
		var user models.User
		db.QueryRow(`
			SELECT id, university_id, first_name, last_name, user_type
			FROM users WHERE id = $1
		`, userID).Scan(&user.ID, &user.UniversityID, &user.FirstName, &user.LastName, &user.UserType)

		// Broadcast location update via WebSocket
		broadcast := models.LocationBroadcast{
			UserID:       user.ID,
			UniversityID: user.UniversityID,
			FirstName:    user.FirstName,
			LastName:     user.LastName,
			UserType:     user.UserType,
			Latitude:     location.Latitude,
			Longitude:    location.Longitude,
			Timestamp:    time.Now().Unix(),
		}

		hub.Broadcast <- broadcast

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "Location updated successfully"})
	}
}

func GetDriversLocations(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		rows, err := db.Query(`
			SELECT id, university_id, first_name, last_name, latitude, longitude, last_location_update
			FROM users 
			WHERE user_type = 'driver' AND latitude IS NOT NULL AND longitude IS NOT NULL
		`)
		if err != nil {
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		locations := []models.LocationBroadcast{}
		for rows.Next() {
			var loc models.LocationBroadcast
			var lastUpdate time.Time
			if err := rows.Scan(&loc.UserID, &loc.UniversityID, &loc.FirstName, &loc.LastName,
				&loc.Latitude, &loc.Longitude, &lastUpdate); err != nil {
				continue
			}
			loc.UserType = "driver"
			loc.Timestamp = lastUpdate.Unix()
			locations = append(locations, loc)
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(locations)
	}
}
