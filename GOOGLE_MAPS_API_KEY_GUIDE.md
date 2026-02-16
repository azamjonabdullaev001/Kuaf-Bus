# 🗺️ КАК ПОЛУЧИТЬ GOOGLE MAPS API КЛЮЧ

## ⚠️ КРИТИЧНО: БЕЗ ЭТОГО APK БУДЕТ ВЫЛЕТАТЬ!

React Native Maps требует **Google Maps API key** для работы на Android!

---

## 🔑 БЫСТРЫЙ СПОСОБ (Бесплатно)

### **ШАГ 1: Создай проект в Google Cloud**

1. Открой: https://console.cloud.google.com/
2. Войди через Google аккаунт
3. Нажми **"Select a project"** → **"NEW PROJECT"**
4. Имя проекта: `Bus Tracking`
5. Нажми **"CREATE"**

---

### **ШАГ 2: Включи Maps SDK for Android**

1. В меню слева найди **"APIs & Services"** → **"Library"**
2. Найди **"Maps SDK for Android"**
3. Нажми **"ENABLE"**

---

### **ШАГ 3: Создай API ключ**

1. Перейди в **"APIs & Services"** → **"Credentials"**
2. Нажми **"+ CREATE CREDENTIALS"** → **"API key"**
3. Скопируй ключ (будет выглядеть как: `AIzaSyA... (39 символов)`)

---

### **ШАГ 4: Добавь ключ в app.json**

Открой файл: `bus/app.json`

Найди секцию `android.config` и **ЗАМЕНИ** dummy ключ:

```json
"android": {
  "config": {
    "googleMaps": {
      "apiKey": "AIzaSyA_ВАШ_РЕАЛЬНЫЙ_КЛЮЧ_СЮДА"
    }
  }
}
```

---

### **ШАГ 5: Собери НОВЫЙ APK**

```bash
cd bus
git add -A
git commit -m "Добавлен Google Maps API ключ"
eas build --platform android --profile preview
```

---

## 💰 БЕСПЛАТНЫЙ ЛИМИТ

Google дает **$200 кредитов в месяц БЕСПЛАТНО**!

Это = **28,500 загрузок карты** в месяц! Более чем достаточно для университета.

---

## 🔒 БЕЗОПАСНОСТЬ: Ограничь ключ

После создания ключа, **ограничь его использование**:

1. В **Credentials** нажми на свой API ключ
2. **Application restrictions:**
   - Выбери **"Android apps"**
   - Нажми **"+ ADD AN ITEM"**
   - Package name: `com.university.bustracking`
   - SHA-1: (можно оставить пустым для разработки)

3. **API restrictions:**
   - Выбери **"Restrict key"**
   - Отметь только **"Maps SDK for Android"**

4. Нажми **"SAVE"**

---

## ❌ ЧТО ПРОИСХОДИТ БЕЗ API КЛЮЧА?

```
APK вылетает при открытии карты
Логи показывают: "Google Maps API key not found"
Пустая серая карта вместо Яндекс/Google карты
```

---

## ✅ АЛЬТЕРНАТИВА: Использовать базовую карту

Если не хочешь регистриро ваться в Google Cloud, можешь **временно** использовать MapView без Google Maps (будет показывать упрощенную карту):

Но **ЛУЧШЕ** получить настоящий API ключ - это займет **5 минут** и **БЕСПЛАТНО**!

---

## 🆘 ИСПРАВЛЕНО В app.json:

✅ Добавлена секция `android.config.googleMaps`  
✅ Добавлен placeholder ключ (нужно заменить на реальный)  
✅ Упрощен компонент YandexMap (убран вложенный BusMarker)  
✅ Добавлен ErrorBoundary для предотвращения полных вылетов  

---

## 📱 ПОСЛЕ ДОБАВЛЕНИЯ КЛЮЧА:

```bash
# 1. Собери новый APK
cd bus
eas build --platform android --profile preview

# 2. Дождись окончания сборки (10-15 минут)

# 3. Скачай и установи НОВЫЙ APK

# 4. Приложение больше НЕ будет вылетать!
```

---

## 📞 ПОДДЕРЖКА

Если возникли проблемы:
- Проверь что ключ **скопирован полностью** (39 символов)
- Проверь что **Maps SDK for Android ВКЛЮЧЕН**
- Проверь что **нет лишних пробелов** в app.json
