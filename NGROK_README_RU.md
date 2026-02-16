# 🚀 Настройка NGROK для создания APK

## Почему нужен NGROK?

Android и iOS **не разрешают HTTP запросы** по соображениям безопасности. Нужен HTTPS!

Ngrok создаёт бесплатный HTTPS туннель к вашему локальному серверу.

---

## ✅ Быстрая настройка (5 минут)

### Шаг 1: Регистрация в ngrok (ОБЯЗАТЕЛЬНО!)

1. Откройте: **https://dashboard.ngrok.com/signup**
2. Зарегистрируйтесь через Google/GitHub (30 секунд)
3. Скопируйте **Authtoken**: https://dashboard.ngrok.com/get-started/your-authtoken

### Шаг 2: Добавьте токен

**Вариант А (просто):**
```cmd
setup-ngrok.bat
```
Вставьте токен, когда скрипт попросит.

**Вариант Б (вручную):**
```cmd
ngrok.exe config add-authtoken ВАШ_ТОКЕН_ЗДЕСЬ
```

### Шаг 3: Запустите ngrok

**Вариант А (просто):**
```cmd
start-ngrok.bat
```

**Вариант Б (вручную):**
```cmd
ngrok.exe http 8080
```

Вы увидите что-то вроде:
```
Forwarding: https://abc-def-ghi.ngrok-free.dev -> http://localhost:8080
```

### Шаг 4: Скопируйте URL

Скопируйте HTTPS URL (например: `https://abc-def-ghi.ngrok-free.dev`)

### Шаг 5: Обновите config.js

Откройте `bus/config.js` и замените URL:

```javascript
const API_URL = 'https://ВАШ-URL.ngrok-free.dev/api';
const WS_URL = 'wss://ВАШ-URL.ngrok-free.dev/ws';
```

### Шаг 6: Проверьте работу

Откройте в браузере:
```
https://ВАШ-URL.ngrok-free.dev/api/health
```

Должен быть ответ от сервера!

---

## 📱 Теперь можно создавать APK!

```bash
cd bus
npx eas build --platform android --profile preview
```

---

## 💡 Полезные команды

### Получить текущий URL ngrok:
```powershell
(Invoke-RestMethod http://localhost:4040/api/tunnels).tunnels[0].public_url
```

### Посмотреть все запросы:
Откройте в браузере: **http://localhost:4040**

### Остановить ngrok:
Нажмите `Ctrl+C` в окне ngrok или:
```powershell
Stop-Process -Name ngrok
```

---

## ⚠️ ВАЖНО

### URL меняется!
При каждом перезапуске ngrok URL меняется. Нужно обновлять `config.js`!

### Решение 1: Платная версия ($8/мес)
- Фиксированный URL
- Без лимитов

### Решение 2: Держите ngrok запущенным
Просто не перезапускайте ngrok = URL не меняется

---

## 🆘 Проблемы?

### "ERR_NGROK_6024" - Страница предупреждения
❌ Проблема: Не добавлен authtoken

✅ Решение: Запустите `setup-ngrok.bat` и добавьте токен

### "Connection refused"
❌ Проблема: Backend не запущен

✅ Решение: 
```cmd
docker-compose up -d
```

### "tunnel not found"
❌ Проблема: Ngrok не запущен

✅ Решение:
```cmd
start-ngrok.bat
```

---

## 📊 Текущий статус

✅ Ngrok установлен в: `D:\app\kuaf bus\ngrok.exe`
✅ Скрипты готовы:
   - `setup-ngrok.bat` - добавить токен
   - `start-ngrok.bat` - запустить туннель

📝 Следующие шаги:
1. ⬜ Зарегистрироваться на ngrok.com
2. ⬜ Добавить authtoken
3. ⬜ Запустить ngrok
4. ⬜ Обновить config.js
5. ⬜ Создать APK

---

## 🎓 Как это работает?

```
Ваш телефон
    ↓ HTTPS
Ngrok Cloud (https://abc.ngrok-free.dev)
    ↓ HTTP
Ваш компьютер (localhost:8080)
    ↓
Docker Backend
```

Ngrok принимает HTTPS запросы и перенаправляет их на ваш локальный HTTP сервер!

---

## 📚 Дополнительно

- Документация: https://ngrok.com/docs
- Dashboard: https://dashboard.ngrok.com
- Поддержка: https://ngrok.com/support

**Удачи с APK! 🚀**
