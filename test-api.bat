@echo off
echo ===================================
echo Тестирование API системы отслеживания автобусов
echo ===================================
echo.

REM Проверка доступности backend
echo Проверка backend...
curl -s http://localhost:8080/api/admin/students > nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Backend не доступен на http://localhost:8080
    echo Запустите: docker-compose up -d
    pause
    exit /b 1
)
echo [OK] Backend работает

echo.
echo ===================================
echo Тест 1: Вход как админ
echo ===================================
curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"university_id\":\"ADMIN001\",\"password\":\"admin123\"}" ^
  -w "\nHTTP Status: %%{http_code}\n"

echo.
echo ===================================
echo Для продолжения тестов:
echo 1. Скопируйте токен из ответа выше
echo 2. Откройте test-api.http в VS Code
echo 3. Установите расширение REST Client
echo 4. Замените TOKEN на ваш токен
echo 5. Нажимайте "Send Request" для каждого теста
echo ===================================
echo.

pause
