# Архитектура системы отслеживания университетских автобусов

## Обзор системы

Система состоит из трех основных компонентов, работающих в связке для обеспечения real-time отслеживания автобусов:

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│                 │         │                 │         │                 │
│  Admin Panel    │◄────────┤   Backend API   │────────►│  Mobile App     │
│  (React Web)    │         │   (Go/WebSocket)│         │  (React Native) │
│                 │         │                 │         │                 │
└─────────────────┘         └────────┬────────┘         └─────────────────┘
                                     │
                                     │
                            ┌────────▼────────┐
                            │                 │
                            │   PostgreSQL    │
                            │    Database     │
                            │                 │
                            └─────────────────┘
```

## Компоненты системы

### 1. Backend (Go)

**Технологии:**
- Go 1.21+
- Gorilla WebSocket для real-time коммуникации
- Gorilla Mux для роутинга
- JWT для аутентификации
- PostgreSQL для хранения данных

**Основные модули:**
- `main.go` - Точка входа, инициализация сервера
- `handlers/` - HTTP обработчики запросов
- `websocket/` - WebSocket hub и клиенты
- `database/` - Работа с БД, миграции
- `models/` - Модели данных

**Поток данных:**
1. Клиент отправляет HTTP запрос
2. Middleware проверяет JWT токен
3. Handler обрабатывает запрос
4. Данные сохраняются в PostgreSQL
5. Обновления транслируются через WebSocket

**WebSocket Architecture:**
```
Hub (центральный узел)
├── Clients (подключенные клиенты)
├── Broadcast channel (канал для рассылки)
├── Register channel (регистрация клиентов)
└── Unregister channel (отключение клиентов)
```

### 2. Admin Panel (React)

**Технологии:**
- React 18
- React Router для навигации
- Axios для HTTP запросов
- CSS для стилизации

**Страницы:**
- `/` - Вход для админа
- `/dashboard` - Панель управления
  - Вкладка студентов
  - Вкладка водителей
  - Модальные окна для создания

**Функционал:**
- Аутентификация админа
- CRUD операции для студентов
- CRUD операции для водителей
- Просмотр списков пользователей

### 3. Mobile App (React Native)

**Технологии:**
- React Native 0.81
- Expo SDK 54
- React Navigation для навигации
- React Native Maps для карт
- Expo Location для геолокации
- WebSocket для real-time

**Навигация:**
```
App
├── Login Screen
├── Student Tabs
│   ├── Map Screen (карта с автобусами)
│   └── Profile Screen
└── Driver Tabs
    ├── Map Screen (карта с водителями)
    └── Profile Screen
```

**Геолокация:**
- Запрос разрешений при входе
- Отслеживание позиции каждую секунду
- Автоматическая отправка на сервер
- Плавное обновление на карте

### 4. Database (PostgreSQL)

**Схема:**

```sql
users
├── id (SERIAL PRIMARY KEY)
├── university_id (VARCHAR UNIQUE)
├── password_hash (VARCHAR)
├── first_name (VARCHAR)
├── last_name (VARCHAR)
├── middle_name (VARCHAR, nullable)
├── user_type (VARCHAR: student/driver/admin)
├── latitude (DOUBLE PRECISION, nullable)
├── longitude (DOUBLE PRECISION, nullable)
├── last_location_update (TIMESTAMP)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)
```

**Индексы:**
- `idx_users_university_id` - Быстрый поиск по ID
- `idx_users_type` - Фильтрация по типу
- `idx_users_location` - Геопространственные запросы

## Потоки данных

### 1. Аутентификация

```
Mobile App/Admin Panel
    │
    ├─► POST /api/auth/login
    │   {university_id, password}
    │
Backend
    │
    ├─► Проверка в БД
    ├─► bcrypt.Compare
    ├─► Генерация JWT
    │
    └─► Response {token, user_type, user}
```

### 2. Real-time обновление координат

```
Mobile App (Driver)
    │
    ├─► Watch Location (каждую секунду)
    │
    ├─► POST /api/users/location
    │   {latitude, longitude}
    │
Backend
    │
    ├─► UPDATE users SET latitude, longitude
    │
    ├─► Broadcast через WebSocket Hub
    │
    └─► WebSocket → Все подключенные клиенты
              │
              ├─► Student App (обновление карты)
              └─► Driver App (обновление других водителей)
```

### 3. Создание пользователя

```
Admin Panel
    │
    ├─► POST /api/admin/students
    │   {university_id, password, first_name, ...}
    │
Backend
    │
    ├─► Проверка JWT (admin?)
    ├─► bcrypt.Hash(password)
    ├─► INSERT INTO users
    │
    └─► Response {message: "success"}
```

## Безопасность

### Аутентификация и авторизация
- JWT токены с 24-часовым сроком действия
- Пароли хешируются через bcrypt (cost: 10)
- Middleware для проверки токенов
- Разделение прав: admin/driver/student

### Защита данных
- HTTPS для production (через nginx)
- CORS настроен для известных origin
- SQL prepared statements (защита от SQL injection)
- Валидация входных данных

### Геолокация
- Запрос разрешений у пользователя
- Студенты видят только водителей
- Водители видят только других водителей
- Координаты студентов не транслируются

## Масштабирование

### Горизонтальное масштабирование Backend
1. Load Balancer (nginx)
2. Несколько инстансов backend
3. Redis для сессий и кеширования
4. PostgreSQL репликация (master-slave)

### WebSocket масштабирование
- Redis Pub/Sub для синхронизации между инстансами
- Sticky sessions на load balancer
- Отдельный WebSocket сервер

### Database оптимизация
- Индексы на часто используемые поля
- Партиционирование по user_type
- Архивация старых данных
- Connection pooling

## Мониторинг и логирование

### Метрики
- Количество активных WebSocket соединений
- Средняя задержка обновления координат
- Количество запросов в секунду
- Нагрузка на БД

### Логирование
- Уровни: INFO, WARNING, ERROR
- Централизованное логирование (ELK stack)
- Логи аутентификации
- Логи ошибок WebSocket

## Deployment

### Development
```bash
# Backend
cd backend && go run main.go

# Admin Panel
cd admin-panel && npm start

# Mobile App
cd bus && npx expo start
```

### Production (Docker)
```bash
docker-compose up -d
```

**Контейнеры:**
1. `postgres` - База данных
2. `backend` - Go API + WebSocket
3. `admin-panel` - React статика на nginx

### CI/CD Pipeline
```
GitHub Actions
    │
    ├─► Тесты (Go test, Jest)
    ├─► Сборка Docker образов
    ├─► Push в Docker Registry
    ├─► Deploy на сервер
    └─► Health check
```

## Будущие улучшения

1. **Маршруты автобусов** - Предопределенные маршруты на карте
2. **Расписание** - Время прибытия на остановки
3. **Уведомления** - Push notifications о приближении автобуса
4. **Аналитика** - Статистика движения, популярные маршруты
5. **Чат** - Коммуникация водитель-студент
6. **Рейтинги** - Оценка водителей студентами
7. **Интеграция с университетской системой** - SSO авторизация
8. **Оффлайн режим** - Кеширование данных
9. **История поездок** - Логи перемещений
10. **Admin dashboard** - Графики и статистика в реальном времени
