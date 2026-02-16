# 🎯 БЫСТРЫЙ СТАРТ - NGROK

## 1️⃣ ПЕРВЫЙ РАЗ (только один раз!)

### a) Зарегистрируйтесь:
👉 https://dashboard.ngrok.com/signup

### b) Добавьте токен:
```cmd
setup-ngrok.bat
```
Вставьте токен, который скопировали с сайта.

---

## 2️⃣ КАЖДЫЙ ДЕНЬ (обычная работа)

### ВАРИАНТ А - Автоматический (РЕКОМЕНДУЕТСЯ):
```cmd
start-all.bat
```
Запустит ВСЁ автоматически: Docker, Ngrok, обновит config.js, запустит Metro!

### ВАРИАНТ Б - Пошагово:

**Шаг 1:** Запустите Docker
```cmd
docker-compose up -d
```

**Шаг 2:** Запустите Ngrok
```cmd
start-ngrok.bat
```

**Шаг 3:** Обновите config.js
```cmd
update-config.bat
```

**Шаг 4:** Запустите приложение
```cmd
cd bus
npm start
```

---

## 3️⃣ СОЗДАНИЕ APK

```bash
cd bus
npx eas build --platform android --profile preview
```

---

## 📱 ПОЛЕЗНЫЕ ССЫЛКИ

После запуска откройте:

- **Ngrok Dashboard:** http://localhost:4040
  _(смотрите все запросы в реальном времени)_

- **Admin Panel:** http://localhost:3001
  _(управление пользователями)_

- **Backend Health:** https://ВАШ-URL.ngrok-free.dev/api/health
  _(проверка работы через HTTPS)_

---

## 🆘 ПРОБЛЕМЫ?

### ❌ "URL изменился!"
После перезапуска ngrok:
```cmd
update-config.bat
```

### ❌ "Страница предупреждения ngrok"
Добавьте authtoken:
```cmd
setup-ngrok.bat
```

### ❌ "Connection refused"
Запустите Docker:
```cmd
docker-compose up -d
```

---

## 📦 СОЗДАННЫЕ ФАЙЛЫ

✅ `ngrok.exe` - программа ngrok
✅ `setup-ngrok.bat` - настройка токена (1 раз)
✅ `start-ngrok.bat` - запуск ngrok
✅ `update-config.bat` - обновление config.js
✅ `start-all.bat` - запуск ВСЕГО (рекомендуется)
✅ `NGROK_README_RU.md` - подробная инструкция

---

## ⚡ ТРИ КОМАНДЫ ДЛЯ РАБОТЫ

```cmd
# 1. Первый раз (добавить токен):
setup-ngrok.bat

# 2. Каждый день (запустить всё):
start-all.bat

# 3. Создать APK:
cd bus && npx eas build --platform android
```

**Вот и всё! Удачи! 🚀**
