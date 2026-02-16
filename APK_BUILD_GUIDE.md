# 📱 Руководство по созданию APK

## Перед началом

### 1. Установите EAS CLI (один раз)

```bash
npm install -g eas-cli
```

### 2. Войдите в Expo аккаунт

```bash
eas login
```

---

## 🔧 Подготовка к build

### Шаг 1: Обновите конфигурацию для production

**Откройте `bus/config.prod.js`** и обновите URL на ваш production сервер:

```javascript
const PRODUCTION_API_URL = 'https://ваш-сервер.com/api';
const PRODUCTION_WS_URL = 'wss://ваш-сервер.com/ws';
```

**Или используйте ngrok** (если сервер ещё не готов):

```javascript
const PRODUCTION_API_URL = 'https://ваш-ngrok-url.ngrok-free.dev/api';
const PRODUCTION_WS_URL = 'wss://ваш-ngrok-url.ngrok-free.dev/ws';
```

### Шаг 2: Обновите config.js для использования production

**Откройте `bus/config.js`** и импортируйте production config:

```javascript
// Временно для build (потом верните обратно!)
export * from './config.prod.js';
```

### Шаг 3: Обновите версию приложения

**Откройте `bus/app.json`** и увеличьте версию:

```json
{
  "expo": {
    "version": "1.0.1",  // <- Увеличьте версию
    "android": {
      "versionCode": 2   // <- Увеличьте versionCode
    }
  }
}
```

---

## 🚀 Сборка APK

### Вариант 1: APK для тестирования (быстро, можно сразу установить)

```bash
cd bus
eas build -p android --profile preview
```

⏳ **Ожидайте 10-20 минут**

После завершения вы получите ссылку на скачивание APK!

### Вариант 2: AAB для Google Play Store (для публикации)

```bash
cd bus
eas build -p android --profile production
```

---

## 📥 Установка APK на телефон

### После успешной сборки:

1. **Скачайте APK** по ссылке которую дал EAS
2. **Отправьте APK на телефон** (через Telegram, WhatsApp, email)
3. **На Android телефоне**:
   - Откройте файл APK
   - Разрешите установку из неизвестных источников (если попросит)
   - Нажмите "Установить"

---

## ⚠️ Важно после build!

### Верните config.js обратно для разработки:

**Откройте `bus/config.js`** и уберите импорт production:

```javascript
// Вернуть для разработки:
const API_URL = NGROK_API_URL;  // или LOCAL_API_URL
const WS_URL = NGROK_WS_URL;    // или LOCAL_WS_URL
export { API_URL, WS_URL };
```

---

## 🔍 Проверка перед build

Убедитесь что:

- [ ] ✅ Backend запущен и доступен
- [ ] ✅ URL в `config.prod.js` правильные
- [ ] ✅ Все пользователи в БД имеют пароли
- [ ] ✅ Версия приложения обновлена
- [ ] ✅ Вы вошли в EAS: `eas whoami`

---

## 🐛 Решение проблем

### Ошибка: "Gradle build failed"

```bash
# Очистите кэш
cd bus
rm -rf node_modules
npm install
```

### Ошибка: "Invalid credentials"

```bash
# Перезайдите
eas logout
eas login
```

### Ошибка: "Project not configured"

```bash
# Настройте проект
cd bus
eas build:configure
```

### APK не устанавливается на телефон

- Проверьте что разрешена установка из неизвестных источников
- Удалите старую версию приложения (если есть)
- Проверьте что хватает места на телефоне

---

## 📱 Первый запуск APK

После установки APK:

1. **Откройте приложение**
2. **Разрешите доступ к геолокации**
3. **Войдите с тестовым аккаунтом**:
   - **Студент**: 
     - University ID: `STU001`
     - Password: `password123`
   - **Водитель**:
     - University ID: `DRV001`
     - Password: `password123`

4. **Проверьте что карта загружается**
5. **Проверьте что координаты обновляются**

---

## 🎯 Чеклист для production

Перед публикацией в Google Play:

- [ ] ✅ Замените ngrok на постоянный сервер
- [ ] ✅ Настройте HTTPS на сервере
- [ ] ✅ Измените пароли студентов/водителей
- [ ] ✅ Обновите иконки приложения
- [ ] ✅ Протестируйте на нескольких устройствах
- [ ] ✅ Проверьте работу в фоновом режиме
- [ ] ✅ Добавьте Google Maps API ключ (для Android)

---

## 🔑 Добавление Google Maps API Key (опционально)

Если используете Google Maps вместо Yandex:

1. Получите API ключ: https://console.cloud.google.com/
2. Добавьте в `app.json`:

```json
{
  "android": {
    "config": {
      "googleMaps": {
        "apiKey": "ВАШ_API_КЛЮЧ"
      }
    }
  }
}
```

---

## 📞 Полезные команды

```bash
# Проверить статус build
eas build:list

# Посмотреть логи последнего build
eas build:view

# Проверить конфигурацию
eas build:configure

# Создать preview build с автоматической установкой
eas build -p android --profile preview --auto-submit
```

---

**Готово!** 🎉

Теперь у вас есть APK который можно установить на любой Android телефон и использовать без Expo Go!
