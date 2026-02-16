# API Documentation

## Базовый URL
```
http://localhost:8080/api
```

## Аутентификация

### Login
**POST** `/auth/login`

Вход в систему для всех типов пользователей.

**Request Body:**
```json
{
  "university_id": "STUDENT001",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user_type": "student",
  "user": {
    "id": 1,
    "university_id": "STUDENT001",
    "first_name": "Иван",
    "last_name": "Иванов",
    "middle_name": "Иванович",
    "user_type": "student",
    "created_at": "2026-02-11T10:00:00Z"
  }
}
```

## Admin Endpoints

### Create Student
**POST** `/admin/students`

Создание нового студента (только для админов).

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "university_id": "STUDENT001",
  "password": "password123",
  "first_name": "Иван",
  "last_name": "Иванов",
  "middle_name": "Иванович"
}
```

**Response:**
```json
{
  "message": "Student created successfully"
}
```

### Get All Students
**GET** `/admin/students`

Получить список всех студентов.

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": 1,
    "university_id": "STUDENT001",
    "first_name": "Иван",
    "last_name": "Иванов",
    "middle_name": "Иванович",
    "user_type": "student"
  }
]
```

### Create Driver
**POST** `/admin/drivers`

Создание нового водителя (только для админов).

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "university_id": "DRIVER001",
  "password": "password123",
  "first_name": "Петр",
  "last_name": "Петров",
  "middle_name": "Петрович"
}
```

### Get All Drivers
**GET** `/admin/drivers`

Получить список всех водителей с их координатами.

**Response:**
```json
[
  {
    "id": 2,
    "university_id": "DRIVER001",
    "first_name": "Петр",
    "last_name": "Петров",
    "latitude": 55.7558,
    "longitude": 37.6173,
    "last_location_update": "2026-02-11T15:30:00Z"
  }
]
```

## User Endpoints

### Get Profile
**GET** `/users/profile?user_id={id}`

Получить профиль текущего пользователя.

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "id": 1,
  "university_id": "STUDENT001",
  "first_name": "Иван",
  "last_name": "Иванов",
  "middle_name": "Иванович",
  "user_type": "student",
  "latitude": 55.7558,
  "longitude": 37.6173
}
```

### Update Location
**POST** `/users/location?user_id={id}`

Обновить геолокацию пользователя.

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "latitude": 55.7558,
  "longitude": 37.6173
}
```

**Response:**
```json
{
  "message": "Location updated successfully"
}
```

### Get Drivers Locations
**GET** `/users/drivers-locations`

Получить текущие координаты всех водителей.

**Response:**
```json
[
  {
    "user_id": 2,
    "university_id": "DRIVER001",
    "first_name": "Петр",
    "last_name": "Петров",
    "user_type": "driver",
    "latitude": 55.7558,
    "longitude": 37.6173,
    "timestamp": 1707663000
  }
]
```

## WebSocket

### Connect to WebSocket
**WS** `/ws`

Подключение для получения real-time обновлений координат.

**Message Format (Server -> Client):**
```json
{
  "user_id": 2,
  "university_id": "DRIVER001",
  "first_name": "Петр",
  "last_name": "Петров",
  "user_type": "driver",
  "latitude": 55.7558,
  "longitude": 37.6173,
  "timestamp": 1707663000
}
```

Сообщения отправляются автоматически каждый раз, когда водитель или студент обновляет свою геолокацию.

## Error Responses

### 400 Bad Request
```json
{
  "error": "Invalid request"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid credentials"
}
```

### 404 Not Found
```json
{
  "error": "User not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Database error"
}
```

## Rate Limiting

В текущей версии rate limiting не реализован. Для production рекомендуется добавить:
- Лимит на количество запросов в минуту
- Защита от DDoS атак
- Throttling для WebSocket соединений
