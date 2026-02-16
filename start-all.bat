@echo off
title Bus Tracking - ПОЛНЫЙ ЗАПУСК
color 0E

echo ================================================
echo   BUS TRACKING SYSTEM - Полный запуск
echo ================================================
echo.

echo [1/4] Проверяем Docker...
docker-compose ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [ЗАПУСК] Docker контейнеры...
    docker-compose up -d
    timeout /t 5 >nul
) else (
    echo [OK] Docker запущен
)

echo.
echo [2/4] Проверяем Ngrok...
powershell -Command "Invoke-RestMethod http://localhost:4040/api/tunnels" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ЗАПУСК] Ngrok в фоновом режиме...
    start /min "" ngrok.exe http 8080
    timeout /t 3 >nul
) else (
    echo [OK] Ngrok запущен
)

echo.
echo [3/4] Обновляем config.js...
call update-config.bat

echo.
echo [4/4] Запускаем React Native...
cd bus
start cmd /k "npm start"

echo.
echo ================================================
echo ✅ Всё запущено!
echo ================================================
echo.
echo Backend:       http://localhost:3001
echo Ngrok:         http://localhost:4040  
echo Metro:         http://localhost:8081
echo.
echo Теперь можете:
echo - Открыть приложение на телефоне через Expo Go
echo - Создать APK: npx eas build --platform android
echo.
pause
