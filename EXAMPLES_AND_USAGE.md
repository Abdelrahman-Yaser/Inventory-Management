# 💻 الأمثلة والاستخدام العملي - Examples & Usage

أمثلة عملية وأكواد جاهزة للاستخدام المباشر.

---

## 🎯 أمثلة أساسية

### مثال 1: إضافة منتج جديد

**من خلال الواجهة:**
```
1. اضغط على الشاشة الأولى "المخزن"
2. اضغط على زر (+) الأحمر في الأسفل
3. أدخل البيانات:
   - اسم المنتج: "أرز بسمتي"
   - الاسم المستعار: "أرز"
   - الكمية الأولية: 100
   - السعر: 30.50
4. اضغط "حفظ"
```

**من خلال الكود:**
```dart
// استخدام Provider
await context.read<InventoryProvider>().addProduct(
  name: 'أرز بسمتي',
  nickname: 'أرز',
  stockQuantity: 100,
  pricePerUnit: 30.50,
);
```

---

### مثال 2: تسجيل عملية بيع

**من خلال الواجهة:**
```
1. اضغط على الشاشة الثانية "بيع جديد"
2. اختر المنتج من القائمة: "أرز بسمتي"
3. أدخل الكمية: 10
4. السعر سيملأ تلقائياً: 30.50
5. الإجمالي سيُحسب: 305.00
6. اضغط "تأكيد البيع" → ثم "تأكيد"
```

**من خلال الكود:**
```dart
// استخدام Provider
await context.read<InventoryProvider>().addSale(
  productId: 1,
  quantitySold: 10,
  unitPrice: 30.50,
);

// النتيجة:
// - تم حفظ البيع: 10 × 30.50 = 305 ريال
// - تم خصم الكمية من المخزن: 100 - 10 = 90
// - تم تسجيل التاريخ والوقت تلقائياً
```

---

### مثال 3: عرض التقارير الشهرية

**من خلال الواجهة:**
```
1. اضغط على الشاشة الثالثة "التقارير"
2. سيعرض الشهر الحالي تلقائياً
3. ستظهر:
   - إجمالي المبيعات
   - عدد العمليات
   - متوسط العملية
   - قائمة تفاصيلية
```

**من خلال الكود:**
```dart
// الحصول على بيانات الشهر الحالي
final now = DateTime.now();
await context.read<InventoryProvider>().loadSalesByMonth(
  now.year,
  now.month,
);

// الوصول للبيانات
final totalSales = context.read<InventoryProvider>().totalSales;
final salesCount = context.read<InventoryProvider>().sales.length;
print('الإجمالي: $totalSales ريال');
print('عدد العمليات: $salesCount');
```

---

## 🔧 أمثلة متقدمة

### مثال 4: البحث والفلترة حسب تاريخ

```dart
// البحث في فترة زمنية محددة
final provider = context.read<InventoryProvider>();

DateTime start = DateTime(2024, 3, 1);
DateTime end = DateTime(2024, 3, 31);

await provider.loadSalesByDateRange(start, end);

// طباعة النتائج
for (var sale in provider.sales) {
  print('${sale.productName}: ${sale.totalPrice} ريال');
}
```

---

### مثال 5: التحقق من الكمية قبل البيع

```dart
// التحقق من المخزن
final product = provider.getProductById(1);

if (product != null) {
  if (product.stockQuantity >= quantityToSell) {
    // الكمية كافية - يمكن البيع
    await provider.addSale(
      productId: 1,
      quantitySold: quantityToSell,
      unitPrice: product.pricePerUnit,
    );
  } else {
    // الكمية غير كافية
    print('الكمية المتاحة: ${product.stockQuantity}');
  }
}
```

---

### مثال 6: تعديل سعر المنتج

```dart
// الحصول على المنتج الحالي
final product = provider.getProductById(1);

if (product != null) {
  // تحديث السعر
  await provider.updateProduct(
    id: product.id!,
    name: product.name,
    nickname: product.nickname,
    stockQuantity: product.stockQuantity,
    pricePerUnit: 35.0,  // السعر الجديد
  );
  
  print('تم تحديث السعر من ${product.pricePerUnit} إلى 35.0');
}
```

---

### مثال 7: حساب قيمة المخزن الكلية

```dart
final provider = context.read<InventoryProvider>();

// حساب قيمة جميع المنتجات في المخزن
double totalValue = provider.getTotalProductsValue();

print('قيمة المخزن الكلية: $totalValue ريال');

// أو حساب الكمية الكلية
double totalQuantity = provider.getTotalStockQuantity();

print('الكمية الكلية: $totalQuantity');
```

---

### مثال 8: عرض مبيعات منتج محدد

