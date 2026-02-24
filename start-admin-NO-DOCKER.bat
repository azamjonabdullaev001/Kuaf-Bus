@echo off
echo ============================================
echo ADMIN PANEL - DOCKER'SIZ ISHGA TUSHIRISH
echo ============================================
echo.
echo Bu usul Docker ishlamasa ishlaydi
echo Admin panel to'g'ridan-to'g'ri Node.js orqali ishga tushadi
echo.

cd admin-panel

echo 1. Node modullarini o'rnatish...
call npm install

echo.
echo 2. Admin panelni ishga tushirish (port 3000)...
echo.
echo ============================================
echo ✓ Admin panel ishga tushmoqda...
echo ✓ O'zbek tilida!
echo ✓ Shablon tugmasi o'chirildi!
echo ============================================
echo.
echo Brauzer: http://localhost:3000
echo Backend ishlab turishi kerak: docker-compose up -d backend postgres
echo.
echo ESLATMA: Backend muljallari .env faylida to'g'ri bo'lishi kerak:
echo   REACT_APP_API_URL=http://localhost:8080
echo   REACT_APP_WS_URL=ws://localhost:8080/ws
echo.

start http://localhost:3000

call npm start
