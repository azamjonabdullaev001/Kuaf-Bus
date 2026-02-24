package handlers

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
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
			       latitude, longitude, heading, last_location_update, created_at, updated_at
			FROM users WHERE id = $1
		`, userID).Scan(
			&user.ID, &user.UniversityID, &user.FirstName, &user.LastName,
			&user.MiddleName, &user.UserType, &user.Latitude, &user.Longitude,
			&user.Heading, &user.LastLocationUpdate, &user.CreatedAt, &user.UpdatedAt,
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
			log.Printf("[UpdateLocation] Error decoding request: %v", err)
			http.Error(w, "Invalid request", http.StatusBadRequest)
			return
		}

		headingStr := "null"
		if location.Heading != nil {
			headingStr = fmt.Sprintf("%.1f°", *location.Heading)
		}
		log.Printf("[UpdateLocation] Received from user %s: lat=%.6f, lon=%.6f, heading=%s",
			userID, location.Latitude, location.Longitude, headingStr)

		// Update location in database with heading
		_, err := db.Exec(`
			UPDATE users 
			SET latitude = $1, longitude = $2, heading = $3, last_location_update = $4, updated_at = $4
			WHERE id = $5
		`, location.Latitude, location.Longitude, location.Heading, time.Now(), userID)

		if err != nil {
			log.Printf("[UpdateLocation] Database error: %v", err)
			http.Error(w, "Failed to update location", http.StatusInternalServerError)
			return
		}

		// Get user info for broadcast
		var user models.User
		err = db.QueryRow(`
			SELECT id, university_id, first_name, last_name, user_type
			FROM users WHERE id = $1
		`, userID).Scan(&user.ID, &user.UniversityID, &user.FirstName, &user.LastName, &user.UserType)
		
		if err != nil {
			log.Printf("[UpdateLocation] Error getting user info: %v", err)
		}

		// Broadcast location update via WebSocket with heading
		broadcast := models.LocationBroadcast{
			UserID:       user.ID,
			UniversityID: user.UniversityID,
			FirstName:    user.FirstName,
			LastName:     user.LastName,
			UserType:     user.UserType,
			Latitude:     location.Latitude,
			Longitude:    location.Longitude,
			Heading:      location.Heading,
			Timestamp:    time.Now().Unix(),
		}

		broadcastHeadingStr := "null"
		if broadcast.Heading != nil {
			broadcastHeadingStr = fmt.Sprintf("%.1f°", *broadcast.Heading)
		}
		log.Printf("[UpdateLocation] Broadcasting: user_id=%d, user_type=%s, lat=%.6f, lon=%.6f, heading=%s",
			broadcast.UserID, broadcast.UserType, broadcast.Latitude, broadcast.Longitude, broadcastHeadingStr)

		hub.Broadcast <- broadcast

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "Location updated successfully"})
	}
}

func GetDriversLocations(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		rows, err := db.Query(`
			SELECT id, university_id, first_name, last_name, latitude, longitude, heading, last_location_update
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
				&loc.Latitude, &loc.Longitude, &loc.Heading, &lastUpdate); err != nil {
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
