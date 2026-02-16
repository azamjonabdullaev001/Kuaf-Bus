@echo off
echo ===================================
echo Настройка IP адреса для React Native
echo ===================================
echo.

echo Текущая конфигурация:
type bus\config.js
echo.
echo.

echo ===================================
echo Ваши IP адреса:
echo ===================================
ipconfig | findstr /i "IPv4"
echo.

set /p NEW_IP="Введите новый IP адрес (или нажмите Enter для использования 192.168.213.21): "

if "%NEW_IP%"=="" set NEW_IP=192.168.213.21

echo.
echo Обновление конфигурации на IP: %NEW_IP%
echo.

(
echo // Используйте IP адрес вашего компьютера в WiFi сети
echo const API_URL = 'http://%NEW_IP%:8080/api';
echo const WS_URL = 'ws://%NEW_IP%:8080/ws';
echo.
echo export { API_URL, WS_URL };
) > bus\config.js

echo.
echo ✅ Конфигурация обновлена!
echo.
echo Новые endpoints:
echo   API: http://%NEW_IP%:8080/api
echo   WebSocket: ws://%NEW_IP%:8080/ws
echo.
echo ===================================
echo Перезапустите Expo:
echo   cd bus
echo   npx expo start --clear
echo ===================================
echo.

pause
