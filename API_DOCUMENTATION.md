# 📚 توثيق API - تطبيق إدارة المخزن والمبيعات

دليل شامل لجميع الفئات والدوال المتاحة في التطبيق.

---

## 📦 الفئات (Classes)

### 1. Product (نموذج المنتج)

**الملف:** `lib/models/product.dart`

#### الخصائص:
```dart
class Product {
  final int? id;                  // معرف فريد (null إذا لم يحفظ)
  final String name;              // اسم المنتج
  final String nickname;          // الاسم المستعار
  final double stockQuantity;     // الكمية المتاحة
  final double pricePerUnit;      // سعر الوحدة
}
```

#### الدوال:

**`toMap() → Map<String, dynamic>`**
- تحويل المنتج إلى خريطة للحفظ في قاعدة البيانات
```dart
Product product = Product(
  name: 'أرز',
  nickname: 'AR',
  stockQuantity: 100,
  pricePerUnit: 25.0,
);
Map<String, dynamic> data = product.toMap();
// {'name': 'أرز', 'nickname': 'AR', 'stock_quantity': 100, 'price_per_unit': 25.0}
```

**`fromMap(Map<String, dynamic>) → Product`** (Factory)
- إنشاء منتج من بيانات قاعدة البيانات
```dart
Map<String, dynamic> data = {'id': 1, 'name': 'أرز', 'nickname': 'AR', 'stock_quantity': 100, 'price_per_unit': 25.0};
Product product = Product.fromMap(data);
```

**`copyWith({...}) → Product`**
- نسخ المنتج مع تعديل بعض الحقول
```dart
Product updated = product.copyWith(
  pricePerUnit: 30.0,
  stockQuantity: 50,
);
```

---

### 2. SaleTransaction (نموذج المبيعات)

**الملف:** `lib/models/sale_transaction.dart`

#### الخصائص:
```dart
class SaleTransaction {
  final int? id;              // معرف العملية
  final int productId;        // معرف المنتج
  final String productName;   // اسم المنتج
  final double quantitySold;  // الكمية المباعة
  final double unitPrice;     // سعر البيع
  final double totalPrice;    // الإجمالي
  final DateTime createdAt;   // التاريخ والوقت
}
```

#### الدوال:

**`toMap() → Map<String, dynamic>`**
- تحويل العملية إلى خريطة للحفظ
```dart
SaleTransaction sale = SaleTransaction(
  productId: 1,
  productName: 'أرز',
  quantitySold: 10,
  unitPrice: 25.0,
  totalPrice: 250.0,
  createdAt: DateTime.now(),
);
```

**`fromMap(Map<String, dynamic>) → SaleTransaction`** (Factory)
- إنشاء عملية من بيانات قاعدة البيانات

---

### 3. DatabaseService (خدمة قاعدة البيانات)

**الملف:** `lib/services/database_service.dart`

#### Singleton Pattern:
```dart
// الوصول للخدمة (نفس الكائن دائماً)
DatabaseService db = DatabaseService();
```

#### دوال المنتجات:

**`addProduct(Product) → Future<int>`**
- إضافة منتج جديد
```dart
Product product = Product(
  name: 'أرز عادي',
  nickname: 'AR',
  stockQuantity: 100,
  pricePerUnit: 25.0,
);
int productId = await db.addProduct(product);
```

**`getAllProducts() → Future<List<Product>>`**
- الحصول على جميع المنتجات
```dart
List<Product> products = await db.getAllProducts();
for (var product in products) {
  print('${product.name}: ${product.stockQuantity}');
}
```

**`getProductById(int id) → Future<Product?>`**
- الحصول على منتج بواسطة المعرف
```dart
Product? product = await db.getProductById(1);
if (product != null) {
  print('المنتج: ${product.name}');
}
```

**`updateProduct(Product) → Future<int>`**
- تحديث بيانات منتج
```dart
Product updated = product.copyWith(pricePerUnit: 30.0);
int changes = await db.updateProduct(updated);
```

**`deleteProduct(int id) → Future<int>`**
- حذف منتج
```dart
int changes = await db.deleteProduct(1);
```

**`updateProductStock(int productId, double quantity) → Future<int>`**
- تحديث كمية المنتج (خصم الكمية المباعة)
```dart
// خصم 10 من كمية المنتج رقم 1
await db.updateProductStock(1, 10);
```

#### دوال المبيعات:

**`addSale(SaleTransaction) → Future<int>`**
- إضافة عملية بيع
```dart
SaleTransaction sale = SaleTransaction(
  productId: 1,
  productName: 'أرز',
  quantitySold: 10,
  unitPrice: 25.0,
  totalPrice: 250.0,
  createdAt: DateTime.now(),
);
int saleId = await db.addSale(sale);
```

**`getAllSales() → Future<List<SaleTransaction>>`**
- الحصول على جميع المبيعات
```dart
List<SaleTransaction> sales = await db.getAllSales();
```

