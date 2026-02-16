@echo off
title Ngrok HTTPS Tunnel для Bus Tracking
color 0A

echo ================================================
echo   NGROK - HTTPS Tunnel для Backend
echo ================================================
echo.
echo Запускаю туннель на порт 8080...
echo.

ngrok.exe http 8080

pause
