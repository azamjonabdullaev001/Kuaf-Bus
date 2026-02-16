# Система отслеживания университетских автобусов

Полнофункциональная система real-time отслеживания автобусов для университета с административной панелью и мобильным приложением.

## 🚀 Технологический стек

- **Backend**: Go (Golang) с WebSocket для real-time обновлений
- **Frontend (Админ-панель)**: React
- **Mobile App**: React Native (Expo)
- **Database**: PostgreSQL
- **Deployment**: Docker & Docker Compose

---

## 📦 Production развёртывание

### 📖 **[PRODUCTION_GUIDE.md](PRODUCTION_GUIDE.md)** ← ВСЁ ЧТО НУЖНО В ОДНОМ ФАЙЛЕ!

**Полное руководство включает:**
- ✅ Пошаговую инструкцию развёртывания
- ✅ Все необходимые команды
- ✅ Настройку безопасности
- ✅ Чеклист готовности
- ✅ Решение всех проблем
- ✅ Регулярное обслуживание

### ⚡ Быстрый старт (для опытных):

```bash
# 1. Генерация паролей
./generate-secrets.sh

# 2. Развёртывание
./deploy-production.sh
```

⚠️ **Важно**: Все пароли ОБЯЗАТЕЛЬНО изменить! См. [PRODUCTION_GUIDE.md](PRODUCTION_GUIDE.md)

---

## 📋 Возможности

### Административная панель (React Web)
- ✅ Добавление студентов в систему
- ✅ Добавление водителей автобусов
- ✅ Просмотр всех пользователей
- ✅ Управление доступами

### Мобильное приложение (React Native)

#### Для студентов:
- ✅ Вход через университетский ID (без регистрации)
- ✅ Просмотр профиля
- ✅ Real-time карта с автобусами
- ✅ Собственная геолокация
- ✅ Плавное обновление координат каждую секунду

#### Для водителей:
- ✅ Вход через университетский ID
- ✅ Просмотр профиля
- ✅ Real-time карта с другими водителями
- ✅ Отслеживание собственной позиции
- ✅ Автоматическая передача координат

## 🛠️ Установка и запуск

### Предварительные требования
- Docker и Docker Compose
- Node.js 18+ (для разработки)
- Go 1.21+ (для разработки backend)
- Expo CLI (для React Native приложения)

### Быстрый старт с Docker

1. **Клонируйте репозиторий и перейдите в директорию проекта**

2. **Запустите все сервисы:**
```bash
docker-compose up -d
```

3. **Доступ к сервисам:**
- Админ-панель: http://localhost:3001
- Backend API: http://localhost:8080
- PostgreSQL: localhost:5433
- Mobile App: используйте IP `192.168.213.21` (см. [NETWORK_CONFIG.md](NETWORK_CONFIG.md))

4. **Учетные данные по умолчанию (админ):**
- University ID: `ADMIN001`
- Password: `admin123`

**Важно для мобильного приложения:** Компьютер и телефон должны быть в одной WiFi сети!

### Запуск для разработки

#### Backend (Go)
```bash
cd backend
go mod download
go run main.go
```

#### Админ-панель (React)
```bash
cd admin-panel
npm install
npm start
```

#### Мобильное приложение (React Native)
```bash
cd bus
npm install
npx expo start
```

**Важно:** React Native приложение настроено на IP адрес `192.168.213.21`. 
Если ваш IP отличается, обновите файл `bus/config.js`:
```javascript
const API_URL = 'http://ВАШ_IP:8080/api';
```

Узнать ваш IP:
```bash
ipconfig  # Windows
ifconfig  # Mac/Linux
```

Подробнее: см. [NETWORK_CONFIG.md](NETWORK_CONFIG.md)

## 📱 Структура проекта

```
bus-tracking/
├── backend/              # Go backend с WebSocket
│   ├── main.go
│   ├── handlers/         # HTTP handlers
│   ├── websocket/        # WebSocket реализация
│   ├── database/         # Работа с БД
│   ├── models/           # Модели данных
│   └── Dockerfile
├── admin-panel/          # React админ-панель
│   ├── src/
│   │   ├── pages/        # Страницы
│   │   └── services/     # API сервисы
│   ├── Dockerfile
│   └── nginx.conf
├── bus/                  # React Native приложение
│   ├── screens/          # Экраны приложения
│   ├── navigation/       # Навигация
│   ├── services/         # API и WebSocket
│   └── App.js
├── docker-compose.yml    # Docker Compose конфигурация
└── init-db.sql          # Начальная схема БД
```

## 🔧 Конфигурация

### Переменные окружения Backend (.env)
```env
PORT=8080
DB_HOST=postgres
DB_PORT=5432
DB_USER=bususer
DB_PASSWORD=buspassword
DB_NAME=bus_tracking
JWT_SECRET=your-super-secret-jwt-key
```

### API Endpoints

#### Аутентификация
- `POST /api/auth/login` - Вход в систему

#### Админ (требуется аутентификация)
- `POST /api/admin/students` - Создать студента
- `GET /api/admin/students` - Все студенты
- `POST /api/admin/drivers` - Создать водителя
- `GET /api/admin/drivers` - Все водители

#### Пользователи (требуется аутентификация)
- `GET /api/users/profile` - Профиль пользователя
- `POST /api/users/location` - Обновить геолокацию
- `GET /api/users/drivers-locations` - Координаты водителей

#### WebSocket
- `WS /ws` - Real-time обновления координат

## 🔐 Безопасность

- JWT токены для аутентификации
- Пароли хешируются через bcrypt
- CORS настроен для безопасности
- Нет самостоятельной регистрации - только через админ-панель

## 🌐 Real-time возможности

- WebSocket соединение для мгновенных обновлений
- Обновление координат каждую секунду
- Плавное перемещение маркеров на карте
- Минимальная задержка между клиентами

## 📊 База данных

### Таблица users
- `id` - Уникальный идентификатор
- `university_id` - ID студента/водителя от университета
- `password_hash` - Хеш пароля
- `first_name` - Имя
- `last_name` - Фамилия
- `middle_name` - Отчество (опционально)
- `user_type` - Тип: student/driver/admin
- `latitude`, `longitude` - Координаты
- `last_location_update` - Время последнего обновления

## 🚦 Запуск в production

1. Измените JWT_SECRET в .env
2. Настройте SSL сертификаты
3. Измените пароли БД
4. Настройте firewall правила
5. Используйте reverse proxy (nginx)

## 📝 Лицензия

MIT License

## 👨‍💻 Разработка

Проект создан для университета для отслеживания автобусов в реальном времени.

### Основные особенности реализации:
- Архитектура микросервисов
- Real-time через WebSocket
- Оптимизация для mobile устройств
- Плавные анимации координат
- Высокая производительность
