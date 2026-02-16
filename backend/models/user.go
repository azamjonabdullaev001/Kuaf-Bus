package models

import "time"

type User struct {
	ID                 int        `json:"id"`
	UniversityID       string     `json:"university_id"`
	PasswordHash       string     `json:"-"`
	FirstName          string     `json:"first_name"`
	LastName           string     `json:"last_name"`
	MiddleName         *string    `json:"middle_name,omitempty"`
	UserType           string     `json:"user_type"` // student, driver, admin
	Latitude           *float64   `json:"latitude,omitempty"`
	Longitude          *float64   `json:"longitude,omitempty"`
	LastLocationUpdate *time.Time `json:"last_location_update,omitempty"`
	CreatedAt          time.Time  `json:"created_at"`
	UpdatedAt          time.Time  `json:"updated_at"`
}

type LoginRequest struct {
	UniversityID string `json:"university_id"`
	Password     string `json:"password,omitempty"` // Опциональный - только для админа
}

type LoginResponse struct {
	Token    string `json:"token"`
	UserType string `json:"user_type"`
	User     User   `json:"user"`
}

type CreateUserRequest struct {
	UniversityID string  `json:"university_id"`
	Password     string  `json:"password"`
	FirstName    string  `json:"first_name"`
	LastName     string  `json:"last_name"`
	MiddleName   *string `json:"middle_name,omitempty"`
	UserType     string  `json:"user_type"`
}

type UserCreatedResponse struct {
	ID           int     `json:"id"`
	UniversityID string  `json:"university_id"`
	Password     string  `json:"password"` // Сгенерированный пароль для выдачи пользователю
	FirstName    string  `json:"first_name"`
	LastName     string  `json:"last_name"`
	MiddleName   *string `json:"middle_name,omitempty"`
	UserType     string  `json:"user_type"`
	CreatedAt    time.Time `json:"created_at"`
}

type LocationUpdate struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type LocationBroadcast struct {
	UserID       int     `json:"user_id"`
	UniversityID string  `json:"university_id"`
	FirstName    string  `json:"first_name"`
	LastName     string  `json:"last_name"`
	UserType     string  `json:"user_type"`
	Latitude     float64 `json:"latitude"`
	Longitude    float64 `json:"longitude"`
	Timestamp    int64   `json:"timestamp"`
}
