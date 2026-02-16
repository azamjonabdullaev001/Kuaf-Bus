#!/bin/bash

# Production Deployment Script
# Автоматизированный скрипт развёртывания

set -e  # Выход при ошибке

echo "🚀 Production Deployment Script"
echo "================================"
echo ""

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Проверка, что скрипт запущен не от root
if [ "$EUID" -eq 0 ]; then 
   echo -e "${RED}❌ Не запускайте этот скрипт от root!${NC}"
   echo "Используйте обычного пользователя с правами sudo"
   exit 1
fi

# Проверка наличия .env.production.local
if [ ! -f .env.production.local ]; then
    echo -e "${RED}❌ Файл .env.production.local не найден!${NC}"
    echo ""
    echo "Создайте его следуя инструкциям:"
    echo "1. Скопируйте .env.production в .env.production.local"
    echo "2. Измените ВСЕ пароли и секреты"
    echo "3. Обновите домены и URL"
    echo ""
    echo "Или запустите: ./generate-secrets.sh"
    exit 1
fi

# Проверка наличия SSL сертификатов
if [ ! -d "ssl" ] || [ ! -f "ssl/fullchain.pem" ] || [ ! -f "ssl/privkey.pem" ]; then
    echo -e "${YELLOW}⚠️  SSL сертификаты не найдены в директории ssl/${NC}"
    read -p "Продолжить без SSL? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Установите SSL сертификаты и повторите"
        exit 1
    fi
fi

# Проверка дефолтных паролей
echo "🔍 Проверка безопасности..."
if grep -q "buspassword" .env.production.local; then
    echo -e "${RED}❌ КРИТИЧНО: Обнаружен дефолтный пароль 'buspassword'!${NC}"
    echo "Обновите пароли в .env.production.local"
    exit 1
fi

if grep -q "dev-jwt-secret" .env.production.local; then
    echo -e "${RED}❌ КРИТИЧНО: Обнаружен дефолтный JWT_SECRET!${NC}"
    echo "Обновите JWT_SECRET в .env.production.local"
    exit 1
fi

if grep -q "localhost" .env.production.local; then
    echo -e "${YELLOW}⚠️  Предупреждение: Обнаружен localhost в .env.production.local${NC}"
    read -p "Это может быть проблемой для production. Продолжить? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}✅ Начальные проверки пройдены${NC}"
echo ""

# Проверка Docker
echo "🐳 Проверка Docker..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker не установлен!${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose не установлен!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker и Docker Compose установлены${NC}"
echo ""

# Загрузка переменных окружения
echo "📋 Загрузка конфигурации..."
export $(cat .env.production.local | grep -v '^#' | xargs)
echo -e "${GREEN}✅ Конфигурация загружена${NC}"
echo ""

# Создание бэкапа если БД уже существует
if docker volume ls | grep -q "bus-tracking_postgres_data_prod"; then
    echo "💾 Создание бэкапа существующей базы данных..."
    BACKUP_DIR="backups"
    mkdir -p $BACKUP_DIR
    BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql"
    
    if docker ps | grep -q "bus-tracking-db-prod"; then
        docker exec bus-tracking-db-prod pg_dump -U $DB_USER $DB_NAME > $BACKUP_FILE
        echo -e "${GREEN}✅ Бэкап создан: $BACKUP_FILE${NC}"
    fi
    echo ""
fi

# Остановка текущих контейнеров если запущены
if docker ps | grep -q "bus-tracking"; then
    echo "🛑 Остановка текущих контейнеров..."
    docker-compose -f docker-compose.prod.yml down
    echo -e "${GREEN}✅ Контейнеры остановлены${NC}"
    echo ""
fi

# Сборка образов
echo "🔨 Сборка Docker образов..."
docker-compose -f docker-compose.prod.yml build --no-cache

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при сборке образов${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Образы собраны${NC}"
echo ""

# Запуск сервисов
echo "🚀 Запуск сервисов..."
docker-compose -f docker-compose.prod.yml up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при запуске сервисов${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Сервисы запущены${NC}"
echo ""

# Ожидание запуска
echo "⏳ Ожидание запуска сервисов..."
sleep 10

# Проверка статуса
echo "🔍 Проверка статуса сервисов..."
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "🔍 Проверка health endpoints..."

# Проверка backend health
if command -v curl &> /dev/null; then
    sleep 5
    if curl -f http://localhost:8080/api/health &> /dev/null; then
        echo -e "${GREEN}✅ Backend работает${NC}"
    else
        echo -e "${RED}⚠️  Backend health check не прошёл${NC}"
        echo "Проверьте логи: docker-compose -f docker-compose.prod.yml logs backend"
    fi
fi

echo ""
echo "================================"
echo -e "${GREEN}✅ Развёртывание завершено!${NC}"
echo "================================"
echo ""
echo "📊 Следующие шаги:"
echo "1. Проверьте логи: docker-compose -f docker-compose.prod.yml logs -f"
echo "2. Создайте администратора (см. PRODUCTION_DEPLOYMENT.md)"
echo "3. Настройте автоматические бэкапы"
echo "4. Проверьте SSL сертификаты"
echo "5. Проверьте чеклист безопасности: SECURITY_CHECKLIST.md"
echo ""
echo "🌐 Сервисы доступны:"
echo "- API: https://$(echo $ALLOWED_ORIGINS | cut -d, -f1 | sed 's/https:\/\///')/api"
echo "- WebSocket: wss://$(echo $ALLOWED_ORIGINS | cut -d, -f1 | sed 's/https:\/\///')/ws"
echo "- Admin Panel: https://$(echo $ALLOWED_ORIGINS | cut -d, -f1 | sed 's/https:\/\///')"
echo ""
echo "📝 Для просмотра логов: docker-compose -f docker-compose.prod.yml logs -f"
echo "🛑 Для остановки: docker-compose -f docker-compose.prod.yml down"
echo ""
