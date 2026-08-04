# 📐 هيكل المشروع - Project Structure

دليل كامل لهيكل ملفات المشروع وكل جزء من أجزاءه.

---

## 📁 شجرة المجلدات (Directory Tree)

```
inventory_app/
│
├── 📄 pubspec.yaml                 ← تعريف المتعلقات والمشروع
├── 📄 pubspec.lock                 ← قفل الإصدارات (تلقائي)
│
├── 📂 lib/                          ← كود التطبيق الرئيسي
│   │
│   ├── 📄 main.dart                ← نقطة البداية
│   │
│   ├── 📂 models/                  ← نماذج البيانات
│   │   ├── 📄 product.dart         ← نموذج المنتج
│   │   └── 📄 sale_transaction.dart ← نموذج المبيعات
│   │
│   ├── 📂 services/                ← خدمات وقواعد البيانات
│   │   └── 📄 database_service.dart ← خدمة قاعدة البيانات
│   │
│   ├── 📂 providers/               ← إدارة الحالة
│   │   └── 📄 inventory_provider.dart ← مزود الحالة الرئيسي
│   │
│   └── 📂 screens/                 ← الشاشات الرئيسية
│       ├── 📄 inventory_screen.dart    ← شاشة المخزن
│       ├── 📄 new_sale_screen.dart     ← شاشة البيع
│       └── 📄 reports_screen.dart      ← شاشة التقارير
│
├── 📂 android/                      ← كود Android (تلقائي)
│   ├── app/
│   └── gradle/
│
├── 📂 ios/                          ← كود iOS (تلقائي)
│   └── Pods/
│
├── 📂 test/                         ← اختبارات (اختياري)
│   └── widget_test.dart
│
├── 📂 build/                        ← ملفات البناء (تلقائي)
│
├── 📄 .gitignore                    ← تجاهل ملفات Git
│
└── 📄 README.md                     ← التوثيق الرئيسية
```

---

## 📋 ملخص الملفات

### 1. **pubspec.yaml** 🎯
```yaml
name: inventory_app
description: تطبيق إدارة المخزن والمبيعات

dependencies:
  flutter:
  sqflite:
  provider:
  path_provider:
  intl:
```
**الوظيفة:** تعريف المشروع والمتعلقات المطلوبة

---

### 2. **lib/main.dart** 🚀
```
- MyApp: إعداد التطبيق الرئيسي
  - MultiProvider: توفير المزودين
  - MaterialApp: الإعدادات
    - InventoryProvider: مزود الحالة

- MainScreen: الشاشة الرئيسية
  - BottomNavigationBar: التنقل
  - 3 شاشات
```
**الوظيفة:** نقطة البداية وتنظيم التطبيق

---

### 3. **lib/models/** 📦

#### **product.dart**
```dart
class Product {
  - id: معرف فريد
  - name: اسم المنتج
  - nickname: الاسم المستعار
  - stockQuantity: الكمية
  - pricePerUnit: سعر الوحدة
  
  Methods:
  + toMap()
  + fromMap()
  + copyWith()
}
```

#### **sale_transaction.dart**
```dart
class SaleTransaction {
  - id: معرف العملية
  - productId: معرف المنتج
  - productName: اسم المنتج
  - quantitySold: كمية مباعة
  - unitPrice: سعر البيع
  - totalPrice: الإجمالي
  - createdAt: التاريخ والوقت
  
  Methods:
  + toMap()
  + fromMap()
}
```

---

### 4. **lib/services/** 🔧

#### **database_service.dart**
```dart
class DatabaseService {
  - _database: قاعدة البيانات
  
  Database Methods:
  + _initDatabase()
  + _onCreate()
  
  Product Methods:
  + addProduct()
  + getAllProducts()
  + getProductById()
  + updateProduct()
  + deleteProduct()
  + updateProductStock()
  
  Sales Methods:
  + addSale()
  + getAllSales()
  + getSalesByMonth()
  + getSalesByDateRange()
  + getSalesByProduct()
  + getTotalSalesByDateRange()
  + getTotalSalesByMonth()
  + deleteSale()
}
```

---

### 5. **lib/providers/** 📊