**`getSalesByMonth(int year, int month) → Future<List<SaleTransaction>>`**
- الحصول على مبيعات شهر معين
```dart
List<SaleTransaction> sales = await db.getSalesByMonth(2024, 3);
```

**`getSalesByDateRange(DateTime start, DateTime end) → Future<List<SaleTransaction>>`**
- الحصول على مبيعات خلال فترة زمنية
```dart
DateTime start = DateTime(2024, 3, 1);
DateTime end = DateTime(2024, 3, 31);
List<SaleTransaction> sales = await db.getSalesByDateRange(start, end);
```

**`getSalesByProduct(int productId) → Future<List<SaleTransaction>>`**
- الحصول على مبيعات منتج معين
```dart
List<SaleTransaction> productSales = await db.getSalesByProduct(1);
```

**`getTotalSalesByDateRange(DateTime start, DateTime end) → Future<double>`**
- حساب إجمالي المبيعات خلال فترة
```dart
double total = await db.getTotalSalesByDateRange(start, end);
print('الإجمالي: $total ريال');
```

**`getTotalSalesByMonth(int year, int month) → Future<double>`**
- حساب إجمالي مبيعات شهر
```dart
double total = await db.getTotalSalesByMonth(2024, 3);
```

**`deleteSale(int id) → Future<int>`**
- حذف عملية بيع
```dart
await db.deleteSale(1);
```

**`closeDatabase() → Future<void>`**
- إغلاق قاعدة البيانات
```dart
await db.closeDatabase();
```

---

### 4. InventoryProvider (إدارة الحالة)

**الملف:** `lib/providers/inventory_provider.dart`

#### الخصائص:
```dart
class InventoryProvider extends ChangeNotifier {
  List<Product> _products;          // قائمة المنتجات
  List<SaleTransaction> _sales;     // قائمة المبيعات
  double _totalSales;               // إجمالي المبيعات
}
```

#### الخصائص العامة (Getters):

**`products → List<Product>`**
```dart
List<Product> allProducts = provider.products;
```

**`sales → List<SaleTransaction>`**
```dart
List<SaleTransaction> allSales = provider.sales;
```

**`totalSales → double`**
```dart
double total = provider.totalSales;
```

**`productsCount → int`**
```dart
int count = provider.productsCount;
```

#### الدوال:

**`loadProducts() → Future<void>`**
- تحميل جميع المنتجات من قاعدة البيانات
```dart
await provider.loadProducts();
```

**`addProduct({name, nickname, stockQuantity, pricePerUnit}) → Future<void>`**
- إضافة منتج جديد
```dart
await provider.addProduct(
  name: 'أرز عادي',
  nickname: 'AR',
  stockQuantity: 100,
  pricePerUnit: 25.0,
);
```

**`updateProduct({id, name, nickname, stockQuantity, pricePerUnit}) → Future<void>`**
- تحديث منتج
```dart
await provider.updateProduct(
  id: 1,
  name: 'أرز فاخر',
  nickname: 'ARF',
  stockQuantity: 50,
  pricePerUnit: 35.0,
);
```

**`deleteProduct(int id) → Future<void>`**
- حذف منتج
```dart
await provider.deleteProduct(1);
```

**`getProductById(int id) → Product?`**
- الحصول على منتج
```dart
Product? product = provider.getProductById(1);
```

**`loadAllSales() → Future<void>`**
- تحميل جميع المبيعات
```dart
await provider.loadAllSales();
```

**`loadSalesByMonth(int year, int month) → Future<void>`**
- تحميل مبيعات شهر معين
```dart
await provider.loadSalesByMonth(2024, 3);
```

**`loadSalesByDateRange(DateTime start, DateTime end) → Future<void>`**
- تحميل مبيعات فترة معينة
```dart
await provider.loadSalesByDateRange(
  DateTime(2024, 3, 1),
  DateTime(2024, 3, 31),
);
```

**`addSale({productId, quantitySold, unitPrice}) → Future<void>`**
- إضافة عملية بيع مع تحديث المخزن تلقائياً
```dart
await provider.addSale(
  productId: 1,
  quantitySold: 10,
  unitPrice: 25.0,
);
// يحدث تلقائياً:
// 1. حفظ عملية البيع
// 2. خصم الكمية من المخزن
// 3. تحديث البيانات المحلية
```

**`deleteSale(int saleId) → Future<void>`**
- حذف عملية بيع
```dart
await provider.deleteSale(1);
```

**`getCurrentMonthTotal() → Future<double>`**
- الحصول على إجمالي الشهر الحالي
```dart
double monthTotal = await provider.getCurrentMonthTotal();
```

**`getTotalProductsValue() → double`**
- حساب قيمة إجمالي المنتجات في المخزن
```dart
double value = provider.getTotalProductsValue();
// قيمة = (كمية المنتج × السعر) لكل المنتجات
```

**`getTotalStockQuantity() → double`**
- إجمالي الكمية المخزنة
```dart
double total = provider.getTotalStockQuantity();
```

