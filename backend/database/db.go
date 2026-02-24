package database

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/lib/pq"
)

func InitDB() (*sql.DB, error) {
	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbname := os.Getenv("DB_NAME")

	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, err
	}

	if err = db.Ping(); err != nil {
		return nil, err
	}

	return db, nil
}

func RunMigrations(db *sql.DB) error {
	queries := []string{
		`CREATE TABLE IF NOT EXISTS users (
			id SERIAL PRIMARY KEY,
			university_id VARCHAR(100) UNIQUE NOT NULL,
			password_hash VARCHAR(255) NOT NULL,
			first_name VARCHAR(100) NOT NULL,
			last_name VARCHAR(100) NOT NULL,
			middle_name VARCHAR(100),
			user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('student', 'driver', 'admin')),
			latitude DOUBLE PRECISION,
			longitude DOUBLE PRECISION,
			heading DOUBLE PRECISION,
			last_location_update TIMESTAMP,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,
		`CREATE INDEX IF NOT EXISTS idx_users_university_id ON users(university_id)`,
		`CREATE INDEX IF NOT EXISTS idx_users_type ON users(user_type)`,
		`CREATE INDEX IF NOT EXISTS idx_users_location ON users(latitude, longitude) WHERE user_type = 'driver'`,
		`ALTER TABLE users ADD COLUMN IF NOT EXISTS heading DOUBLE PRECISION`,
		`CREATE INDEX IF NOT EXISTS idx_users_heading ON users(heading) WHERE user_type = 'driver'`,
		`COMMENT ON COLUMN users.heading IS 'Direction in degrees (0-360): 0=North, 90=East, 180=South, 270=West'`,
	}

	for _, query := range queries {
		if _, err := db.Exec(query); err != nil {
			return err
		}
	}

	return nil
}
