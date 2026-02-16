# Конфигурация для разработки

## Настройка IP адреса для React Native

### Автоматическое определение IP
React Native приложение автоматически использует IP адрес компьютера из Expo Dev Server.

### Ручная настройка (если требуется)

1. **Узнайте IP адрес вашего компьютера:**

Windows:
```bash
ipconfig
```
Найдите "IPv4 Address" вашего WiFi адаптера.

Mac/Linux:
```bash
ifconfig
```

2. **Обновите файл `bus/config.js`:**

```javascript
const API_URL = 'http://ВАШ_IP:8080/api';
const WS_URL = 'ws://ВАШ_IP:8080/ws';
```

Пример (текущая конфигурация):
```javascript
const API_URL = 'http://192.168.213.21:8080/api';
const WS_URL = 'ws://192.168.213.21:8080/ws';
```

3. **Перезапустите Expo:**
```bash
# Ctrl+C чтобы остановить
npx expo start --clear
```

## Проверка подключения

### Тест Backend API:
```bash
# С компьютера (localhost)
curl http://localhost:8080/api/admin/students

# С телефона через WiFi
curl http://192.168.213.21:8080/api/admin/students
```

### Требования:
- ✅ Компьютер и телефон должны быть в одной WiFi сети
- ✅ Firewall не должен блокировать порт 8080
- ✅ Docker контейнеры запущены

### Решение проблем:

**Если приложение не подключается:**

1. Проверьте, что Backend работает:
```bash
docker-compose ps
```

2. Проверьте доступность с телефона:
- Откройте браузер на телефоне
- Перейдите: `http://192.168.213.21:8080/api/admin/students`
- Должен показаться JSON ответ

3. Проверьте Firewall:
```powershell
# Windows - разрешить порт 8080
New-NetFirewallRule -DisplayName "Backend API" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

4. Убедитесь что используете правильный IP:
```bash
ipconfig
# Проверьте IPv4 Address вашего WiFi адаптера
```

## Expo Go vs Development Build

### С Expo Go (рекомендуется для начала):
- Просто отсканируйте QR-код
- Используется текущая конфигурация IP
- Работает на Android и iOS

### Для Production:
- Используйте фиксированный IP или домен
- Настройте HTTPS
- Используйте переменные окружения
