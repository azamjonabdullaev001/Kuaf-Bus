package handlers

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"backend/models"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type Claims struct {
	UserID       int    `json:"user_id"`
	UniversityID string `json:"university_id"`
	UserType     string `json:"user_type"`
	jwt.RegisteredClaims
}

func Login(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req models.LoginRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request", http.StatusBadRequest)
			return
		}

		log.Printf("Login attempt for user: %s", req.UniversityID)

		var user models.User
		err := db.QueryRow(`
			SELECT id, university_id, password_hash, first_name, last_name, middle_name, user_type, 
			       latitude, longitude, last_location_update, created_at, updated_at
			FROM users WHERE university_id = $1
		`, req.UniversityID).Scan(
			&user.ID, &user.UniversityID, &user.PasswordHash, &user.FirstName, &user.LastName,
			&user.MiddleName, &user.UserType, &user.Latitude, &user.Longitude,
			&user.LastLocationUpdate, &user.CreatedAt, &user.UpdatedAt,
		)

		if err == sql.ErrNoRows {
			log.Printf("User not found: %s", req.UniversityID)
			http.Error(w, "Invalid credentials", http.StatusUnauthorized)
			return
		} else if err != nil {
			log.Printf("Database error: %v", err)
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}

	log.Printf("User found: %s, type: %s", user.UniversityID, user.UserType)

	// Проверка пароля ТОЛЬКО для админа
	if user.UserType == "admin" {
		if req.Password == "" {
			log.Printf("Password required for admin")
			http.Error(w, "Password required for admin", http.StatusUnauthorized)
			return
		}

		if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
			log.Printf("Invalid admin password")
			http.Error(w, "Invalid credentials", http.StatusUnauthorized)
			return
		}
	}

	log.Printf("Login successful for user: %s", req.UniversityID)

	// Generate JWT token
	expirationTime := time.Now().Add(24 * time.Hour)
	claims := &Claims{
		UserID:       user.ID,
		UniversityID: user.UniversityID,
		UserType:     user.UserType,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(os.Getenv("JWT_SECRET")))
	if err != nil {
		http.Error(w, "Error generating token", http.StatusInternalServerError)
		return
	}

	response := models.LoginResponse{
		Token:    tokenString,
		UserType: user.UserType,
		User:     user,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
	}
}
