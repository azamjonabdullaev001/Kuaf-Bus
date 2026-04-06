#!/bin/bash
###############################################################
#  KuafBus — полный скрипт установки на VPS (Ubuntu + Docker)
#  Запуск: bash vps-deploy.sh
###############################################################

set -e

# ─── Цвета ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║       KuafBus — Установка на VPS сервер           ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ─── 1. Проверка Docker ─────────────────────────────────────
echo -e "${CYAN}[1/6] Проверка Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker не найден. Устанавливаю...${NC}"
    sudo apt-get update -qq
    sudo apt-get install -y -qq ca-certificates curl gnupg lsb-release
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    echo -e "${GREEN}✅ Docker установлен${NC}"
else
    echo -e "${GREEN}✅ Docker уже установлен: $(docker --version)${NC}"
fi

# Docker Compose (plugin or standalone)
if docker compose version &>/dev/null; then
    DC="docker compose"
elif command -v docker-compose &>/dev/null; then
    DC="docker-compose"
else
    echo -e "${YELLOW}Устанавливаю Docker Compose plugin...${NC}"
    sudo apt-get install -y -qq docker-compose-plugin
    DC="docker compose"
fi
echo -e "${GREEN}✅ Docker Compose: $DC${NC}"

# ─── 2. Определение IP адреса VPS ───────────────────────────
echo ""
echo -e "${CYAN}[2/6] Настройка IP адреса...${NC}"

# Автоматическое определение внешнего IP
VPS_IP=$(curl -s -4 ifconfig.me 2>/dev/null || curl -s -4 icanhazip.com 2>/dev/null || echo "")

if [ -z "$VPS_IP" ]; then
    echo -e "${YELLOW}Не удалось определить IP автоматически.${NC}"
    read -p "Введите IP адрес вашего VPS: " VPS_IP
fi

echo -e "${GREEN}✅ IP адрес VPS: ${VPS_IP}${NC}"

# ─── 3. Генерация .env.production ───────────────────────────
echo ""
echo -e "${CYAN}[3/6] Создание конфигурации .env.production...${NC}"

# Генерируем безопасные пароли
DB_PASS=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 20)
JWT_SECRET=$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c 40)

cat > .env.production <<EOF
# ────────────────────────────────────────────
# KuafBus Production Environment
# Сгенерировано: $(date)
# ────────────────────────────────────────────

# Database
POSTGRES_USER=bususer
POSTGRES_PASSWORD=${DB_PASS}
POSTGRES_DB=bus_tracking

# Backend
PORT=8080
DB_HOST=postgres
DB_PORT=5432
DB_USER=bususer
DB_PASSWORD=${DB_PASS}
DB_NAME=bus_tracking
JWT_SECRET=${JWT_SECRET}
ALLOWED_ORIGINS=http://${VPS_IP},http://${VPS_IP}:80,http://${VPS_IP}:3001
ENVIRONMENT=production

# Admin Panel
REACT_APP_API_URL=http://${VPS_IP}:8080/api
EOF

echo -e "${GREEN}✅ .env.production создан${NC}"
echo -e "${YELLOW}   DB Password: ${DB_PASS}${NC}"
echo -e "${YELLOW}   JWT Secret:  ${JWT_SECRET}${NC}"

# ─── 4. Настройка nginx для IP (без SSL) ────────────────────
echo ""
echo -e "${CYAN}[4/6] Настройка nginx...${NC}"

cat > admin-panel/nginx.vps.conf <<'NGINX'
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss image/svg+xml;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # React SPA
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API proxy
    location /api {
        proxy_pass http://backend:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 90s;
        proxy_send_timeout 90s;
    }

    # WebSocket proxy
    location /ws {
        proxy_pass http://backend:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}
NGINX

echo -e "${GREEN}✅ nginx конфигурация создана${NC}"

# ─── 5. Создание docker-compose для VPS ─────────────────────
echo ""
echo -e "${CYAN}[5/6] Создание docker-compose.vps.yml...${NC}"

cat > docker-compose.vps.yml <<EOF
services:
  # PostgreSQL
  postgres:
    image: postgres:15-alpine
    container_name: kuafbus-db
    environment:
      POSTGRES_USER: \${POSTGRES_USER}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD}
      POSTGRES_DB: \${POSTGRES_DB}
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - kuafbus
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: always

  # Backend (Go)
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    container_name: kuafbus-backend
    ports:
      - "8080:8080"
    env_file:
      - .env.production
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - kuafbus
    restart: always
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Admin Panel (React + Nginx)
  admin-panel:
    build:
      context: ./admin-panel
      dockerfile: Dockerfile
      args:
        REACT_APP_API_URL: http://${VPS_IP}:8080/api
    container_name: kuafbus-admin
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - kuafbus
    restart: always
    volumes:
      - ./admin-panel/nginx.vps.conf:/etc/nginx/conf.d/default.conf:ro

