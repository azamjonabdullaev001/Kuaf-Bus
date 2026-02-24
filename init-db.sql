-- Create users table
CREATE TABLE IF NOT EXISTS users (
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
);

CREATE INDEX IF NOT EXISTS idx_users_university_id ON users(university_id);
CREATE INDEX IF NOT EXISTS idx_users_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_users_location ON users(latitude, longitude) WHERE user_type = 'driver';
CREATE INDEX IF NOT EXISTS idx_users_heading ON users(heading) WHERE user_type = 'driver';

COMMENT ON COLUMN users.heading IS 'Direction in degrees (0-360): 0=North, 90=East, 180=South, 270=West';

-- This script creates an initial admin user
-- ID: 65837499i9
-- Password: K7mP9nQ2rS5tV8xW1yZ4aB6cD3eF

INSERT INTO users (university_id, password_hash, first_name, last_name, user_type)
VALUES (
    '65837499i9',
    '$2b$10$.qR4c2dm5mldT3MzDtrHdewvqE1H1Bp7K0v4TN4r45JAS/vWRiMEC',
    'Администратор',
    'Системы',
    'admin'
) ON CONFLICT (university_id) DO NOTHING;