```dart
final provider = context.read<InventoryProvider>();

// الحصول على جميع مبيعات منتج محدد
List<SaleTransaction> productSales = await DatabaseService()
    .getSalesByProduct(1);

// حساب الكمية الكلية المباعة
double totalSold = productSales.fold<double>(
  0,
  (sum, sale) => sum + sale.quantitySold,
);

print('تم بيع $totalSold من هذا المنتج');

// حساب الإيرادات من هذا المنتج
double totalRevenue = productSales.fold<double>(
  0,
  (sum, sale) => sum + sale.totalPrice,
);

print('إجمالي الإيرادات: $totalRevenue ريال');
```

---

## 📊 أمثلة الحسابات والإحصائيات

### مثال 9: متوسط سعر المنتج

```dart
// متوسط سعر جميع المنتجات
final products = provider.products;

double averagePrice = products.isEmpty
    ? 0
    : products.fold<double>(0, (sum, p) => sum + p.pricePerUnit) /
        products.length;

print('متوسط السعر: $averagePrice ريال');
```

---

### مثال 10: المنتج الأكثر مبيعاً

```dart
final provider = context.read<InventoryProvider>();
final sales = provider.sales;

// تجميع المبيعات حسب المنتج
Map<String, double> productSales = {};

for (var sale in sales) {
  productSales[sale.productName] =
      (productSales[sale.productName] ?? 0) + sale.totalPrice;
}

// البحث عن الأعلى
String? topProduct;
double maxSales = 0;

productSales.forEach((product, sales) {
  if (sales > maxSales) {
    maxSales = sales;
    topProduct = product;
  }
});

print('المنتج الأكثر مبيعاً: $topProduct بـ $maxSales ريال');
```

---

### مثال 11: الربح المتوقع

```dart
// حساب الربح بناءً على التكلفة
Map<String, double> productCost = {
  'أرز': 20,      // سعر التكلفة
  'سكر': 5,       // سعر التكلفة
};

double totalProfit = 0;

for (var sale in provider.sales) {
  double cost = productCost[sale.productName] ?? 0;
  double profit = (sale.unitPrice - cost) * sale.quantitySold;
  totalProfit += profit;
}

print('إجمالي الربح المتوقع: $totalProfit ريال');
```

---

## 🎨 أمثلة الواجهات المخصصة

### مثال 12: إضافة شاشة مخصصة للمحاسبة

```dart
// lib/screens/accounting_screen.dart

class AccountingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('المحاسبة')),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          double totalRevenue = provider.totalSales;
          int productCount = provider.productsCount;
          double inventoryValue = provider.getTotalProductsValue();

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('إجمالي الإيرادات: $totalRevenue ريال'),
                      SizedBox(height: 8),
                      Text('عدد المنتجات: $productCount'),
                      SizedBox(height: 8),
                      Text('قيمة المخزن: $inventoryValue ريال'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

### مثال 13: إضافة رسم بياني للمبيعات

```dart
// استخدام مكتبة charts_flutter
import 'package:charts_flutter/flutter.dart' as charts;

class SalesChartWidget extends StatelessWidget {
  final List<SaleTransaction> sales;

  SalesChartWidget({required this.sales});

  @override
  Widget build(BuildContext context) {
    // تجميع البيانات
    Map<String, int> chartData = {};
    
    for (var sale in sales) {
      chartData[sale.productName] =
          (chartData[sale.productName] ?? 0) + sale.quantitySold.toInt();
    }

    // إنشاء البيانات للرسم البياني
    final data = [
      charts.Series<dynamic, String>(
        id: 'Sales',
        domainFn: (item, _) => item['name'],
        measureFn: (item, _) => item['quantity'],
        data: chartData.entries
            .map((e) => {'name': e.key, 'quantity': e.value})
            .toList(),
      )
    ];

    return charts.BarChart(data);
  }
}
```

---

## 🔐 أمثلة معالجة الأخطاء

### مثال 14: معالجة آمنة للأخطاء

```dart
// دالة آمنة لإضافة منتج
Future<bool> safeAddProduct({
  required String name,
  required String nickname,
  required double quantity,
  required double price,
}) async {
  try {
    // التحقق من المدخلات
    if (name.isEmpty || nickname.isEmpty) {
      throw Exception('الأسماء لا يمكن أن تكون فارغة');
    }

    if (quantity <= 0 || price <= 0) {
      throw Exception('الكمية والسعر يجب أن تكون موجبة');
    }

    // إضافة المنتج
    await context.read<InventoryProvider>().addProduct(
      name: name,
      nickname: nickname,
      stockQuantity: quantity,
      pricePerUnit: price,
    );

    return true;
  } catch (e) {
    print('خطأ: $e');
    _showErrorDialog('فشل إضافة المنتج: $e');
    return false;
  }
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('خطأ'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('موافق'),
        ),
      ],
    ),
  );
}
```

---

### مثال 15: التحقق من صحة البيانات

```dart
class ValidationHelper {
  // التحقق من اسم المنتج
  static bool isValidProductName(String name) {
    return name.isNotEmpty && name.length <= 100;
  }