volumes:
  pgdata:
    driver: local

networks:
  kuafbus:
    driver: bridge
EOF

echo -e "${GREEN}✅ docker-compose.vps.yml создан${NC}"

# ─── 6. Сборка и запуск ─────────────────────────────────────
echo ""
echo -e "${CYAN}[6/6] Сборка и запуск контейнеров...${NC}"
echo -e "${YELLOW}(Это может занять 3-5 минут при первом запуске)${NC}"
echo ""

# Остановить старые контейнеры если есть
$DC -f docker-compose.vps.yml down 2>/dev/null || true

# Сборка
$DC -f docker-compose.vps.yml --env-file .env.production build

# Запуск
$DC -f docker-compose.vps.yml --env-file .env.production up -d

# Ждём запуска
echo ""
echo -e "${YELLOW}Ожидание запуска сервисов (30 сек)...${NC}"
sleep 30

# ─── Проверка ────────────────────────────────────────────────
echo ""
echo -e "${CYAN}Проверка сервисов...${NC}"
echo ""

$DC -f docker-compose.vps.yml ps

echo ""

# Проверка backend
if curl -sf http://localhost:8080/api/health >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend — РАБОТАЕТ${NC}"
else
    echo -e "${RED}⚠️  Backend — загружается, подождите ещё 30 сек${NC}"
fi

# Проверка admin panel
if curl -sf http://localhost:80 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Admin Panel — РАБОТАЕТ${NC}"
else
    echo -e "${RED}⚠️  Admin Panel — загружается${NC}"
fi

# ─── Firewall ────────────────────────────────────────────────
echo ""
echo -e "${CYAN}Настройка UFW Firewall...${NC}"
if command -v ufw &>/dev/null; then
    sudo ufw allow 22/tcp   >/dev/null 2>&1  # SSH
    sudo ufw allow 80/tcp   >/dev/null 2>&1  # HTTP (Admin Panel)
    sudo ufw allow 8080/tcp >/dev/null 2>&1  # Backend API + WebSocket
    echo -e "${GREEN}✅ Порты 22, 80, 8080 открыты${NC}"
else
    echo -e "${YELLOW}UFW не установлен. Убедитесь, что порты 80 и 8080 открыты.${NC}"
fi

# ─── Итог ────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!              ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Admin Panel:${NC}  http://${VPS_IP}"
echo -e "  ${CYAN}API:${NC}          http://${VPS_IP}:8080/api"
echo -e "  ${CYAN}WebSocket:${NC}    ws://${VPS_IP}:8080/ws"
echo ""
echo -e "  ${CYAN}Логин Admin:${NC}"
echo -e "    ID:       ${YELLOW}65837499i9${NC}"
echo -e "    Пароль:   ${YELLOW}K7mP9nQ2rS5tV8xW1yZ4aB6cD3eF${NC}"
echo ""
echo -e "  ${CYAN}Для мобилки (bus/config.js) поменяй:${NC}"
echo -e "    API_URL:  ${YELLOW}http://${VPS_IP}:8080${NC}"
echo -e "    WS_URL:   ${YELLOW}ws://${VPS_IP}:8080/ws${NC}"
echo ""
echo -e "  ${CYAN}Полезные команды:${NC}"
echo -e "    Логи:     ${YELLOW}$DC -f docker-compose.vps.yml logs -f${NC}"
echo -e "    Стоп:     ${YELLOW}$DC -f docker-compose.vps.yml down${NC}"
echo -e "    Рестарт:  ${YELLOW}$DC -f docker-compose.vps.yml restart${NC}"
echo -e "    Статус:   ${YELLOW}$DC -f docker-compose.vps.yml ps${NC}"
echo ""
