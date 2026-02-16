package handlers

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	"backend/models"
)

// SearchUsers - поиск пользователей по имени, фамилии или university_id
func SearchUsers(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		query := r.URL.Query().Get("q")
		if query == "" {
			http.Error(w, "Search query is required", http.StatusBadRequest)
			return
		}

	searchPattern := "%" + strings.ToLower(strings.TrimSpace(query)) + "%"

	rows, err := db.Query(`
		SELECT id, university_id, first_name, last_name, middle_name, user_type,
		       latitude, longitude, last_location_update, created_at, updated_at
		FROM users 
		WHERE user_type IN ('student', 'driver')
		AND (
			LOWER(TRIM(university_id)) LIKE $1 
			OR LOWER(TRIM(first_name)) LIKE $1 
			OR LOWER(TRIM(last_name)) LIKE $1
			OR LOWER(TRIM(middle_name)) LIKE $1
		)
		ORDER BY user_type, last_name, first_name, id
	`, searchPattern)

	if err != nil {
		log.Printf("Search error: %v", err)
		http.Error(w, "Database error", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		if err := rows.Scan(&user.ID, &user.UniversityID, &user.FirstName, &user.LastName,
			&user.MiddleName, &user.UserType, &user.Latitude, &user.Longitude,
			&user.LastLocationUpdate, &user.CreatedAt, &user.UpdatedAt); err != nil {
			continue
		}
		users = append(users, user)
	}

	// Если ничего не найдено, возвращаем пустой массив вместо null
	if users == nil {
		users = []models.User{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(users)
}
}

// DeleteUser - удаление одного пользователя
func DeleteUser(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			UserID int `json:"user_id"`
		}

		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request", http.StatusBadRequest)
			return
		}

		// Проверяем что это не admin
		var userType string
		err := db.QueryRow("SELECT user_type FROM users WHERE id = $1", req.UserID).Scan(&userType)
		if err == sql.ErrNoRows {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}
		if err != nil {
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}

		if userType == "admin" {
			http.Error(w, "Cannot delete admin user", http.StatusForbidden)
			return
		}

		// Удаляем пользователя
		result, err := db.Exec("DELETE FROM users WHERE id = $1", req.UserID)
		if err != nil {
			log.Printf("Error deleting user %d: %v", req.UserID, err)
			http.Error(w, "Error deleting user", http.StatusInternalServerError)
			return
		}

		rowsAffected, _ := result.RowsAffected()
		if rowsAffected == 0 {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		log.Printf("User %d deleted successfully", req.UserID)

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"message": "User deleted successfully",
		})
	}
}

// DeleteAllUsers - удаление всех студентов и водителей (админы сохраняются)
func DeleteAllUsers(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Confirmation string `json:"confirmation"`
		}

		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request", http.StatusBadRequest)
			return
		}

		// Проверяем текст подтверждения
		if req.Confirmation != "DELETE ALL USERS" {
			http.Error(w, "Invalid confirmation text", http.StatusBadRequest)
			return
		}

		// Удаляем всех студентов и водителей (админы остаются)
		result, err := db.Exec("DELETE FROM users WHERE user_type IN ('student', 'driver')")
		if err != nil {
			log.Printf("Error deleting all users: %v", err)
			http.Error(w, "Error deleting users", http.StatusInternalServerError)
			return
		}

		rowsAffected, _ := result.RowsAffected()

		log.Printf("Deleted %d users (students and drivers)", rowsAffected)

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"message": fmt.Sprintf("Deleted %d users", rowsAffected),
			"deleted": rowsAffected,
		})
	}
}
