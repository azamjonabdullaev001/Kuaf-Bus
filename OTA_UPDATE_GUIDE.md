# 🚀 OTA ОБНОВЛЕНИЯ (Over-The-Air Updates)

## ✅ ЧТО ТАКОЕ OTA?

**OTA Updates** = Обновление **БЕЗ пересборки APK**!

- ✅ Изменяешь код JavaScript/React Native
- ✅ Публикуешь update командой
- ✅ Пользователи получают обновление **автоматически** при открытии приложения

**НЕ НУЖНО:**
- ❌ Заново билдить APK
- ❌ Скачивать и устанавливать новый APK
- ❌ Ждать 10-20 минут сборки

---

## 📥 ТВО

Й APK УЖЕ ГОТОВ!

**Скачай:**
```
https://expo.dev/artifacts/eas/r2GicTGAuAHRxjSsHtggMi.apk
```

**Или через браузер:**
1. Открой: https://expo.dev/accounts/supreme001/projects/bus-tracking/builds
2. Найди Build ID: `cab10b40-aa54-4810-91d2-a509c8b18287`
3. Нажми "Download"

---

## 🔧 НАСТРОЙКА (УЖЕ СДЕЛАНО!)

✅ `app.json` - добавлено `runtimeVersion` и `updates.url`  
✅ `eas.json` - добавлены channels для preview и production  
✅ Проект готов к OTA updates!

---

## 📱 КАК ИСПОЛЬЗОВАТЬ OTA UPDATES

### **ШАГ 1: Установи expo-updates**

```bash
cd bus
npm install expo-updates
```

### **ШАГ 2: Внеси изменения в код**

Например, измени текст в `LoginScreen.js`:
```javascript
<Text style={styles.title}>Bus Tracking v2.0</Text>
```

### **ШАГ 3: Опубликуй OTA update**

```bash
cd bus
eas update --branch preview --message "Исправлен баг с паролями"
```

**Параметры:**
- `--branch preview` - канал для preview билда (тот что ты создал)
- `--message "..."` - описание что изменил

### **ШАГ 4: Пользователи получат обновление**

- При следующем запуске APK - автоматически скачается update
- ⚡ Обновление происходит **за секунды**!

---

## 🎯 ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ

### **Быстрое исправление бага:**
```bash
cd bus

# 1. Исправь код
# 2. Опубликуй update
eas update --branch preview --message "Фикс: карта не загружалась"

# Готово! Через минуту все пользователи получат исправление
```

### **Новая функция:**
```bash
eas update --branch preview --message "Новое: темная тема"
```

### **Для production:**
```bash
eas update --branch production --message "Стабильное обновление v1.0.1"
```

---

## ⚠️ ВАЖНО: ЧТО МОЖНО/НЕЛЬЗЯ ОБНОВЛЯТЬ ЧЕРЕЗ OTA

### ✅ **МОЖНО обновлять:**
- JavaScript код (вся логика приложения)
- React компоненты
- Стили (StyleSheet)
- Изображения (assets)
- Конфигурацию (config.js)
- Тексты и переводы

### ❌ **НЕЛЬЗЯ обновлять (нужен новый билд):**
- Native модули (новые библиотеки с native кодом)
- Permissions в AndroidManifest/Info.plist
- `app.json` конфигурацию (bundle ID, permissions)
- SDK версию Expo
- Обновление React Native версии

**Правило:** Если изменения только в JS/React - OTA работает! Если native - нужен новый билд.

---

## 🔄 ROLLBACK (ОТКАТ К ПРЕДЫДУЩЕЙ ВЕРСИИ)

Если OTA update сломал приложение:

```bash
# Посмотри историю updates
eas update:list --branch preview

# Откатись к предыдущему
eas update:republish --update-id <previous-update-id> --branch preview
```

---

## 📊 МОНИТОРИНГ UPDATES

### **Посмотреть все updates:**
```bash
eas update:list --branch preview
```

### **Посмотреть кто скачал update:**
```bash
eas update:view <update-id>
```

### **Удалить update:**
```bash
eas update:delete <update-id>
```

---

## 🚨 TROUBLESHOOTING

### **Update не приходит к пользователям:**

1. Проверь что APK собран с **тем же runtimeVersion** что в app.json:
   ```json
   "runtimeVersion": "1.0.0"
   ```

2. Проверь что используешь правильный branch:
   - APK собран с `--profile preview` → используй `--branch preview`

3. Пользователь должен **перезапустить** приложение (закрыть и открыть заново)

### **Ошибка: "No updates available":**

```bash
# Проверь конфигурацию
eas update:configure

# Попробуй принудительную загрузку
eas update --branch preview --message "Force update" --clear-cache
```

---

## 💡 WORKFLOW ДЛЯ РАЗРАБОТКИ

### **Вариант 1: Разработка через Expo Go (БЕЗ OTA)**
```bash
npm start
# Тестируешь в Expo Go, изменения видны сразу
```

### **Вариант 2: OTA Updates для Preview APK**
```bash
# 1. Собери APK один раз
eas build --platform android --profile preview

# 2. Далее только OTA updates
eas update --branch preview --message "..."
eas update --branch preview --message "..."
eas update --branch preview --message "..."
```

### **Вариант 3: Production**
```bash
# Критические обновления - новый билд
eas build --platform android --profile production

# Мелкие фиксы - OTA
eas update --branch production --message "Hotfix"
```

---

## 🎓 ПОЛЕЗНЫЕ КОМАНДЫ

```bash
# Посмотреть текущую конфигурацию updates
eas update:configure

# Посмотреть все branches
eas branch:list

# Создать новый branch
eas branch:create my-feature-branch

# Посмотреть какой update активен
eas update:view --branch preview

# Проверить совместимость runtime
eas update:validate --branch preview
```

---

## 📖 ПРИМЕР ИСПОЛЬЗОВАНИЯ

### **Сценарий: Ты выпустил APK, но забыл убрать пароли**

**БЕЗ OTA (старый способ):**
1. Исправь код ❌ 30 секунд
2. `eas build` ❌ 20 минут
3. Скачай новый APK ❌ 5 минут
4. Переустанови на всех устройствах ❌ 10 минут
**ИТОГО: ~35 минут**

**С OTA (новый способ):**
1. Исправь код ✅ 30 секунд
2. `eas update --branch preview` ✅ 1 минута
3. Пользователи перезапускают приложение ✅ 5 секунд
**ИТОГО: ~2 минуты**

---

## ✅ ТВОЙ APK ГОТОВ К OTA!

**Сейчас можешь:**

1. **Установи APK** из:
   ```
   https://expo.dev/artifacts/eas/r2GicTGAuAHRxjSsHtggMi.apk
   ```

2. **Внеси изменения** (например, убери тестовые тексты)

3. **Опубликуй update:**
   ```bash
   cd bus
   npm install expo-updates
   eas update --branch preview --message "Первое OTA обновление"
   ```

4. **Перезапусти APK** на телефоне - увидишь изменения!

---

## 🎯 СЛЕДУЮЩИЕ ШАГИ

1. ✅ Скачай и установи APK
2. ✅ Протестируй работу без паролей (используй `519251110726`)
3. ✅ Сделай изменения в коде
4. ✅ Опубликуй OTA update
5. ✅ Проверь что update пришел автоматически

**Теперь ты можешь обновлять приложение мгновенно! 🚀**
