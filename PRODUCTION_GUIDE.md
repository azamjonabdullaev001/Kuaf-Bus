# 🚀 Полное руководство по развёртыванию системы отслеживания автобусов

**Всё что нужно знать для развёртывания и обслуживания системы - в одном файле**

---

## 📖 СОДЕРЖАНИЕ

1. [Что нужно подготовить](#что-нужно-подготовить)
2. [Пошаговая инструкция развёртывания](#пошаговая-инструкция)
3. [Быстрая справка по командам](#командная-справка)
4. [Чеклист безопасности](#безопасность)
5. [Решение проблем](#проблемы)
6. [Регулярное обслуживание](#обслуживание)

---

# ЧТО НУЖНО ПОДГОТОВИТЬ

## Требования к серверу

- **ОС**: Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- **RAM**: Минимум 2GB, рекомендуется 4GB
- **CPU**: Минимум 2 cores
- **Диск**: Минимум 20GB свободного места
- **Сеть**: Статический IP адрес или доменное имя

## Что нужно иметь

✅ **Сервер VPS/Cloud** с SSH доступом  
✅ **Доменное имя** (опционально, но рекомендуется)  
✅ **Локальный компьютер** с Git  

---

# ПОШАГОВАЯ ИНСТРУКЦИЯ

## ЭТАП 1: ПОДГОТОВКА СЕРВЕРА

### Шаг 1.1 - Подключение к серверу

```bash
ssh username@YOUR_SERVER_IP
# Замените username и YOUR_SERVER_IP на ваши данные
# Пример: ssh root@123.45.67.89
```

### Шаг 1.2 - Обновление системы

```bash
sudo apt update
sudo apt upgrade -y
```

⏳ Ожидайте 2-5 минут

### Шаг 1.3 - Установка Docker

```bash
# Скачиваем установщик
curl -fsSL https://get.docker.com -o get-docker.sh

# Устанавливаем
sudo sh get-docker.sh

# Добавляем пользователя в группу docker
sudo usermod -aG docker $USER
```

⚠️ **ВАЖНО**: После последней команды выйдите и зайдите заново:

```bash
exit
# Затем снова: ssh username@YOUR_SERVER_IP
```

### Шаг 1.4 - Установка Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

### Шаг 1.5 - Проверка установки

```bash
docker --version
# Должны увидеть: Docker version 24.0.7 (или новее)

docker-compose --version
# Должны увидеть: docker-compose version 1.29.2 (или новее)
```

### Шаг 1.6 - Настройка файрвола

```bash
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable
# На вопрос введите: y

# Проверка
sudo ufw status
```

---

## ЭТАП 2: ЗАГРУЗКА ПРОЕКТА

### Шаг 2.1 - Создание директории

```bash
sudo mkdir -p /opt/bus-tracking
sudo chown $USER:$USER /opt/bus-tracking
cd /opt/bus-tracking
```

### Шаг 2.2 - Загрузка файлов

**Вариант А - Через Git:**
```bash
git clone https://github.com/ваш-username/ваш-репозиторий.git .
```

**Вариант Б - С локального компьютера:**

На вашем компьютере (Windows PowerShell):
```powershell
scp -r "d:\app\kuaf bus\*" username@YOUR_SERVER_IP:/opt/bus-tracking/
```

⏳ Ожидайте загрузки (2-5 минут)

### Шаг 2.3 - Проверка

```bash
cd /opt/bus-tracking
ls -la
# Должны увидеть: backend/, admin-panel/, bus/, docker-compose.yml и другие файлы
```

---

## ЭТАП 3: SSL СЕРТИФИКАТЫ

### Вариант А: Let's Encrypt (если есть домен)

```bash
# Установка Certbot
sudo apt install certbot -y

# Остановка Docker (если запущен)
docker-compose down

# Получение сертификата (ЗАМЕНИТЕ yourdomain.com на ваш домен!)
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Копирование сертификатов
cd /opt/bus-tracking
mkdir ssl
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/
sudo chmod 644 ssl/*.pem
```

### Вариант Б: Самоподписанный (если НЕТ домена)

```bash
cd /opt/bus-tracking
mkdir ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/privkey.pem \
  -out ssl/fullchain.pem \
  -subj "/C=RU/ST=State/L=City/O=Organization/CN=$(curl -s ifconfig.me)"
sudo chmod 644 ssl/*.pem
```

### Проверка

```bash
ls -la ssl/
# Должны увидеть: fullchain.pem и privkey.pem
```

---

## ЭТАП 4: ГЕНЕРАЦИЯ ПАРОЛЕЙ

### Шаг 4.1 - Запуск генератора

```bash
cd /opt/bus-tracking
chmod +x generate-secrets.sh
./generate-secrets.sh
```

### Шаг 4.2 - Сохранение паролей

Скрипт выведет что-то вроде:

```
✅ Пароль базы данных (32 символа):
aB3cD4eF5gH6iJ7kL8mN9oP0qR1sT2uV

✅ JWT Secret (64+ символов):
xYz1Abc2Def3Ghi4Jkl5Mno6Pqr7Stu8Vwx9Yza0Bcd1Efg2Hij3Klm4Nop5Qrs6Tuv

✅ Пароль администратора:
wX9yZ0aB1cD2eF3
```

📝 **СКОПИРУЙТЕ ЭТИ ПАРОЛИ!** Они понадобятся позже.

### Шаг 4.3 - Автоматическое создание конфигурации

На вопрос: `Создать .env.production.local автоматически? (y/n)`

Введите: **y**

Затем введите:
- **Если есть домен**: `yourdomain.com`
- **Если НЕТ домена**: `123.45.67.89` (ваш IP сервера)

### Шаг 4.4 - Проверка конфигурации

```bash
cat .env.production.local
```

Убедитесь что:
- Пароли заполнены
- Домен/IP правильный
- ALLOWED_ORIGINS содержит ваш домен или IP

### Шаг 4.5 - Ручное редактирование (если нужно)

```bash
nano .env.production.local
```

**Важные параметры:**

Если **ЕСТЬ домен**:
```env
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
REACT_APP_API_URL=https://yourdomain.com/api
REACT_APP_WS_URL=wss://yourdomain.com/ws
```

Если **НЕТ домена**:
```env
ALLOWED_ORIGINS=http://YOUR_IP,https://YOUR_IP
REACT_APP_API_URL=http://YOUR_IP:8080/api
REACT_APP_WS_URL=ws://YOUR_IP:8080/ws
```

Сохранение: `Ctrl + O`, `Enter`, `Ctrl + X`

---

## ЭТАП 5: НАСТРОЙКА NGINX

```bash
nano admin-panel/nginx.prod.conf
```

Найдите строки:
```nginx
server_name yourdomain.com www.yourdomain.com;
```

Замените на:
- **Если есть домен**: ваш домен
- **Если НЕТ домена**: закомментируйте (добавьте `#` в начале)

Сохранение: `Ctrl + O`, `Enter`, `Ctrl + X`

---

## ЭТАП 6: РАЗВЁРТЫВАНИЕ

### Шаг 6.1 - Запуск

```bash
cd /opt/bus-tracking
chmod +x deploy-production.sh
./deploy-production.sh
```

⏳ **Ожидайте 5-15 минут**

Вы увидите:
- 🔍 Проверка безопасности...
- 🐳 Проверка Docker...
- 🔨 Сборка Docker образов...
- 🚀 Запуск сервисов...
- ✅ Развёртывание завершено!

### Шаг 6.2 - Проверка статуса

```bash
docker-compose -f docker-compose.prod.yml ps
```

Должны увидеть 3 контейнера в состоянии `Up`:
- `bus-tracking-db-prod`
- `bus-tracking-backend-prod`
- `bus-tracking-admin-prod`

---

## ЭТАП 7: СОЗДАНИЕ АДМИНИСТРАТОРА

### Шаг 7.1 - Получение пароля

```bash
cat ADMIN_PASSWORD.txt
# Скопируйте показанный пароль
```

### Шаг 7.2 - Генерация хеша

```bash
# Установка Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Установка bcryptjs
cd /opt/bus-tracking
npm install bcryptjs

# Генерация хеша (ЗАМЕНИТЕ YOUR_PASSWORD на пароль из ADMIN_PASSWORD.txt!)
node -e "console.log(require('bcryptjs').hashSync('YOUR_PASSWORD', 10))"
```

📝 **Скопируйте полученный хеш** (длинная строка начинающаяся с `$2a$10$...`)

### Шаг 7.3 - Обновление в базе данных

```bash
docker exec -it bus-tracking-db-prod psql -U bususer -d bus_tracking
```

В базе данных выполните (ЗАМЕНИТЕ GENERATED_HASH на ваш хеш!):

```sql
UPDATE users 
SET password_hash = 'GENERATED_HASH'
WHERE university_id = '65837499i9';
```

Должны увидеть: `UPDATE 1`

Выход из базы:
```sql
\q
```

### Шаг 7.4 - Удаление файла с паролем

```bash
rm ADMIN_PASSWORD.txt
```

---

## ЭТАП 8: ПРОВЕРКА

### Проверка Backend

```bash
curl http://localhost:8080/api/health
# Должны увидеть: {"status":"ok"}
```

### Проверка логина администратора

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"university_id":"65837499i9","password":"ВАШ_ПАРОЛЬ"}'
# Должны увидеть ответ с token
```

### Проверка в браузере

Откройте:
- **Если есть домен**: `https://yourdomain.com`
- **Если НЕТ домена**: `http://YOUR_SERVER_IP`

Войдите:
- **University ID**: `65837499i9`
- **Password**: (пароль который вы установили)

✅ **Если вошли - всё работает!**

---

## ЭТАП 9: НАСТРОЙКА БЭКАПОВ

### Создание директории

```bash
sudo mkdir -p /opt/backups
sudo chown $USER:$USER /opt/backups
```

### Создание скрипта

```bash
nano /opt/bus-tracking/backup.sh
```

Вставьте:

```bash
#!/bin/bash
BACKUP_DIR="/opt/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
docker exec bus-tracking-db-prod pg_dump -U bususer bus_tracking > "$BACKUP_DIR/backup_$TIMESTAMP.sql"
find $BACKUP_DIR -name "backup_*.sql" -mtime +30 -delete
echo "Backup completed: backup_$TIMESTAMP.sql"
```

Сохраните и сделайте исполняемым:

```bash
chmod +x /opt/bus-tracking/backup.sh
```

### Настройка автоматического бэкапа (каждый день в 2:00)

```bash
crontab -e
# Выберите nano (обычно опция 1)
```

Добавьте в конец:

```
0 2 * * * /opt/bus-tracking/backup.sh >> /var/log/backup.log 2>&1
```

Сохраните: `Ctrl + O`, `Enter`, `Ctrl + X`

### Тестирование

```bash
/opt/bus-tracking/backup.sh
ls -lh /opt/backups/
# Должны увидеть файл backup_*.sql
```

---

## ЭТАП 10: НАСТРОЙКА МОБИЛЬНОГО ПРИЛОЖЕНИЯ

На **ВАШЕМ КОМПЬЮТЕРЕ** (не на сервере):

### Обновление конфигурации

Откройте `bus/config.js` и измените:

**Если есть домен:**
```javascript
const API_URL = 'https://yourdomain.com/api';
const WS_URL = 'wss://yourdomain.com/ws';
export { API_URL, WS_URL };
```

**Если НЕТ домена:**
```javascript
const API_URL = 'http://YOUR_SERVER_IP:8080/api';
const WS_URL = 'ws://YOUR_SERVER_IP:8080/ws';
export { API_URL, WS_URL };
```

### Запуск приложения

```bash
cd bus
npx expo start --clear
```

Отсканируйте QR код в Expo Go приложении.

---

# КОМАНДНАЯ СПРАВКА

## Управление сервисами

```bash
# Запуск
docker-compose -f docker-compose.prod.yml up -d

# Остановка
docker-compose -f docker-compose.prod.yml down

# Перезапуск всех
docker-compose -f docker-compose.prod.yml restart

# Перезапуск конкретного сервиса
docker-compose -f docker-compose.prod.yml restart backend

# Статус
docker-compose -f docker-compose.prod.yml ps

# Пересборка и запуск
docker-compose -f docker-compose.prod.yml up -d --build
```

## Логи

```bash
# Все логи (в реальном времени)
docker-compose -f docker-compose.prod.yml logs -f

# Конкретный сервис
docker-compose -f docker-compose.prod.yml logs -f backend
docker-compose -f docker-compose.prod.yml logs -f postgres
docker-compose -f docker-compose.prod.yml logs -f admin-panel

# Последние 100 строк
docker-compose -f docker-compose.prod.yml logs -f --tail=100

# С временными метками
docker-compose -f docker-compose.prod.yml logs -f -t
```

## Работа с базой данных

```bash
# Подключение к БД
docker exec -it bus-tracking-db-prod psql -U bususer -d bus_tracking

# Создание бэкапа
docker exec bus-tracking-db-prod pg_dump -U bususer bus_tracking > backup.sql

# Восстановление из бэкапа
docker exec -i bus-tracking-db-prod psql -U bususer bus_tracking < backup.sql

# Просмотр таблиц
docker exec -it bus-tracking-db-prod psql -U bususer -d bus_tracking -c "\dt"

# Количество пользователей
docker exec -it bus-tracking-db-prod psql -U bususer -d bus_tracking -c "SELECT COUNT(*) FROM users;"
```

## Мониторинг

```bash
# Использование ресурсов
docker stats

# Использование диска
df -h
docker system df

# Сетевые настройки
docker network ls
docker network inspect bus-tracking_bus-network-prod
```

## Проверка работоспособности

```bash
# Backend health check
curl http://localhost:8080/api/health

# Проверка WebSocket (требует wscat)
npm install -g wscat
wscat -c ws://localhost:8080/ws

# SSL сертификат (если используется)
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Проверка портов
sudo netstat -tulpn | grep LISTEN
```

---

# БЕЗОПАСНОСТЬ

## Чеклист перед запуском

### Критические (ОБЯЗАТЕЛЬНО)

- [ ] Изменён пароль БД с дефолтного `buspassword`
- [ ] Пароль БД содержит минимум 20 символов
- [ ] JWT_SECRET изменён и содержит минимум 64 символа
- [ ] Пароль администратора изменён с `K7mP9nQ2rS5tV8xW1yZ4aB6cD3eF`
- [ ] University ID администратора изменён с `65837499i9` (опционально)
- [ ] CORS настроен ТОЛЬКО для вашего домена (не "*")
- [ ] SSL сертификат установлен и работает
- [ ] .env файлы НЕ в Git репозитории
- [ ] Файрвол настроен (только порты 22, 80, 443)

### Важные

- [ ] SSH доступ настроен с ключами (пароли отключены)
- [ ] Создан непривилегированный пользователь
- [ ] Настроены регулярные бэкапы
- [ ] Логи Docker настроены с ротацией
- [ ] Health check эндпоинты работают
- [ ] Обновления безопасности установлены

### Рекомендуемые

- [ ] Установлен Web Application Firewall
- [ ] Настроен мониторинг доступности
- [ ] Все зависимости обновлены
- [ ] Rate limiting настроен для API
- [ ] Source maps отключены в production

## Хорошие практики

### Пароли

✅ **ПРАВИЛЬНО:**
- Минимум 20 символов
- Буквы, цифры, спецсимволы
- Генерируются автоматически
- Не повторяются

❌ **НЕПРАВИЛЬНО:**
- Простые пароли типа "password123"
- Одинаковые пароли везде
- Пароли из словаря
- Короткие пароли

### CORS

✅ **ПРАВИЛЬНО:**
```env
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

❌ **НЕПРАВИЛЬНО:**
```env
ALLOWED_ORIGINS=*
ALLOWED_ORIGINS=http://localhost:3000,*
```

### SSL

✅ **ПРАВИЛЬНО:**
- Let's Encrypt для production
- Автообновление сертификатов
- HTTPS везде (включая API и WebSocket)
- HTTP редирект на HTTPS

❌ **НЕПРАВИЛЬНО:**
- Самоподписанный в production
- Истекшие сертификаты
- Смешанный HTTP/HTTPS контент

---

# ПРОБЛЕМЫ

## Backend не запускается

### Симптомы
- Контейнер падает сразу после запуска
- В логах ошибки подключения к БД

### Решение

```bash
# 1. Проверить логи
docker-compose -f docker-compose.prod.yml logs backend

# 2. Проверить переменные окружения
docker exec bus-tracking-backend-prod env | grep DB

# 3. Проверить что БД запущена
docker-compose -f docker-compose.prod.yml ps postgres

# 4. Проверить подключение к БД
docker exec -it bus-tracking-db-prod psql -U bususer -d bus_tracking

# 5. Перезапуск
docker-compose -f docker-compose.prod.yml restart backend
```

---

## Не могу войти в админ-панель

### Симптомы
- Страница не открывается
- Белый экран
- Ошибка подключения

### Решение

```bash
# 1. Проверить что nginx работает
docker-compose -f docker-compose.prod.yml ps admin-panel

# 2. Проверить логи nginx
docker-compose -f docker-compose.prod.yml logs admin-panel

# 3. Проверить что backend доступен
curl http://localhost:8080/api/health

# 4. Проверить файрвол
sudo ufw status

# 5. Проверить порты
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
```

---

## CORS ошибки

### Симптомы
- В консоли браузера: "CORS policy blocked"
- API запросы не проходят

### Решение

```bash
# 1. Проверить ALLOWED_ORIGINS
cat .env.production.local | grep ALLOWED_ORIGINS

# 2. Убедиться что домен правильный
# ALLOWED_ORIGINS должен содержать ТОЧНЫЙ адрес с которого заходите

# 3. Отредактировать если нужно
nano .env.production.local

# 4. Перезапустить backend
docker-compose -f docker-compose.prod.yml restart backend

# 5. Проверить логи backend
docker-compose -f docker-compose.prod.yml logs backend | grep CORS
```

---

## SSL не работает

### Симптомы
- Браузер показывает "Небезопасно"
- Сертификат недействителен
- ERR_CERT_ ошибки

### Решение

```bash
# 1. Проверить наличие сертификатов
ls -la ssl/
# Должны быть: fullchain.pem и privkey.pem

# 2. Проверить nginx конфигурацию
docker exec bus-tracking-admin-prod nginx -t

# 3. Проверить сертификат
openssl x509 -in ssl/fullchain.pem -text -noout | grep "Not After"

# 4. Если истёк, продлить (Let's Encrypt)
sudo certbot renew

# 5. Перезапустить nginx
docker-compose -f docker-compose.prod.yml restart admin-panel
```

---

## База данных не запускается

### Симптомы
- postgres контейнер в статусе Restarting
- Backend не может подключиться

### Решение

```bash
# 1. Проверить логи
docker-compose -f docker-compose.prod.yml logs postgres

# 2. Проверить пароль в .env
cat .env.production.local | grep POSTGRES_PASSWORD

# 3. Если пароль изменили после создания volume
docker-compose -f docker-compose.prod.yml down -v
docker-compose -f docker-compose.prod.yml up -d

# 4. Проверить права на volume
docker volume inspect bus-tracking_postgres_data_prod
```

---

## WebSocket не работает

### Симптомы
- Карта не обновляется
- Координаты не передаются
- В логах ошибки WebSocket

### Решение

```bash
# 1. Проверить URL в мобильном приложении
# Должен быть: wss:// (с SSL) или ws:// (без SSL)

# 2. Проверить nginx конфигурацию
docker exec bus-tracking-admin-prod cat /etc/nginx/conf.d/default.conf | grep -A 10 "location /ws"

# 3. Проверить backend логи
docker-compose -f docker-compose.prod.yml logs backend | grep -i websocket

# 4. Тест подключения
npm install -g wscat
wscat -c ws://YOUR_SERVER_IP:8080/ws
```

---

## Низкая производительность

### Симптомы
- Медленные ответы API
- Высокая загрузка CPU/RAM
- Таймауты

### Решение

```bash
# 1. Проверить ресурсы
docker stats

# 2. Проверить логи на ошибки
docker-compose -f docker-compose.prod.yml logs -f

# 3. Оптимизировать БД (создать индексы)
docker exec -it bus-tracking-db-prod psql -U bususer -d bus_tracking
# В psql:
# REINDEX DATABASE bus_tracking;
# VACUUM ANALYZE;

# 4. Увеличить ресурсы в docker-compose.prod.yml
nano docker-compose.prod.yml
# Добавить в каждый сервис:
# resources:
#   limits:
#     memory: 2G
```

---

# ОБСЛУЖИВАНИЕ

## Регулярные задачи

### Ежедневно (автоматически)

- ✅ Автоматические бэкапы БД (через cron)
- ✅ Ротация логов Docker

### Еженедельно (вручную)

```bash
# Проверка логов на ошибки
docker-compose -f docker-compose.prod.yml logs --since 7d | grep -i error

# Проверка использования диска
df -h
docker system df

# Проверка статуса сервисов
docker-compose -f docker-compose.prod.yml ps

# Проверка бэкапов
ls -lh /opt/backups/ | tail -7
```

### Ежемесячно

```bash
# Обновление системы
sudo apt update
sudo apt upgrade -y

# Обновление Docker образов
cd /opt/bus-tracking
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# Продление SSL (Let's Encrypt)
sudo certbot renew

# Очистка старых Docker образов
docker system prune -a --volumes -f

# Проверка бэкапов (тест восстановления)
# Создайте тестовую БД и восстановите последний бэкап
```

### Ежеквартально

```bash
# Аудит безопасности
# Проверьте все пункты из Чеклиста безопасности

# Обновление паролей (если требуется)
./generate-secrets.sh

# Проверка SSL сертификата
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Disaster recovery drill
# Попробуйте полностью восстановить систему из бэкапа на тестовом сервере
```

---

## Обновление приложения

### Обновление с новой версией

```bash
cd /opt/bus-tracking

# Сохранить текущую конфигурацию
cp .env.production.local .env.production.local.backup

# Получить новый код
git pull origin main
# Или загрузить новые файлы через scp

# Восстановить конфигурацию если перезаписалась
cp .env.production.local.backup .env.production.local

# Пересобрать и перезапустить
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

# Проверить
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

---

## Масштабирование

### Увеличение ресурсов

Отредактируйте `docker-compose.prod.yml`:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G
```

### Горизонтальное масштабирование

Для высоких нагрузок рассмотрите:
- Load balancer (nginx/HAProxy)
- Несколько backend инстансов
- Отдельный сервер для БД
- Redis для кэширования
- CDN для статики

---

# ПОЛЕЗНАЯ ИНФОРМАЦИЯ

## Структура проекта

```
/opt/bus-tracking/
├── backend/              # Go backend
│   ├── Dockerfile
│   ├── Dockerfile.prod
│   └── main.go
├── admin-panel/          # React админ-панель
│   ├── Dockerfile
│   ├── nginx.conf
│   └── nginx.prod.conf
├── bus/                  # React Native приложение
│   └── config.js
├── ssl/                  # SSL сертификаты
│   ├── fullchain.pem
│   └── privkey.pem
├── .env                  # Development конфигурация
├── .env.production.local # Production конфигурация (НЕ в Git!)
├── docker-compose.yml    # Development
├── docker-compose.prod.yml # Production
├── generate-secrets.sh   # Генератор паролей
└── deploy-production.sh  # Скрипт развёртывания
```

## Порты

- **80** - HTTP (админ-панель)
- **443** - HTTPS (админ-панель)
- **8080** - Backend API (внутренний)
- **5432** - PostgreSQL (внутренний)

## Переменные окружения

### Обязательные

- `POSTGRES_PASSWORD` - Пароль БД
- `JWT_SECRET` - Секрет для JWT токенов
- `ALLOWED_ORIGINS` - Разрешённые домены для CORS

### Опциональные

- `PORT` - Порт backend (по умолчанию 8080)
- `DB_HOST` - Хост БД (по умолчанию postgres)
- `ENVIRONMENT` - Окружение (development/production)

## Логи и мониторинг

### Расположение логов

```bash
# Docker логи
/var/lib/docker/containers/

# Логи бэкапов
/var/log/backup.log

# Системные логи
/var/log/syslog
/var/log/auth.log
```

### Полезные команды мониторинга

```bash
# Топ процессов
htop

# Использование сети
iftop

# Использование диска
ncdu /

# Системный мониторинг
dstat
```

---

# КОНТАКТЫ И ПОДДЕРЖКА

## Документация проекта

- **Этот файл** - Всё что нужно знать
- **README.md** - Общая информация
- **API.md** - Документация API (если есть)

## Команда для связи

При возникновении проблем:

1. Проверьте раздел "Проблемы" выше
2. Посмотрите логи: `docker-compose -f docker-compose.prod.yml logs -f`
3. Проверьте статус: `docker-compose -f docker-compose.prod.yml ps`

## Полезные ссылки

- Docker: https://docs.docker.com/
- Let's Encrypt: https://letsencrypt.org/
- PostgreSQL: https://www.postgresql.org/docs/
- Go: https://golang.org/doc/
- React: https://reactjs.org/docs/
- React Native: https://reactnative.dev/docs/

---

# ФИНАЛЬНЫЙ ЧЕКЛИСТ

После развёртывания убедитесь:

- [ ] ✅ Все контейнеры запущены
- [ ] ✅ Backend отвечает на /api/health
- [ ] ✅ Админ-панель открывается
- [ ] ✅ Можно войти под администратором
- [ ] ✅ SSL работает (если используется)
- [ ] ✅ CORS настроен правильно
- [ ] ✅ Все пароли изменены
- [ ] ✅ Автоматические бэкапы настроены
- [ ] ✅ Файрвол настроен
- [ ] ✅ Мобильное приложение подключается

---

**🎉 Поздравляю! Система успешно развёрнута и готова к работе!**

Сохраните этот файл - в нём есть всё необходимое для работы с системой.
