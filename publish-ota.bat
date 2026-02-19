@echo off
chcp 65001 > nul
echo.
echo ========================================
echo   📤 ПУБЛИКАЦИЯ OTA ОБНОВЛЕНИЯ
echo ========================================
echo.

cd /d "%~dp0bus"

echo 🔍 Проверка изменений...
echo.

echo 📝 Введите описание изменений:
set /p MESSAGE="Описание: "

if "%MESSAGE%"=="" (
    set MESSAGE=Update fixes and improvements
)

echo.
echo 🚀 Публикация OTA обновления на preview channel...
echo 📦 Сообщение: %MESSAGE%
echo.

call eas update --branch preview --message "%MESSAGE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   ✅ ОБНОВЛЕНИЕ ОПУБЛИКОВАНО!
    echo ========================================
    echo.
    echo 📱 Пользователи получат обновление:
    echo    • При следующем запуске приложения
    echo    • Или при возвращении из фона
    echo.
    echo 🌐 Проверить статус:
    echo    https://expo.dev/accounts/spm_supreme/projects/bus-tracking/updates
    echo.
) else (
    echo.
    echo ❌ Ошибка при публикации OTA
    echo.
)

pause