---

## 🎯 أمثلة عملية (Use Cases)

### مثال 1: إضافة منتج وبيع كمية منه

```dart
// 1. إضافة المنتج
await provider.addProduct(
  name: 'سكر أبيض',
  nickname: 'سكر',
  stockQuantity: 200,
  pricePerUnit: 8.0,
);

// 2. بيع 50 كيلو
await provider.addSale(
  productId: 1,
  quantitySold: 50,
  unitPrice: 10.0,
);

// النتيجة:
// - تم حفظ عملية البيع بقيمة 500 ريال (50 × 10)
// - تم تحديث المخزن ليصبح 150 كيلو (200 - 50)
// - تم تسجيل التاريخ والوقت تلقائياً
```

### مثال 2: عرض التقارير الشهرية

```dart
// 1. تحميل مبيعات الشهر الحالي
await provider.loadSalesByMonth(2024, 3);

// 2. الوصول للبيانات
print('عدد المبيعات: ${provider.sales.length}');
print('الإجمالي: ${provider.totalSales} ريال');
print('المتوسط: ${provider.totalSales / provider.sales.length} ريال');

// 3. عرض التفاصيل
for (var sale in provider.sales) {
  print('${sale.productName}: ${sale.quantitySold} × ${sale.unitPrice} = ${sale.totalPrice}');
}
```

### مثال 3: البحث والفلترة

```dart
// 1. البحث عن مبيعات فترة محددة
DateTime start = DateTime(2024, 3, 1);
DateTime end = DateTime(2024, 3, 15);
await provider.loadSalesByDateRange(start, end);

// 2. الحصول على إجمالي الفترة
double total = provider.totalSales;

// 3. عرض النتائج
print('المبيعات من 1-15 مارس: $total ريال');
print('عدد العمليات: ${provider.sales.length}');
```

---

## 🔄 دورة حياة البيانات (Data Flow)

### تسجيل بيع جديد:
```
مستخدم يدخل البيانات
         ↓
InventoryProvider.addSale()
         ↓
DatabaseService.addSale() → حفظ العملية
         ↓
DatabaseService.updateProductStock() → تحديث المخزن
         ↓
InventoryProvider يحدّث القائم المحلية
         ↓
الواجهة تعاد رسمها (UI Rebuild)
```

### عرض التقارير:
```
مستخدم يختار فترة زمنية
         ↓
InventoryProvider.loadSalesByDateRange()
         ↓
DatabaseService يسأل قاعدة البيانات
         ↓
النتائج تُحفظ محلياً في Provider
         ↓
الواجهة تعرض البيانات
```

---

## 🐛 معالجة الأخطاء (Error Handling)

### في DatabaseService:
```dart
try {
  List<Product> products = await db.getAllProducts();
} catch (e) {
  print('خطأ في الحصول على المنتجات: $e');
}
```

### في InventoryProvider:
```dart
try {
  await provider.addSale(
    productId: 1,
    quantitySold: 1000,
    unitPrice: 25.0,
  );
} on Exception catch (e) {
  if (e.toString().contains('كمية')) {
    // الكمية المتاحة غير كافية
  }
}
```

---

## 📊 أنواع البيانات المدعومة

| النوع | الوصف | مثال |
|------|-------|------|
| `int` | عدد صحيح | `id: 1` |
| `double` | عدد عشري | `price: 25.50` |
| `String` | نص | `name: 'أرز'` |
| `DateTime` | التاريخ والوقت | `DateTime.now()` |
| `List<T>` | قائمة | `List<Product>` |
| `Map` | خريطة بيانات | `toMap()` |

---

## 🔐 قيود وحدود

| الحد | القيمة | الملاحظة |
|-----|--------|---------|
| عدد المنتجات | غير محدود | يعتمد على مساحة التخزين |
| عدد المبيعات | غير محدود | يعتمد على مساحة التخزين |
| دقة الأسعار | 2 عشري | مثل: 25.50 |
| نطاق التواريخ | 2020 - الحاضر | قابل للتعديل |
| طول الأسماء | غير محدود | يُنصح: 100 حرف max |

---

## 💡 أفضل الممارسات

### 1. استخدام Provider بشكل صحيح:
```dart
// ✅ صحيح
context.read<InventoryProvider>().addProduct(...);

// ❌ خطأ
InventoryProvider().addProduct(...);
```

### 2. معالجة الأخطاء:
```dart
// ✅ صحيح
try {
  await provider.addSale(...);
} catch (e) {
  showErrorDialog(e.toString());
}

// ❌ خطأ
await provider.addSale(...);
```

### 3. تحديث البيانات:
```dart
// ✅ صحيح - تحديث تلقائي عند إضافة بيع
await provider.addSale(...);

// ❌ خطأ - عدم تحديث البيانات
// ... بدون استدعاء loadProducts()
```

---

هذا التوثيق يغطي جميع المكونات الرئيسية. للمزيد من التفاصيل، اطلع على التعليقات في الكود.
