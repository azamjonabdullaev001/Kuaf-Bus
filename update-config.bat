@echo off
title Автообновление config.js с URL от ngrok
color 0B

echo ================================================
echo   Обновление config.js с URL от ngrok
echo ================================================
echo.

REM Получаем URL от ngrok
for /f "tokens=*" %%i in ('powershell -Command "(Invoke-RestMethod http://localhost:4040/api/tunnels).tunnels[0].public_url"') do set NGROK_URL=%%i

if "%NGROK_URL%"=="" (
    echo [ОШИБКА] Ngrok не запущен!
    echo.
    echo Сначала запустите: start-ngrok.bat
    echo.
    pause
    exit /b 1
)

echo Найден URL ngrok: %NGROK_URL%
echo.

REM Создаём новый config.js
(
echo // Ngrok HTTPS tunnel ^(для APK/iOS^)
echo // ВАЖНО: При перезапуске ngrok URL изменится, обновите здесь!
echo const API_URL = '%NGROK_URL%/api';
echo const WS_URL = 'wss://%NGROK_URL:https://=%/ws';
echo.
echo // Локальная разработка ^(для веб-версии в браузере^)
echo // const API_URL = 'http://192.168.0.189:8080/api';
echo // const WS_URL = 'ws://192.168.0.189:8080/ws';
echo.
echo export { API_URL, WS_URL };
) > bus\config.js

echo.
echo ================================================
echo ✅ Готово! config.js обновлён
echo ================================================
echo.
echo API URL: %NGROK_URL%/api
echo WS URL:  wss://%NGROK_URL:https://=%/ws
echo.
echo Dashboard: http://localhost:4040
echo.
pause
