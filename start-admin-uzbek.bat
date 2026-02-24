@echo off
echo ====================================
echo Admin Panel - UZBEK olarak qayta yuklash
echo ====================================
echo.

cd admin-panel

echo Admin panelni to'xtatish...
taskkill /F /IM node.exe 2>nul

echo.
echo Kesh tozalamoqda...
if exist node_modules\.cache (
    rmdir /S /Q node_modules\.cache
    echo Kesh o'chirildi!
)

echo.
echo ====================================
echo Admin panelni ishga tushirish...
echo Uzbek tilida!
echo ====================================
echo.

start cmd /k "npm start"

echo.
echo ====================================
echo ✓ Admin panel ishga tushirildi!
echo ✓ Brauzerda http://localhost:3000 ochiladi
echo ✓ Hamma yozuvlar uzbek tilida!
echo ====================================
echo.

pause
