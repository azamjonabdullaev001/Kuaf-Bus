-- Исправление пароля администратора
-- Пароль: K7mP9nQ2rS5tV8xW1yZ4aB6cD3eF

UPDATE users 
SET password_hash = '$2b$10$gk6kAon4XYLrycT7A06AMOwxj.2mtdsyAjeaGb59HH//nDNHjsJdC'
WHERE university_id = '65837499i9';
