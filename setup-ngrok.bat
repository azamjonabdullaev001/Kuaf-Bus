@echo off
echo ================================================
echo Ngrok Setup - Добавление Authtoken
echo ================================================
echo.
echo 1. Откройте: https://dashboard.ngrok.com/signup
echo 2. Зарегистрируйтесь (бесплатно)
echo 3. Скопируйте Authtoken
echo.
set /p TOKEN="Вставьте ваш Authtoken и нажмите Enter: "
echo.
echo Добавляю токен...
ngrok.exe config add-authtoken %TOKEN%
echo.
echo ================================================
echo Готово! Теперь перезапустите ngrok:
echo    ngrok.exe http 8080
echo ================================================
pause
