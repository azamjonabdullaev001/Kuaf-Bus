// Переводы для административной панели

export const translations = {
  uz: {
    // Login Page
    adminPanel: 'Ma\'muriyat paneli',
    busTrackingSystem: 'Universitet avtobuslarini kuzatish tizimi',
    universityId: 'Universitet ID',
    password: 'Parol',
    enterYourId: 'ID raqamingizni kiriting',
    enterPassword: 'Parolni kiriting',
    login: 'Kirish',
    loggingIn: 'Kirilmoqda...',
    accessDenied: 'Faqat administratorlar uchun ruxsat berilgan',
    invalidCredentials: 'Noto\'g\'ri ID yoki parol',
    
    // Dashboard tabs
    students: 'Talabalar',
    drivers: 'Haydovchilar',
    logout: 'Chiqish',
    
    // Lists
    listOfStudents: 'Talabalar ro\'yxati',
    listOfDrivers: 'Haydovchilar ro\'yxati',
    
    // Actions
    addStudent: 'Talaba qo\'shish',
    addDriver: 'Haydovchi qo\'shish',
    importFromFile: 'Fayldan import qilish',
    deleteAll: 'Hammasini o\'chirish',
    export: 'Eksport',
    search: 'Qidirish',
    searchPlaceholder: 'ID, ism yoki familiya bo\'yicha qidiring...',
    searching: 'Qidirilmoqda...',
    clearSearch: 'Qidiruvni tozalash',
    
    // Table headers
    number: '№',
    universityId: 'Universitet ID',
    firstName: 'Ism',
    lastName: 'Familiya',
    middleName: 'Otasining ismi',
    type: 'Turi',
    student: 'Talaba',
    driver: 'Haydovchi',
    
    // Pagination
    showing: 'Ko\'rsatilmoqda',
    of: 'dan',
    studentsLowerCase: 'talabalar',
    driversLowerCase: 'haydovchilar',
    noData: 'Ma\'lumot yo\'q',
    previous: 'Oldingi',
    next: 'Keyingi',
    
    // Form
    required: 'majburiy',
    optional: 'ixtiyoriy',
    cancel: 'Bekor qilish',
    create: 'Yaratish',
    next: 'Keyingi',
    import: 'Import qilish',
    importing: 'Import qilinmoqda...',
    
    // Messages
    userCreatedSuccess: 'muvaffaqiyatli yaratildi!\nID:',
    userLoginInfo: '\n\nKirish uchun foydalanuvchi faqat o\'z ID raqamidan foydalanishi kerak (parol talab qilinmadi)',
    errorCreatingUser: 'Foydalanuvchi yaratishda xato:',
    errorLoadingData: 'Ma\'lumotlarni yuklashda xato:',
    
    // Import modal
    importUsers: 'Foydalanuvchilarni import qilish',
    importDescription: 'Excel (.xlsx), JSON, yoki TXT/CSV formatda faylni yuklang',
    uploadFile: 'Faylni yuklang',
    columnMapping: 'Ustunlarni moslashtirish',
    mappingDescription: 'Fayl ustunlarini tizim maydonlariga moslashtiring:',
    selectColumn: '-- Ustunni tanlang --',
    previewData: 'Ma\'lumotlarni ko\'rib chiqish',
    rowsFound: 'qatorlar topildi',
    emptyFile: 'Fayl bo\'sh yoki noto\'g\'ri format',
    importSuccess: 'muvaffaqiyatli import qilindi!',
    errors: 'Xatolar',
    errorDetails: 'Xatoliklar tafsiloti',
    andMore: 'va yana',
    moreErrors: 'ta xato',
    
    // Delete all modal
    deleteAllUsers: 'Barcha foydalanuvchilarni o\'chirish',
    deleteWarning: 'Bu amal <strong>barcha talabalar va haydovchilarni</strong> ma\'lumotlar bazasidan o\'chiradi.<br/>Bu amal qaytarilmaydi!',
    typeToConfirm: 'Davom etish uchun quyidagi so\'zni kiriting:',
    confirmText: 'HAMMASINI O\'CHIRISH',
    deletingAll: 'O\'chirilmoqda...',
    confirmDelete: 'O\'chirishni tasdiqlang',
    deleteAllSuccess: 'Barcha foydalanuvchilar muvaffaqiyatli o\'chirildi!',
    errorDeletingAll: 'Foydalanuvchilarni o\'chirishda xato:',
  }
};

export const getTranslation = (key, lang = 'uz') => {
  return translations[lang]?.[key] || key;
};

export default translations;
