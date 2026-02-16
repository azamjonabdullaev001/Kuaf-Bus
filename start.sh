#!/bin/bash

echo "==================================="
echo "Установка зависимостей Backend..."
echo "==================================="
cd backend
go mod download
cd ..

echo ""
echo "==================================="
echo "Установка зависимостей Admin Panel..."
echo "==================================="
cd admin-panel
npm install
cd ..

echo ""
echo "==================================="
echo "Установка зависимостей Mobile App..."
echo "==================================="
cd bus
npm install
cd ..

echo ""
echo "==================================="
echo "Зависимости установлены!"
echo "==================================="
echo ""
echo "Запуск Docker контейнеров..."
docker-compose up -d

echo ""
echo "==================================="
echo "Проект запущен!"
echo "==================================="
echo ""
echo "Админ-панель: http://localhost:3000"
echo "Backend API: http://localhost:8080"
echo "PostgreSQL: localhost:5432"
echo ""
echo "Учетные данные админа:"
echo "University ID: ADMIN001"
echo "Password: admin123"
echo ""
echo "Для запуска мобильного приложения:"
echo "cd bus"
echo "npx expo start"
echo ""
