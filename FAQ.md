# ❓ الأسئلة الشائعة - FAQ

أجوبة مفصلة للأسئلة التي يطرحها المستخدمون بشكل متكرر.

---

## ⚙️ الأسئلة التقنية

### س1: هل يمكنني تشغيل التطبيق على iOS؟

**ج:** نعم! التطبيق مبني بـ Flutter ويدعم iOS بالكامل.

**للتشغيل على iOS:**
```bash
# على Mac فقط
flutter run -d iphone

# أو على محاكاة iOS
open -a Simulator
flutter run
```

**المتطلبات:**
- Mac مع Xcode
- iOS SDK
- 5+ GB مساحة تخزين

---

### س2: هل يمكني استخدام التطبيق على ويب؟

**ج:** نعم، لكن بشكل تجريبي.

**للتشغيل على ويب:**
```bash
flutter run -d chrome
```

**ملاحظات:**
- الأداء قد تكون أقل
- بعض الميزات قد لا تعمل بشكل كامل
- يفضل استخدام Android أو iOS

---

### س3: كم حجم التطبيق النهائي؟

**ج:** تقريباً:
- **APK (Android):** 50-70 MB
- **AAB (Android Bundle):** 35-50 MB
- **IPA (iOS):** 60-80 MB

**يمكن تقليل الحجم بـ:**
```bash
# بناء Release APK
flutter build apk --release --split-per-abi

# بناء App Bundle
flutter build appbundle --release
```

---

### س4: هل البيانات تُحفظ تلقائياً؟

**ج:** نعم 100%! كل عملية تُحفظ فوراً في قاعدة البيانات.

**لا تحتاج إلى:**
- زر "حفظ" منفصل
- تسجيل دخول
- اتصال بالإنترنت

---

### س5: ما هي سرعة التطبيق؟

**ج:** سريع جداً!

**أوقات التنفيذ التقريبية:**
- إضافة منتج: < 100ms
- البحث: < 50ms
- عرض 1000 عملية: < 200ms
- حساب التقارير: < 100ms

---

### س6: هل يمكنني إضافة صور للمنتجات؟

**ج:** نعم! يمكن إضافتها بتعديل بسيط.

**الخطوات:**
```dart
// أضف حقل جديد في Product
String? imageUrl;

// أو
Uint8List? imageBytes;

// ثم أضف Image widget في الواجهة
Image.file(File(imageUrl))
```

---

### س7: هل يمكن مزامنة البيانات بين أجهزة?

**ج:** حالياً لا، لكن يمكن إضافتها:

**الحل:**
```dart
// استخدم Firebase Firestore أو Google Drive
// أضف مزامنة اختيارية

// مثال بسيط:
if (connectivityStatus == ConnectivityResult.mobile) {
  await syncToCloud();
}
```

---

### س8: كم عدد المنتجات الذي يدعمه التطبيق؟

**ج:** غير محدود نظرياً!

**في الواقع:**
- 100 منتج: بدون مشاكل ✅
- 1000 منتج: بدون مشاكل ✅
- 10000 منتج: قد تحتاج تحسينات

**تحسينات للأداء:**
```dart
// استخدم pagination
List<Product> products = await db.getProducts(limit: 50, offset: 0);

// أو استخدم search
List<Product> results = products
    .where((p) => p.name.contains(query))
    .toList();
```

---

## 🐛 مشاكل شائعة وحلولها

### س9: التطبيق بطيء عند تحميل المبيعات

**ج:** جرب هذه الحلول:

```dart
// 1. استخدم pagination
final sales = await db.getSales(limit: 50);

// 2. استخدم index في قاعدة البيانات
await db.execute('CREATE INDEX idx_sales_created_at ON sales (created_at)');

// 3. استخدم lazy loading
ListView.builder(
  itemBuilder: (context, index) {
    // يحمل العنصر عند الحاجة فقط
  },
)
```

---

### س10: لا يمكنني حذف منتج

**ج:** السبب قد يكون:

**1. المنتج له مبيعات:**
```dart
// تحقق من المبيعات أولاً
List<SaleTransaction> sales = await db.getSalesByProduct(productId);
if (sales.isNotEmpty) {
  // لا يمكن حذف
  showError('لا يمكن حذف منتج له مبيعات');
}
```

**2. خطأ في المزامنة:**
```bash
flutter clean
flutter pub get
flutter run
```

---

### س11: البيانات لم تُحفظ بعد إعادة التشغيل

**ج:** تحقق من:

```dart
// 1. هل قاعدة البيانات تُنشأ؟
await DatabaseService().database; // يجب أن ينجح

// 2. هل الإذن موجود؟
// في android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

// 3. أعد تشغيل التطبيق
flutter clean
flutter run
```

---

### س12: رسالة خطأ: "Database is locked"

