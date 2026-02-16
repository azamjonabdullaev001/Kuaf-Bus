#!/bin/bash

echo "🔐 Генератор безопасных паролей и секретов"
echo "=========================================="
echo ""

# Генерация пароля БД
DB_PASSWORD=$(openssl rand -base64 32 | tr -d '\n' | tr -d '=')
echo "✅ Пароль базы данных (32 символа):"
echo "$DB_PASSWORD"
echo ""

# Генерация JWT секрета
JWT_SECRET=$(openssl rand -base64 64 | tr -d '\n' | tr -d '=')
echo "✅ JWT Secret (64+ символов):"
echo "$JWT_SECRET"
echo ""

# Генерация пароля администратора
ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d '\n' | tr -d '=')
echo "✅ Пароль администратора:"
echo "$ADMIN_PASSWORD"
echo ""

echo "=========================================="
echo "📝 Сохраните эти данные в безопасном месте!"
echo ""
echo "Следующие шаги:"
echo "1. Скопируйте пароли выше"
echo "2. Обновите файл .env.production.local"
echo "3. Никогда не коммитьте .env файлы в Git"
echo ""

# Опционально: создание .env.production.local с секретами
read -p "Создать .env.production.local автоматически? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    read -p "Введите домен (например, api.yourdomain.com): " DOMAIN
    
    cat > .env.production.local << EOF
# Production Environment Variables
# Сгенерировано: $(date)

# Database Configuration
POSTGRES_USER=bususer
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=bus_tracking

# Backend Configuration
DB_HOST=postgres
DB_PORT=5432
DB_USER=bususer
DB_PASSWORD=$DB_PASSWORD
DB_NAME=bus_tracking
PORT=8080
JWT_SECRET=$JWT_SECRET
ENVIRONMENT=production

# CORS Configuration (обновите домен!)
ALLOWED_ORIGINS=https://$DOMAIN,https://admin.$DOMAIN

# Frontend Configuration
REACT_APP_API_URL=https://$DOMAIN/api
REACT_APP_WS_URL=wss://$DOMAIN/ws
EOF
    
    chmod 600 .env.production.local
    echo ""
    echo "✅ Файл .env.production.local создан!"
    echo "⚠️  Проверьте и обновите ALLOWED_ORIGINS и URL если нужно"
    
    # Создание файла с паролем администратора
    cat > ADMIN_PASSWORD.txt << EOF
Пароль администратора: $ADMIN_PASSWORD

Для генерации hash используйте:
node -e "console.log(require('bcryptjs').hashSync('$ADMIN_PASSWORD', 10))"

ИЛИ используйте generate-bcrypt.js:
node generate-bcrypt.js $ADMIN_PASSWORD

УДАЛИТЕ ЭТОТ ФАЙЛ после создания администратора!
EOF
    chmod 600 ADMIN_PASSWORD.txt
    echo "✅ Пароль администратора сохранён в ADMIN_PASSWORD.txt"
    echo "⚠️  УДАЛИТЕ этот файл после настройки!"
fi

echo ""
echo "Готово! 🎉"