#### **inventory_provider.dart**
```dart
class InventoryProvider extends ChangeNotifier {
  Private Data:
  - _products: List<Product>
  - _sales: List<SaleTransaction>
  - _totalSales: double
  
  Public Getters:
  + products
  + sales
  + totalSales
  + productsCount
  
  Product Methods:
  + loadProducts()
  + addProduct()
  + updateProduct()
  + deleteProduct()
  + getProductById()
  
  Sales Methods:
  + loadAllSales()
  + loadSalesByMonth()
  + loadSalesByDateRange()
  + addSale()
  + deleteSale()
  
  Calculation Methods:
  + getCurrentMonthTotal()
  + getTotalProductsValue()
  + getTotalStockQuantity()
}
```

---

### 6. **lib/screens/** 🎨

#### **inventory_screen.dart**
```
InventoryScreen
├── AppBar (أزرق)
├── إذا كانت قائمة فارغة:
│   └── رسالة "لا توجد منتجات"
└── إذا كانت قائمة ممتلئة:
    └── ListView
        └── Product Cards
            ├── الصورة (أيقونة)
            ├── الاسم والكنية
            ├── السعر والكمية
            └── زر القائمة (تعديل/حذف)

FloatingActionButton: إضافة منتج

Dialogs:
- Add Product Dialog
- Edit Product Dialog
- Delete Confirmation Dialog
```

#### **new_sale_screen.dart**
```
NewSaleScreen
├── AppBar (أخضر)
├── إذا كانت قائمة فارغة:
│   └── رسالة "لا توجد منتجات"
└── Cards:
    ├── اختيار المنتج (Dropdown)
    ├── معلومات المنتج (إن وُجد)
    ├── إدخال الكمية
    ├── إدخال السعر
    ├── عرض الإجمالي
    └── الأزرار (تأكيد/إعادة تعيين)

Dialog: تأكيد البيع
```

#### **reports_screen.dart**
```
ReportsScreen
├── AppBar (برتقالي)
├── قسم الفلاتر:
│   ├── زر "الشهر الحالي"
│   └── اختيار نطاق مخصص:
│       ├── تاريخ البداية
│       ├── تاريخ النهاية
│       └── زر البحث
├── ملخص المبيعات:
│   ├── إجمالي المبيعات
│   ├── عدد العمليات
│   └── متوسط العملية
└── قائمة المبيعات:
    └── Sale Cards
        ├── اسم المنتج والسعر
        ├── الكمية والسعر الواحد
        └── التاريخ والوقت
```

---

## 🔄 تدفق البيانات (Data Flow)

### عند إضافة منتج جديد:
```
User Input (InventoryScreen Dialog)
    ↓
Provider.addProduct()
    ↓
DatabaseService.addProduct()
    ↓
SQLite Database (Insert)
    ↓
Provider._products.add()
    ↓
notifyListeners()
    ↓
UI Rebuild (InventoryScreen)
```

### عند تسجيل بيع جديدة:
```
User Input (NewSaleScreen)
    ↓
Provider.addSale()
    ├→ DatabaseService.addSale()
    ├→ DatabaseService.updateProductStock()
    └→ Provider.loadProducts() + loadAllSales()
    ↓
notifyListeners()
    ↓
UI Rebuild (All screens)
```

### عند عرض التقارير:
```
User Selects Date Range (ReportsScreen)
    ↓
Provider.loadSalesByDateRange()
    ↓
DatabaseService.getSalesByDateRange()
    ↓
SQLite Query (SELECT with WHERE)
    ↓
Provider._sales + _totalSales
    ↓
notifyListeners()
    ↓
UI Rebuild (ReportsScreen)
```

---

## 🎯 المسؤوليات (Responsibilities)

### **Models** 📦
- تمثيل البيانات
- تحويل من/إلى Map
- التحقق من صحة البيانات

### **Services** 🔧
- التواصل مع قاعدة البيانات
- عمليات CRUD
- الاستعلامات المعقدة

### **Providers** 📊
- إدارة حالة التطبيق
- تخزين البيانات محلياً
- اشعار الواجهة بالتغييرات

### **Screens** 🎨
- عرض الواجهة للمستخدم
- استقبال المدخلات
- التفاعل مع المستخدم

---

## 📚 حجم الملفات (File Sizes)