**ج:** الحل:

```dart
// أغلق قاعدة البيانات بشكل صحيح
@override
void dispose() {
  DatabaseService().closeDatabase();
  super.dispose();
}
```

---

## 🎨 أسئلة التخصيص

### س13: كيف أغير الألوان؟

**ج:** عدّل في `main.dart`:

```dart
MaterialApp(
  theme: ThemeData(
    primarySwatch: Colors.teal,  // اللون الأساسي
    scaffoldBackgroundColor: Colors.grey[100],
  ),
)
```

وفي الشاشات:
```dart
// لون المخزن
AppBar(backgroundColor: Colors.teal)

// لون البيع
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green[600],
  )
)
```

---

### س14: كيف أغير اللغة؟

**ج:** أضف دعم اللغات:

```dart
MaterialApp(
  locale: Locale('ar', 'SA'),
  supportedLocales: [
    Locale('ar', 'SA'),
    Locale('en', 'US'),
  ],
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
)
```

---

### س15: كيف أضيف أيقونة تطبيق مخصصة؟

**ج:** استخدم `flutter_launcher_icons`:

```bash
# التثبيت
flutter pub add flutter_launcher_icons

# إضافة الصور
# android: android/app/src/main/res/mipmap-*/ic_launcher.png
# ios: ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

---

## 📊 أسئلة البيانات

### س16: كيف أصدر البيانات إلى Excel؟

**ج:** استخدم `excel` package:

```dart
import 'package:excel/excel.dart';

Future<void> exportToExcel() async {
  var excel = Excel.createExcel();
  var sheet = excel['Sheet1'];

  // إضافة رؤوس
  sheet.insertRowIterables(['المنتج', 'الكمية', 'السعر'], 0);

  // إضافة البيانات
  int row = 1;
  for (var sale in provider.sales) {
    sheet.insertRowIterables([
      sale.productName,
      sale.quantitySold,
      sale.totalPrice,
    ], row);
    row++;
  }

  // حفظ الملف
  excel.encode().then((onValue) {
    File('./report.xlsx')
      ..createSync(recursive: true)
      ..writeAsBytesSync(onValue);
  });
}
```

---

### س17: كيف أصدر البيانات إلى PDF؟

**ج:** استخدم `pdf` package:

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> exportToPDF() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('تقرير المبيعات'),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Text('المنتج'),
                    pw.Text('الكمية'),
                    pw.Text('السعر'),
                  ],
                ),
                ...provider.sales.map((sale) {
                  return pw.TableRow(
                    children: [
                      pw.Text(sale.productName),
                      pw.Text('${sale.quantitySold}'),
                      pw.Text('${sale.totalPrice}'),
                    ],
                  );
                }),
              ],
            ),
          ],
        );
      },
    ),
  );

  // حفظ الملف
  await File('report.pdf').writeAsBytes(await pdf.save());
}
```

---

### س18: كيف أستعيد البيانات المحذوفة؟

**ج:** للأسف لا يوجد Undo/Redo مدمج، لكن يمكن إضافته:

```dart
// إضافة History
class DataHistory {
  List<HistoryEntry> entries = [];

  void addEntry(HistoryEntry entry) {
    entries.add(entry);
  }

  void undo() {
    if (entries.isNotEmpty) {
      entries.removeLast().undo();
    }
  }
}

class HistoryEntry {
  final Function undo;
  HistoryEntry({required this.undo});
}
```

---

## 📱 أسئلة الاستخدام

### س19: هل يمكن استخدام التطبيق من عدة أجهزة؟

**ج:** حالياً كل جهاز له نسخته الخاصة من البيانات.

**للمزامنة:**
```dart
// أضف Firebase Firestore
final firestore = FirebaseFirestore.instance;

Future<void> syncToCloud() async {
  for (var product in provider.products) {
    await firestore
        .collection('products')
        .doc('${product.id}')
        .set(product.toMap());
  }
}
```

---

### س20: هل يمكن إضافة تقارير متقدمة؟

**ج:** نعم! أمثلة:

```dart
// تقرير المنتجات الأكثر مبيعاً
Map<String, double> topProducts = {};
for (var sale in provider.sales) {
  topProducts[sale.productName] = 
      (topProducts[sale.productName] ?? 0) + sale.totalPrice;
}

// تقرير أيام الذروة
Map<String, int> peakDays = {};
for (var sale in provider.sales) {
  String day = DateFormat('EEEE').format(sale.createdAt);
  peakDays[day] = (peakDays[day] ?? 0) + 1;
}

// تقرير الربح
double profit = calculateProfit(provider.sales);
```

---

## 🔒 أسئلة الأمان

### س21: هل البيانات آمنة من الفقد؟

