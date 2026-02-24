#!/bin/bash

echo "===================================="
echo "Добавление поддержки heading (направления) для 3D иконок автобусов"
echo "===================================="
echo ""

echo "Применение миграции к базе данных..."
docker-compose exec -T postgres psql -U kuaf_user -d kuaf_bus_db < add-heading-column.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "===================================="
    echo "✓ Миграция успешно применена!"
    echo "===================================="
    echo ""
    echo "Перезапуск backend..."
    docker-compose restart backend
    
    echo ""
    echo "===================================="
    echo "✓ Готово! Теперь у вас есть 3D иконки автобусов с поворотом!"
    echo "===================================="
else
    echo ""
    echo "===================================="
    echo "✗ Ошибка при применении миграции"
    echo "===================================="
    echo "Попробуйте выполнить вручную:"
    echo "docker-compose exec postgres psql -U kuaf_user -d kuaf_bus_db"
    echo "Затем выполните SQL из файла add-heading-column.sql"
fi