  // التحقق من السعر
  static bool isValidPrice(double price) {
    return price > 0 && price <= 999999;
  }

  // التحقق من الكمية
  static bool isValidQuantity(double quantity) {
    return quantity > 0;
  }

  // التحقق من جميع البيانات
  static String? validateProduct({
    required String name,
    required String nickname,
    required double quantity,
    required double price,
  }) {
    if (!isValidProductName(name)) {
      return 'اسم المنتج غير صحيح';
    }
    if (!isValidProductName(nickname)) {
      return 'الاسم المستعار غير صحيح';
    }
    if (!isValidQuantity(quantity)) {
      return 'الكمية يجب أن تكون موجبة';
    }
    if (!isValidPrice(price)) {
      return 'السعر يجب أن يكون بين 0 و 999999';
    }
    return null;
  }
}

// الاستخدام
String? error = ValidationHelper.validateProduct(
  name: 'أرز',
  nickname: 'AR',
  quantity: 100,
  price: 25.0,
);

if (error != null) {
  print('خطأ: $error');
} else {
  print('البيانات صحيحة');
}
```

---

## 📱 أمثلة استجابة الواجهة

### مثال 16: عرض رسالة النجاح

```dart
void showSuccessMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
}

// الاستخدام
showSuccessMessage('تم حفظ المنتج بنجاح');
```

---

### مثال 17: عرض تحذير

```dart
void showWarningDialog(String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.orange[50],
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('حسناً'),
        ),
      ],
    ),
  );
}

// الاستخدام
showWarningDialog(
  'تحذير المخزون',
  'الكمية المتاحة من هذا المنتج أقل من 10',
);
```

---

## 🔄 أمثلة التحديث التلقائي

### مثال 18: تحديث البيانات عند الدخول

```dart
@override
void initState() {
  super.initState();
  // تحميل البيانات عند فتح الشاشة
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<InventoryProvider>().loadProducts();
  });
}
```

---

### مثال 19: إعادة تحميل دورية

```dart
// تحديث البيانات كل 5 ثواني
Timer.periodic(Duration(seconds: 5), (timer) {
  context.read<InventoryProvider>().loadAllSales();
});
```

---

## 📈 أمثلة التقارير المتقدمة

### مثال 20: تقرير شامل

```dart
Future<void> generateComprehensiveReport() async {
  final provider = context.read<InventoryProvider>();

  // الشهر الحالي
  final now = DateTime.now();
  await provider.loadSalesByMonth(now.year, now.month);

  print('═══ تقرير الشهر الحالي ═══');
  print('إجمالي المبيعات: ${provider.totalSales} ريال');
  print('عدد العمليات: ${provider.sales.length}');
  print('متوسط العملية: ${provider.totalSales / provider.sales.length} ريال');
  print('عدد المنتجات: ${provider.productsCount}');
  print('قيمة المخزن: ${provider.getTotalProductsValue()} ريال');

  print('\n═══ المبيعات التفصيلية ═══');
  for (var sale in provider.sales) {
    print('${sale.productName}: ${sale.quantitySold} × ${sale.unitPrice} = ${sale.totalPrice} ريال');
  }
}
```

---

## 🎯 استخدام عملي يومي

### السيناريو: يوم في متجر البقالة

```dart
// الصباح: فتح المتجر
await provider.loadProducts(); // عرض المخزن الحالي

// أثناء اليوم: تسجيل المبيعات
// 1. بيع أرز
await provider.addSale(productId: 1, quantitySold: 5, unitPrice: 30);

// 2. بيع سكر
await provider.addSale(productId: 2, quantitySold: 10, unitPrice: 8);

// 3. بيع دقيق
await provider.addSale(productId: 3, quantitySold: 2, unitPrice: 7);

// نهاية اليوم: عرض التقارير
await provider.loadSalesByMonth(2024, 3);
print('مبيعات اليوم: ${provider.totalSales} ريال');
print('عدد العمليات: ${provider.sales.length}');

// قبل الإغلاق: التحقق من المخزون
for (var product in provider.products) {
  if (product.stockQuantity < 10) {
    print('⚠️ منخفض: ${product.name} (${product.stockQuantity})');
  }
}
```

---

**هذه الأمثلة توفر أساساً قوياً للبدء والتطوير!** 🚀
