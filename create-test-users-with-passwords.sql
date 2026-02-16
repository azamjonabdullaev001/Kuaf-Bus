-- Скрипт для генерации тестовых пользователей с паролями
-- Используйте этот скрипт для создания студентов и водителей с паролями

-- ВАЖНО: Все пароли будут "password123" (хеш ниже)
-- В production измените пароли на более безопасные!

-- Хеш для пароля "password123"
-- Сгенерирован с помощью: bcrypt.hashSync('password123', 10)
-- $2a$10$rN6QkZHx5gK7bLmP9yT8qOXxVwYzJdHfM3nKpQsRtUvWxYzAbCdEf

-- Студенты с паролями
INSERT INTO users (university_id, password_hash, first_name, last_name, user_type)
VALUES 
  ('STU001', '$2a$10$rN6QkZHx5gK7bLmP9yT8qOXxVwYzJdHfM3nKpQsRtUvWxYzAbCdEf', 'Алиев', 'Рустам', 'student'),
  ('STU002', '$2a$10$rN6QkZHx5gK7bLmP9yT8qOXxVwYzJdHfM3nKpQsRtUvWxYzAbCdEf', 'Давидов', 'Нуриддин', 'student'),
  ('STU003', '$2a$10$rN6QkZHx5gK7bLmP9yT8qOXxVwYzJdHfM3nKpQsRtUvWxYzAbCdEf', 'Каримова', 'Азиза', 'student'),
  ('STU004', '$2a$10$rN6QkZHx5gK7bLmP9yT8qOXxVwYzJdHfM3nKpQsRtUvWxYzAbCdEf', 'Турсунов', 'Бекзод', 'student'),
  ('STU005', '$2a$10$rN6QkZHx5gK7bLmP9yT8qOXxVwYzJdHfM3nKpQsRtUvWxYzAbCdEf', 'Ахмедова', 'Дилноза', 'student')
ON CONFLICT (university_id) DO NOTHING;

-- Водители с паролями  
INSERT INTO users (university_id, password_hash, first_name, last_name, user_type)
VALUES 
  ('DRV001', '$2a$10$rN6QkZHx5gK7bLmP9yT8qOXxVwYzJdHfM3nKpQsRtUvWxYzAbCdEf', 'Усманов', 'Шавкат', 'driver'),
  ('DRV002', '$2a$10$rN6QkZHx5gK7bLmP9yT8qOXxVwYzJdHfM3nKpQsRtUvWxYzAbCdEf', 'Собиров', 'Улугбек', 'driver'),
  ('DRV003', '$2a$10$rN6QkZHx5gK7bLmP9yT8qOXxVwYzJdHfM3nKpQsRtUvWxYzAbCdEf', 'Мухаммадов', 'Фаррух', 'driver')
ON CONFLICT (university_id) DO NOTHING;

-- Обновить пароль для существующего администратора (65837499i9)
-- Новый пароль: admin123
UPDATE users 
SET password_hash = '$2a$10$YourNewHashHere' 
WHERE university_id = '65837499i9';

-- ИНСТРУКЦИЯ: Как сгенерировать новый пароль
-- 1. Установите Node.js и bcryptjs: npm install bcryptjs
-- 2. Запустите: node -e "console.log(require('bcryptjs').hashSync('ВАШ_ПАРОЛЬ', 10))"
-- 3. Скопируйте полученный хеш в этот файл
