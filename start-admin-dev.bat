@echo off
echo ====================================
echo Admin Panel - Ishlab chiqish rejimida ishga tushirish
echo (Docker'siz, to'g'ridan-to'g'ri)
echo ====================================
echo.

cd admin-panel

echo Node modules mavjudligini tekshirish...
if not exist "node_modules" (
    echo Node modules topilmadi, o'rnatilmoqda...
    npm install
)

echo.
echo Keshni tozalash...
if exist "node_modules\.cache" (
    rmdir /S /Q node_modules\.cache
    echo Kesh o'chirildi!
)

echo.
echo ====================================
echo Admin panel ishlab chiqish rejimida ishga tushmoqda...
echo O'zbek tilida!
echo Shablon tugmasi o'chirildi!
echo ====================================
echo.

echo MUHIM: Backend ishlab turishiga ishonch hosil qiling!
echo Backend: http://localhost:8080
echo.

npm start

pause
