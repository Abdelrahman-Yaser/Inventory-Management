// lib/models/product.dart

class Product {
  final int? id; // معرف فريد (تلقائي)
  final String name; // اسم الصنف
  final String nickname; // الاسم المستعار
  final double stockQuantity; // الكمية المتاحة
  final double pricePerUnit; // سعر الوحدة

  Product({
    this.id,
    required this.name,
    required this.nickname,
    required this.stockQuantity,
    required this.pricePerUnit,
  });

  // تحويل Product إلى خريطة (Map) للحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'stock_quantity': stockQuantity,
      'price_per_unit': pricePerUnit,
    };
  }

  // إنشاء Product من خريطة (Map)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      nickname: map['nickname'] as String,
      stockQuantity: (map['stock_quantity'] as num).toDouble(),
      pricePerUnit: (map['price_per_unit'] as num).toDouble(),
    );
  }

  // نسخ Product مع تعديل بعض الحقول
  Product copyWith({
    int? id,
    String? name,
    String? nickname,
    double? stockQuantity,
    double? pricePerUnit,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    );
  }

  @override
  String toString() =>
      'Product(id: $id, name: $name, nickname: $nickname, stock: $stockQuantity, price: $pricePerUnit)';
}
