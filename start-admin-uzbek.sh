#!/bin/bash

echo "===================================="
echo "Admin Panel - O'zbek tilida qayta yuklash"
echo "===================================="
echo ""

cd admin-panel

echo "Admin panelni to'xtatish..."
pkill -f "react-scripts" 2>/dev/null

echo ""
echo "Kesh tozalamoqda..."
if [ -d "node_modules/.cache" ]; then
    rm -rf node_modules/.cache
    echo "Kesh o'chirildi!"
fi

echo ""
echo "===================================="
echo "Admin panelni ishga tushirish..."
echo "O'zbek tilida!"
echo "===================================="
echo ""

npm start &

echo ""
echo "===================================="
echo "✓ Admin panel ishga tushirildi!"
echo "✓ Brauzerda http://localhost:3000 ochiladi"
echo "✓ Hamma yozuvlar o'zbek tilida!"
echo "===================================="
