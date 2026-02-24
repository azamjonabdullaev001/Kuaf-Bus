# 🔧 Docker Admin Panel - O'zbek tiliga qayta qurish

## ⚠️ MUAMMO:
Docker eski frontend keshini saqladi, shuning uchun o'zgarishlar ko'rinmayapti.

## ✅ YECHIM: Docker konteynerini qayta qurish

### **Usul 1: Avtomatik (TAVSIYA ETILADI)**

Faqat shu faylni ishga tushiring:
```
rebuild-admin-uzbek.bat
```

Bu:
1. ✅ Eski admin-panel konteynerini to'xtatadi
2. ✅ Eski konteynerini o'chiradi  
3. ✅ Docker keshini tozalaydi
4. ✅ Yangi kodlar bilan qayta quradi (uzbek tili + shablon o'chirildi)
5. ✅ Ishga tushiradi
6. ✅ Brauzerda ochadi

---

### **Usul 2: Qo'lda**

Terminal/CMD da bajaring:

```bash
# 1. To'xtatish
docker-compose stop admin-panel

# 2. O'chirish
docker-compose rm -f admin-panel

# 3. Keshni tozalash
docker builder prune -f

# 4. Qayta qurish (KESHSIZ)
docker-compose build --no-cache admin-panel

# 5. Ishga tushirish
docker-compose up -d admin-panel
```

---

### **Usul 3: Super tezkor**

```
quick-rebuild-admin.bat
```
Bu faqat admin-panel ni qayta quradi va loglarni ko'rsatadi.

---

## 🌐 Brauzerda ko'rish

1. Ochish: http://localhost:3001
2. **MUHIM**: Brauzer keshini tozalang:
   - **Ctrl + Shift + R** (Windows/Linux)
   - **Cmd + Shift + R** (Mac)
   
3. Yoki:
   - Chrome: Ctrl+Shift+Delete → "Cached images and files"
   - Firefox: Ctrl+Shift+Delete → "Cache"

---

## ✨ Natija:

**OLDIN (Rus tili):**
- ❌ Панель администратора
- ❌ Студенты / Водители
- ❌ 📥 Шаблон

**KEYIN (O'zbek tili):**
- ✅ Ma'muriyat paneli
- ✅ Talabalar / Haydovchilar
- ✅ Shablon tugmasi O'CHIRILDI!

---

## 🔍 Tekshirish

Agar hali ham rus tili ko'rinsa:

```bash
# Loglarni ko'ring
docker-compose logs admin-panel

# Konteynerni tekshiring
docker ps | grep admin

# Qayta ishga tushiring
docker-compose restart admin-panel
```

---

## ⚡ Muammo hal bo'lmasa

Butun sistemani qayta ishga tushiring:

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

Yoki:
```
start-all.bat
```

---

**Muvaffaqiyat!** 🎉
