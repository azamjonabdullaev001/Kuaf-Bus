#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo "========================================"
echo "  📤 ПУБЛИКАЦИЯ OTA ОБНОВЛЕНИЯ"
echo "========================================"
echo ""

cd "$(dirname "$0")/bus"

echo "🔍 Проверка изменений..."
echo ""

echo "📝 Введите описание изменений:"
read -p "Описание: " MESSAGE

if [ -z "$MESSAGE" ]; then
    MESSAGE="Update fixes and improvements"
fi

echo ""
echo "🚀 Публикация OTA обновления на preview channel..."
echo "📦 Сообщение: $MESSAGE"
echo ""

eas update --branch preview --message "$MESSAGE"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================"
    echo "  ✅ ОБНОВЛЕНИЕ ОПУБЛИКОВАНО!"
    echo -e "========================================${NC}"
    echo ""
    echo "📱 Пользователи получат обновление:"
    echo "   • При следующем запуске приложения"
    echo "   • Или при возвращении из фона"
    echo ""
    echo "🌐 Проверить статус:"
    echo "   https://expo.dev/accounts/spm_supreme/projects/bus-tracking/updates"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Ошибка при публикации OTA${NC}"
    echo ""
fi

read -p "Нажмите Enter для выхода..."
