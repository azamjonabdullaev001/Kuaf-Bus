#!/bin/bash

echo "==================================="
echo "Настройка IP адреса для React Native"
echo "==================================="
echo ""

echo "Текущая конфигурация:"
cat bus/config.js
echo ""
echo ""

echo "==================================="
echo "Ваши IP адреса:"
echo "==================================="
ifconfig | grep "inet " | grep -v 127.0.0.1
echo ""

read -p "Введите новый IP адрес (или нажмите Enter для использования 192.168.213.21): " NEW_IP

if [ -z "$NEW_IP" ]; then
    NEW_IP="192.168.213.21"
fi

echo ""
echo "Обновление конфигурации на IP: $NEW_IP"
echo ""

cat > bus/config.js << EOF
// Используйте IP адрес вашего компьютера в WiFi сети
const API_URL = 'http://${NEW_IP}:8080/api';
const WS_URL = 'ws://${NEW_IP}:8080/ws';

export { API_URL, WS_URL };
EOF

echo ""
echo "✅ Конфигурация обновлена!"
echo ""
echo "Новые endpoints:"
echo "  API: http://${NEW_IP}:8080/api"
echo "  WebSocket: ws://${NEW_IP}:8080/ws"
echo ""
echo "==================================="
echo "Перезапустите Expo:"
echo "  cd bus"
echo "  npx expo start --clear"
echo "==================================="
echo ""
