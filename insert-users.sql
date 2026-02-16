-- Insert users with correct bcrypt password hashes
-- Password for all users: admin123
INSERT INTO users (university_id, password_hash, first_name, last_name, user_type) VALUES 
('ADMIN001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin', 'User', 'admin'),
('STUDENT001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Student', 'User', 'student'),
('DRIVER001', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Driver', 'User', 'driver');
