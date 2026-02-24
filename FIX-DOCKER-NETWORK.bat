@echo off
echo ============================================
echo DOCKER TARMOQ MUAMMOSINI HAL QILISH
echo ============================================
echo.

echo Muammo: Docker Docker Hub'ga ulana olmayapti
echo Sabab: Internet yoki DNS muammosi
echo.

echo ============================================
echo YECHIM 1: INTERNET VA DNS TEKSHIRISH
echo ============================================
echo.

echo 1. Internetni tekshiring:
ping -n 4 google.com

echo.
echo 2. Docker Hub'ni tekshiring:
ping -n 4 registry-1.docker.io

echo.
echo ============================================
echo YECHIM 2: DOCKER QAYTA ISHGA TUSHIRISH
echo ============================================
echo.

echo Docker Desktop'ni yoping va qayta oching
echo.

pause

echo.
echo ============================================
echo YECHIM 3: DNS O'ZGARTIRISH
echo ============================================
echo.
echo Agar yuqoridagi ping ishlamasa:
echo.
echo 1. Docker Desktop ochib: Settings ^> Docker Engine
echo 2. Quyidagini qo'shing:
echo.
echo {
echo   "dns": ["8.8.8.8", "8.8.4.4"]
echo }
echo.
echo 3. Apply ^& Restart
echo.

pause

echo.
echo ============================================
echo YECHIM 4: DOCKER'SIZ ISHGA TUSHIRISH
echo ============================================
echo.
echo Agar Docker umuman ishlamasa:
echo.
echo 1. Backend uchun:
echo    cd backend
echo    go run main.go
echo.
echo 2. Admin panel uchun:
echo    start-admin-NO-DOCKER.bat
echo.

pause
