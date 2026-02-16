# Руководство по использованию ngrok

## Что такое ngrok?
Ngrok создаёт защищённый HTTPS туннель к вашему локальному серверу. Это необходимо для:
- Создания APK файла (Android требует HTTPS)
- Тестирования на iOS (требует HTTPS)
- Доступа к серверу извне

## 1. Запуск ngrok

### Первый раз:
```powershell
.\ngrok.exe http 8080
```

Ngrok запустится и покажет URL:
```
Forwarding: https://your-url.ngrok-free.dev -> http://localhost:8080
```

### Получить текущий URL:
```powershell
(Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels").tunnels | Select-Object -First 1 | ForEach-Object { $_.public_url }
```

## 2. Обновление config.js

После запуска ngrok скопируйте URL и обновите `bus/config.js`:

```javascript
const API_URL = 'https://your-url.ngrok-free.dev/api';
const WS_URL = 'wss://your-url.ngrok-free.dev/ws';
```

**⚠️ ВАЖНО**: При каждом перезапуске ngrok URL меняется!

## 3. Проверка работы

Откройте в браузере:
```
https://your-url.ngrok-free.dev/api/health
```

Если видите ответ от сервера - всё работает!

## 4. Создание APK

Теперь можно создавать APK:
```powershell
cd bus
npx eas build --platform android --profile preview
```

## 5. Команды

### Запустить ngrok в фоне:
```powershell
Start-Process -FilePath ".\ngrok.exe" -ArgumentList "http 8080" -WindowStyle Hidden
```

### Остановить ngrok:
```powershell
Stop-Process -Name "ngrok"
```

### Проверить статус:
```powershell
Get-Process ngrok -ErrorAction SilentlyContinue
```

## 6. Ngrok Dashboard

Откройте в браузере: http://localhost:4040

Здесь вы увидите:
- Текущий URL
- Все запросы в реальном времени
- Детали каждого запроса

## 7. Бесплатная vs Платная версия

**Бесплатная версия:**
- ✅ HTTPS туннель
- ✅ 1 туннель одновременно
- ❌ URL меняется при перезапуске
- ❌ Срок жизни: 2 часа

**Платная версия ($8/месяц):**
- ✅ Фиксированный URL (custom subdomain)
- ✅ Несколько туннелей
- ✅ Без ограничений по времени

## 8. Регистрация (опционально)

Для увеличения лимитов зарегистрируйтесь на https://ngrok.com:

```powershell
.\ngrok.exe config add-authtoken YOUR_TOKEN
```

## Текущий статус

✅ Ngrok установлен: `D:\app\kuaf bus\ngrok.exe`
✅ Запущен на порту: 8080
✅ HTTPS URL: https://debbra-coralloid-detractively.ngrok-free.dev
✅ Dashboard: http://localhost:4040

## Быстрый старт

1. Убедитесь, что backend запущен:
   ```powershell
   docker-compose ps
   ```

2. Запустите ngrok (если ещё не запущен):
   ```powershell
   .\ngrok.exe http 8080
   ```

3. Проверьте config.js - URL должен совпадать с ngrok

4. Перезапустите React Native:
   ```powershell
   cd bus
   npm start
   ```

5. Теперь можно собирать APK или тестировать на телефоне!
