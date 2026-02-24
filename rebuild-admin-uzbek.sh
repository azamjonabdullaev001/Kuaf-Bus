#!/bin/bash

echo "===================================="
echo "Docker Admin Panel - O'ZBEK TILIDA QAYTA QURISH"
echo "===================================="
echo ""

echo "1. Eski admin-panel konteynerini to'xtatish..."
docker-compose stop admin-panel

echo ""
echo "2. Eski admin-panel konteynerini o'chirish..."
docker-compose rm -f admin-panel

echo ""
echo "3. Docker keshini tozalash..."
docker builder prune -f

echo ""
echo "4. Admin panel obrazini qayta qurish (KESHSIZ)..."
docker-compose build --no-cache admin-panel

echo ""
echo "5. Admin panelni ishga tushirish..."
docker-compose up -d admin-panel

echo ""
echo "===================================="
echo "✓ Admin panel qayta qurildi!"
echo "✓ O'zbek tilida!"
echo "✓ Shablon tugmasi o'chirildi!"
echo "===================================="
echo ""

echo "Brauzer ochilishi kutilmoqda..."
sleep 3

if command -v xdg-open > /dev/null; then
    xdg-open http://localhost:3000
elif command -v open > /dev/null; then
    open http://localhost:3000
fi

echo ""
echo "===================================="
echo "ESLATMA:"
echo "- Brauzerda Ctrl+Shift+R bosing (hard refresh)"
echo "- Yoki brauzer keshini tozalang"
echo "===================================="
