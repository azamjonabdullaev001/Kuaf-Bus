#!/bin/bash

echo "==================================="
echo "Тестирование API системы отслеживания автобусов"
echo "==================================="
echo ""

# Проверка доступности backend
echo "Проверка backend..."
if ! curl -s http://localhost:8080/api/admin/students > /dev/null 2>&1; then
    echo "[ОШИБКА] Backend не доступен на http://localhost:8080"
    echo "Запустите: docker-compose up -d"
    exit 1
fi
echo "[OK] Backend работает"

echo ""
echo "==================================="
echo "Тест 1: Вход как админ"
echo "==================================="
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"university_id":"ADMIN001","password":"admin123"}' \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "==================================="
echo "Сохраните токен из ответа выше"
echo ""
echo "Тест 2: Создание студента"
echo "==================================="
read -p "Введите токен: " TOKEN

curl -X POST http://localhost:8080/api/admin/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "university_id":"STUDENT001",
    "password":"student123",
    "first_name":"Иван",
    "last_name":"Иванов",
    "middle_name":"Иванович"
  }' \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "==================================="
echo "Тест 3: Создание водителя"
echo "==================================="
curl -X POST http://localhost:8080/api/admin/drivers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "university_id":"DRIVER001",
    "password":"driver123",
    "first_name":"Петр",
    "last_name":"Петров",
    "middle_name":"Петрович"
  }' \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "==================================="
echo "Тест 4: Получение всех студентов"
echo "==================================="
curl -X GET http://localhost:8080/api/admin/students \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "==================================="
echo "Тест 5: Получение всех водителей"
echo "==================================="
curl -X GET http://localhost:8080/api/admin/drivers \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "==================================="
echo "Все тесты завершены!"
echo "==================================="
