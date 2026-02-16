package handlers

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"backend/models"

	"golang.org/x/crypto/bcrypt"
)

func CreateStudent(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req models.CreateUserRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request", http.StatusBadRequest)
			return
		}

		// Для студентов пароль не нужен - используем заглушку
		password := "no-password-needed"

		req.UserType = "student"
		req.Password = password

		// Создаем пользователя и получаем его ID
		user, err := createUserWithResponse(db, req)
		if err != nil {
			log.Printf("Error creating student: %v", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// Возвращаем данные БЕЗ пароля (он не нужен для студентов)
		response := models.UserCreatedResponse{
			ID:           user.ID,
			UniversityID: user.UniversityID,
			Password:     "", // Пароль не нужен - вход только по ID
			FirstName:    user.FirstName,
			LastName:     user.LastName,
			MiddleName:   user.MiddleName,
			UserType:     user.UserType,
			CreatedAt:    user.CreatedAt,
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(response)
	}
}

func CreateDriver(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req models.CreateUserRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request", http.StatusBadRequest)
			return
		}

		// Для водителей пароль не нужен - используем заглушку
		password := "no-password-needed"

		req.UserType = "driver"
		req.Password = password

		// Создаем пользователя и получаем его ID
		user, err := createUserWithResponse(db, req)
		if err != nil {
			log.Printf("Error creating driver: %v", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// Возвращаем данные БЕЗ пароля (он не нужен для водителей)
		response := models.UserCreatedResponse{
			ID:           user.ID,
			UniversityID: user.UniversityID,
			Password:     "", // Пароль не нужен - вход только по ID
			FirstName:    user.FirstName,
			LastName:     user.LastName,
			MiddleName:   user.MiddleName,
			UserType:     user.UserType,
			CreatedAt:    user.CreatedAt,
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(response)
	}
}

func GetAllStudents(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		rows, err := db.Query(`
			SELECT id, university_id, first_name, last_name, middle_name, created_at, updated_at
			FROM users WHERE user_type = 'student'
			ORDER BY id
		`)
		if err != nil {
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		var students []models.User
		for rows.Next() {
			var user models.User
			if err := rows.Scan(&user.ID, &user.UniversityID, &user.FirstName, &user.LastName,
				&user.MiddleName, &user.CreatedAt, &user.UpdatedAt); err != nil {
				continue
			}
			user.UserType = "student"
			students = append(students, user)
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(students)
	}
}

func GetAllDrivers(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		rows, err := db.Query(`
			SELECT id, university_id, first_name, last_name, middle_name, 
			       latitude, longitude, last_location_update, created_at, updated_at
			FROM users WHERE user_type = 'driver'
			ORDER BY id
		`)
		if err != nil {
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		var drivers []models.User
		for rows.Next() {
			var user models.User
			if err := rows.Scan(&user.ID, &user.UniversityID, &user.FirstName, &user.LastName,
				&user.MiddleName, &user.Latitude, &user.Longitude, &user.LastLocationUpdate,
				&user.CreatedAt, &user.UpdatedAt); err != nil {
				continue
			}
			user.UserType = "driver"
			drivers = append(drivers, user)
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(drivers)
	}
}

func createUser(db *sql.DB, req models.CreateUserRequest) error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	_, err = db.Exec(`
		INSERT INTO users (university_id, password_hash, first_name, last_name, middle_name, user_type)
		VALUES ($1, $2, $3, $4, $5, $6)
	`, req.UniversityID, hashedPassword, req.FirstName, req.LastName, req.MiddleName, req.UserType)

	return err
}

func createUserWithResponse(db *sql.DB, req models.CreateUserRequest) (*models.User, error) {
	// Обрезаем пробелы из всех полей
	req.UniversityID = strings.TrimSpace(req.UniversityID)
	req.FirstName = strings.TrimSpace(req.FirstName)
	req.LastName = strings.TrimSpace(req.LastName)
	if req.MiddleName != nil {
		trimmed := strings.TrimSpace(*req.MiddleName)
		if trimmed == "" {
			req.MiddleName = nil
		} else {
			req.MiddleName = &trimmed
		}
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	var id int
	var createdAt time.Time

	err = db.QueryRow(`
		INSERT INTO users (university_id, password_hash, first_name, last_name, middle_name, user_type, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, NOW())
		RETURNING id, created_at
	`, req.UniversityID, hashedPassword, req.FirstName, req.LastName, req.MiddleName, req.UserType).
		Scan(&id, &createdAt)

	if err != nil {
		return nil, err
	}

	return &models.User{
		ID:           id,
		UniversityID: req.UniversityID,
		FirstName:    req.FirstName,
		LastName:     req.LastName,
		MiddleName:   req.MiddleName,
		UserType:     req.UserType,
		CreatedAt:    createdAt,
		UpdatedAt:    createdAt,
	}, nil
}

func ImportStudents(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Users []models.CreateUserRequest `json:"users"`
		}

		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request", http.StatusBadRequest)
			return
		}

		log.Printf("Starting student import: %d users", len(req.Users))

		// Начинаем транзакцию для быстрой вставки
		tx, err := db.Begin()
		if err != nil {
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}
		defer tx.Rollback()

		// Подготавливаем statement для batch insert
		stmt, err := tx.Prepare(`
			INSERT INTO users (university_id, password_hash, first_name, last_name, middle_name, user_type, created_at)
			VALUES ($1, $2, $3, $4, $5, $6, NOW())
		`)
		if err != nil {
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}
		defer stmt.Close()

		// Подготавливаем хэш пароля один раз для всех студентов
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte("no-password-needed"), bcrypt.DefaultCost)
		if err != nil {
			http.Error(w, "Password hashing error", http.StatusInternalServerError)
			return
		}

		successCount := 0
		errorCount := 0
		errors := []string{}

		for i, userReq := range req.Users {
			// Обрезаем пробелы из всех полей
			userReq.UniversityID = strings.TrimSpace(userReq.UniversityID)
			userReq.FirstName = strings.TrimSpace(userReq.FirstName)
			userReq.LastName = strings.TrimSpace(userReq.LastName)
			if userReq.MiddleName != nil {
				trimmed := strings.TrimSpace(*userReq.MiddleName)
				if trimmed == "" {
					userReq.MiddleName = nil
				} else {
					userReq.MiddleName = &trimmed
				}
			}

			// Validate required fields AFTER trimming
			if userReq.UniversityID == "" {
				errorCount++
				errors = append(errors, fmt.Sprintf("Строка %d: отсутствует университетский ID", i+1))
				continue
			}
			if userReq.FirstName == "" {
				errorCount++
				errors = append(errors, fmt.Sprintf("ID %s: отсутствует имя", userReq.UniversityID))
				continue
			}
			if userReq.LastName == "" {
				errorCount++
				errors = append(errors, fmt.Sprintf("ID %s: отсутствует фамилия", userReq.UniversityID))
				continue
			}

			// Выполняем вставку
			_, err := stmt.Exec(userReq.UniversityID, hashedPassword, userReq.FirstName, userReq.LastName, userReq.MiddleName, "student")
			if err != nil {
				errorCount++
				if strings.Contains(err.Error(), "duplicate key") {
					errors = append(errors, fmt.Sprintf("ID %s: уже существует в базе", userReq.UniversityID))
				} else {
					errors = append(errors, fmt.Sprintf("ID %s: %s", userReq.UniversityID, err.Error()))
				}
			} else {
				successCount++
			}

			// Логируем прогресс каждые 1000 записей
			if (i+1)%1000 == 0 {
				log.Printf("Imported %d/%d students", i+1, len(req.Users))
			}
		}

		// Коммитим транзакцию
		if err := tx.Commit(); err != nil {
			http.Error(w, "Failed to commit transaction", http.StatusInternalServerError)
			return
		}

		log.Printf("Student import completed: %d success, %d failed", successCount, errorCount)

		response := map[string]interface{}{
			"success": successCount,
			"failed":  errorCount,
			"errors":  errors,
			"total":   len(req.Users),
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

func ImportDrivers(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Users []models.CreateUserRequest `json:"users"`
		}

		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			log.Printf("Error decoding import request: %v", err)
			http.Error(w, fmt.Sprintf("Invalid request format: %v", err), http.StatusBadRequest)
			return
		}

		log.Printf("Starting driver import: %d users", len(req.Users))

		if len(req.Users) == 0 {
			http.Error(w, "No users provided", http.StatusBadRequest)
			return
		}

		// Начинаем транзакцию для быстрой вставки
		tx, err := db.Begin()
		if err != nil {
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}
		defer tx.Rollback()

		// Подготавливаем statement для batch insert
		stmt, err := tx.Prepare(`
			INSERT INTO users (university_id, password_hash, first_name, last_name, middle_name, user_type, created_at)
			VALUES ($1, $2, $3, $4, $5, $6, NOW())
		`)
		if err != nil {
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}
		defer stmt.Close()

		// Подготавливаем хэш пароля один раз для всех водителей
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte("no-password-needed"), bcrypt.DefaultCost)
		if err != nil {
			http.Error(w, "Password hashing error", http.StatusInternalServerError)
			return
		}

		successCount := 0
		errorCount := 0
		errors := []string{}

		for i, userReq := range req.Users {
			// Обрезаем пробелы из всех полей
			userReq.UniversityID = strings.TrimSpace(userReq.UniversityID)
			userReq.FirstName = strings.TrimSpace(userReq.FirstName)
			userReq.LastName = strings.TrimSpace(userReq.LastName)
			if userReq.MiddleName != nil {
				trimmed := strings.TrimSpace(*userReq.MiddleName)
				if trimmed == "" {
					userReq.MiddleName = nil
				} else {
					userReq.MiddleName = &trimmed
				}
			}

			// Validate required fields AFTER trimming
			if userReq.UniversityID == "" {
				errorCount++
				errors = append(errors, fmt.Sprintf("Строка %d: отсутствует университетский ID", i+1))
				continue
			}
			if userReq.FirstName == "" {
				errorCount++
				errors = append(errors, fmt.Sprintf("ID %s: отсутствует имя", userReq.UniversityID))
				continue
			}
			if userReq.LastName == "" {
				errorCount++
				errors = append(errors, fmt.Sprintf("ID %s: отсутствует фамилия", userReq.UniversityID))
				continue
			}

			// Выполняем вставку
			_, err := stmt.Exec(userReq.UniversityID, hashedPassword, userReq.FirstName, userReq.LastName, userReq.MiddleName, "driver")
			if err != nil {
				errorCount++
				if strings.Contains(err.Error(), "duplicate key") {
					errors = append(errors, fmt.Sprintf("ID %s: уже существует в базе", userReq.UniversityID))
				} else {
					errors = append(errors, fmt.Sprintf("ID %s: %s", userReq.UniversityID, err.Error()))
				}
			} else {
				successCount++
			}

			// Логируем прогресс каждые 1000 записей
			if (i+1)%1000 == 0 {
				log.Printf("Imported %d/%d drivers", i+1, len(req.Users))
			}
		}

		// Коммитим транзакцию
		if err := tx.Commit(); err != nil {
			http.Error(w, "Failed to commit transaction", http.StatusInternalServerError)
			return
		}

		log.Printf("Driver import completed: %d success, %d failed", successCount, errorCount)

		response := map[string]interface{}{
			"success": successCount,
			"failed":  errorCount,
			"errors":  errors,
			"total":   len(req.Users),
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}
