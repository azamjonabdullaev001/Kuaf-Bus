@echo off
echo ====================================
echo TEZKOR YECHIM - Docker keshini tozalash va qayta qurish
echo ====================================
echo.

echo Barcha ishlamayotgan konteynerlarni o'chirish...
docker container prune -f

echo.
echo Build keshini tozalash...
docker builder prune -af

echo.
echo Admin panel qayta qurilmoqda...
docker-compose build --no-cache admin-panel

echo.
echo Admin panel ishga tushirilmoqda...
docker-compose up -d admin-panel

echo.
echo Loglarni ko'rish...
docker-compose logs -f admin-panel