**ج:** نعم! البيانات محفوظة في:
- قاعدة بيانات SQLite محلية
- ملف محمي من النظام
- نسخة احتياطية تلقائية (نسبياً)

**لضمان الأمان:**
```bash
# 1. احفظ نسخة احتياطية دورية
# 2. استخدم جهاز موثوق
# 3. لا تحذف البيانات بدون تأكيد
```

---

### س22: هل أحتاج إنترنت للتطبيق؟

**ج:** **لا إطلاقاً!** التطبيق يعمل 100% بدون إنترنت.

**ولا يحتاج إلى:**
- تسجيل دخول
- حساب محلي
- أذونات خاصة
- الاتصال بخادم

---

### س23: كيف أحمي البيانات بكلمة مرور؟

**ج:** استخدم `sqflite_sqlcipher`:

```dart
// بدلاً من sqflite العادي
import 'package:sqflite_sqlcipher/sqflite.dart';

// فتح قاعدة البيانات المشفرة
Database db = await openDatabase(
  path,
  password: 'my_secure_password',
);
```

---

## 🚀 أسئلة التطوير

### س24: كيف أنشر التطبيق على Google Play؟

**ج:** الخطوات الأساسية:

```bash
# 1. بناء Release APK/AAB
flutter build appbundle --release

# 2. إنشاء حساب Google Play Developer ($25)

# 3. رفع الملف إلى Google Play Console

# 4. ملء التفاصيل والصور

# 5. النشر
```

---

### س25: كيف أنشر على App Store؟

**ج:** (على Mac فقط)

```bash
# 1. بناء IPA
flutter build ios --release

# 2. إنشاء حساب Apple Developer ($99/سنة)

# 3. استخدام Xcode للنشر

# 4. الانتظار للموافقة (24-48 ساعة)
```

---

## 💡 نصائح مفيدة

### س26: كيف أحسّن أداء التطبيق؟

**ج:**

```dart
// 1. استخدم const widgets
const Text('Hello');

// 2. تجنب rebuild غير الضروري
Consumer<InventoryProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.products.length,
    );
  },
)

// 3. استخدم lazy loading
ListView.builder(
  itemBuilder: (context, index) {
    // يحمل العنصر عند الحاجة
  },
)

// 4. أغلق الموارد
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

---

### س27: كيف أختبر التطبيق؟

**ج:**

```dart
// unit tests
test('Product calculation', () {
  Product p = Product(
    name: 'Test',
    nickname: 'T',
    stockQuantity: 100,
    pricePerUnit: 25.0,
  );
  
  expect(p.stockQuantity, 100);
  expect(p.pricePerUnit, 25.0);
});

// widget tests
testWidgets('Product card shows data', (WidgetTester tester) async {
  await tester.pumpWidget(ProductCard(product: testProduct));
  expect(find.text('Test Product'), findsOneWidget);
});
```

---

### س28: كيف أُصحح الأخطاء؟

**ج:**

```dart
// استخدم print للتصحيح
print('DEBUG: $value');

// أو استخدم debugPrint
import 'package:flutter/foundation.dart';
debugPrint('Value: $value');

// في production، استخدم Crashlytics
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
try {
  // code
} catch (e, stackTrace) {
  FirebaseCrashlytics.instance.recordError(e, stackTrace);
}
```

---

### س29: كيف أتعامل مع التحديثات المستقبلية؟

**ج:**

```dart
// عند التحديث:
// 1. احفظ البيانات الحالية
// 2. احفظ نسخة احتياطية
// 3. قم بتحديث قاعدة البيانات

Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // إضافة عمود جديد
    await db.execute(
      'ALTER TABLE products ADD COLUMN category TEXT',
    );
  }
}
```

---

### س30: هل يمكن إضافة إشعارات؟

**ج:** نعم! استخدم `flutter_local_notifications`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> showNotification(String title, String message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('0', 'Important notifications');
  
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    message,
    platformChannelSpecifics,
  );
}
```

---

## 📞 أين أطلب المزيد من المساعدة؟

| السؤال | المصدر |
|--------|--------|
| **مشاكل التثبيت** | README.md + Google |
| **أسئلة عن الكود** | API_DOCUMENTATION.md |
| **أمثلة عملية** | EXAMPLES_AND_USAGE.md |
| **تصميم الواجهة** | SCREENS_GUIDE.md |
| **مشاكل Flutter** | flutter.dev |
| **مشاكل Dart** | dart.dev |
| **StackOverflow** | tag: flutter |

---

## ✅ الخلاصة

**30 سؤال شامل تم الإجابة عليها!**

إذا لم تجد إجابتك:
1. ابحث في التوثيق الأخرى
2. جرب الحل المقترح
3. تحقق من الأمثلة
4. اطلب المساعدة من المجتمع

**استمتع بالتطوير! 🚀**