| الملف | عدد الأسطر | الحجم تقريباً |
|------|----------|------------|
| main.dart | 60 | 2 KB |
| product.dart | 45 | 1.5 KB |
| sale_transaction.dart | 50 | 1.8 KB |
| database_service.dart | 200 | 7 KB |
| inventory_provider.dart | 180 | 6 KB |
| inventory_screen.dart | 280 | 10 KB |
| new_sale_screen.dart | 250 | 9 KB |
| reports_screen.dart | 300 | 11 KB |
| **المجموع** | **~1365** | **~48.3 KB** |

---

## 🚀 نقاط الدخول (Entry Points)

### 1. **Application Entry Point**
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

### 2. **First Screen Shown**
```dart
// main.dart → MainScreen()
// يعرض: InventoryScreen بشكل افتراضي
```

### 3. **Database Initialization**
```dart
// inventory_provider.dart → _initializeData()
// يُستدعى عند إنشاء Provider لأول مرة
```

---

## 🔌 الوحدات المستقلة (Modules)

يمكن استخدام كل وحدة بشكل مستقل:

```dart
// استخدام Database مباشرة
DatabaseService db = DatabaseService();
List<Product> products = await db.getAllProducts();

// استخدام Provider للتطبيق الكامل
context.read<InventoryProvider>().loadProducts();

// استخدام Models في أماكن أخرى
Product p = Product.fromMap(data);
```

---

## 🧪 ملفات الاختبار (Testing)

### موقع ملفات الاختبار:
```
test/
├── models_test.dart
├── services_test.dart
├── providers_test.dart
└── widgets_test.dart
```

### مثال اختبار بسيط:
```dart
void main() {
  test('Product toMap conversion', () {
    Product product = Product(
      name: 'أرز',
      nickname: 'AR',
      stockQuantity: 100,
      pricePerUnit: 25.0,
    );
    
    Map<String, dynamic> map = product.toMap();
    expect(map['name'], 'أرز');
  });
}
```

---

## 📦 الملفات المُولدة تلقائياً

```
build/                    ← ملفات البناء
.dart_tool/              ← أدوات Dart
pubspec.lock             ← قفل الإصدارات
.packages                ← قائمة الحزم
```

**تجاهل هذه الملفات عند رفع المشروع إلى Git**

---

## 🔑 المتغيرات البيئية (Environment Variables)

إذا أردت إضافة متغيرات بيئية:

```dart
// lib/config/app_config.dart
const String APP_VERSION = '1.0.0';
const bool DEBUG_MODE = true;
const String DATABASE_NAME = 'inventory_app.db';
```

---

## 📋 قائمة التحقق من الملفات

قبل البدء، تأكد من وجود:

- [ ] `pubspec.yaml` بالمتعلقات الصحيحة
- [ ] `lib/main.dart` بنقطة البداية
- [ ] `lib/models/product.dart`
- [ ] `lib/models/sale_transaction.dart`
- [ ] `lib/services/database_service.dart`
- [ ] `lib/providers/inventory_provider.dart`
- [ ] `lib/screens/inventory_screen.dart`
- [ ] `lib/screens/new_sale_screen.dart`
- [ ] `lib/screens/reports_screen.dart`
- [ ] `README.md` للتوثيق

---

## 🎨 ترتيب الواجهة (UI Hierarchy)

```
MyApp
├── MaterialApp
│   └── MainScreen
│       ├── Scaffold
│       │   ├── AppBar (متغير)
│       │   ├── Body (Screen 1/2/3)
│       │   └── BottomNavigationBar
│       │       ├── InventoryScreen
│       │       ├── NewSaleScreen
│       │       └── ReportsScreen
│       └── Dialogs (modals)
│           ├── AddProductDialog
│           ├── EditProductDialog
│           ├── DeleteConfirmationDialog
│           └── SaleConfirmationDialog
```

---

## 💡 نصائح التنظيم

1. **احفظ النموذج مع الخدمة**
   - اجعل Model.fromMap مع DatabaseService معاً

2. **فصل الحاويات عن العروض**
   - Screens تستقبل البيانات من Provider

3. **تعليقات واضحة**
   - أضف تعليقات فوق كل دالة مهمة

4. **معالجة الأخطاء**
   - استخدم try-catch في كل عملية قاعدة بيانات

5. **اختبر كل ميزة**
   - جرّب كل وظيفة قبل الانتقال للتالية

---

هذا الهيكل مرن وقابل للتوسع. يمكنك إضافة وحدات جديدة بسهولة! 🎉
