@echo off
echo ========================================
echo   Production Deployment Script
echo ========================================
echo.

echo [93mВАЖНО: Для production развертывания на Windows[0m
echo Рекомендуется использовать Linux сервер.
echo.
echo Если вы продолжите на Windows, убедитесь что:
echo 1. Docker Desktop установлен и запущен
echo 2. WSL 2 настроен
echo 3. .env.production.local создан с реальными паролями
echo.
pause

echo.
echo [96mПроверка наличия .env.production.local...[0m
if not exist .env.production.local (
    echo [91mОшибка: .env.production.local не найден![0m
    echo.
    echo Создайте его:
    echo 1. Скопируйте .env.production в .env.production.local
    echo 2. Измените ВСЕ пароли и секреты
    echo 3. Обновите домены и URL
    echo.
    echo Или запустите: generate-secrets.bat
    pause
    exit /b 1
)

echo [92mФайл конфигурации найден[0m
echo.

echo [96mПроверка Docker...[0m
docker --version >nul 2>&1
if errorlevel 1 (
    echo [91mОшибка: Docker не установлен или не запущен![0m
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [91mОшибка: Docker Compose не установлен![0m
    pause
    exit /b 1
)

echo [92mDocker и Docker Compose установлены[0m
echo.

echo [96mОстановка текущих контейнеров...[0m
docker-compose -f docker-compose.prod.yml down

echo.
echo [96mСборка образов...[0m
docker-compose -f docker-compose.prod.yml build --no-cache

if errorlevel 1 (
    echo [91mОшибка при сборке образов![0m
    pause
    exit /b 1
)

echo.
echo [96mЗапуск сервисов...[0m
docker-compose -f docker-compose.prod.yml up -d

if errorlevel 1 (
    echo [91mОшибка при запуске сервисов![0m
    pause
    exit /b 1
)

echo.
echo [92mОжидание запуска сервисов...[0m
timeout /t 10 /nobreak >nul

echo.
echo [96mПроверка статуса...[0m
docker-compose -f docker-compose.prod.yml ps

echo.
echo ========================================
echo [92m  Развертывание завершено![0m
echo ========================================
echo.
echo Следующие шаги:
echo 1. Проверьте логи: docker-compose -f docker-compose.prod.yml logs -f
echo 2. Создайте администратора
echo 3. Настройте SSL сертификаты
echo 4. Проверьте SECURITY_CHECKLIST.md
echo.
pause
