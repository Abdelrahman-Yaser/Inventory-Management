// lib/models/sale_transaction.dart

class SaleTransaction {
  final int? id; // معرف العملية
  final int productId; // رقم المنتج المباع
  final String productName; // اسم المنتج (للتقارير)
  final double quantitySold; // الكمية المباعة
  final double unitPrice; // سعر البيع وقت العملية
  final double totalPrice; // الإجمالي
  final DateTime createdAt; // تاريخ ووقت العملية

  SaleTransaction({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
  });

  // تحويل SaleTransaction إلى خريطة (Map) للحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity_sold': quantitySold,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // إنشاء SaleTransaction من خريطة (Map)
  factory SaleTransaction.fromMap(Map<String, dynamic> map) {
    return SaleTransaction(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      quantitySold: (map['quantity_sold'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() =>
      'SaleTransaction(id: $id, productId: $productId, quantity: $quantitySold, total: $totalPrice, date: $createdAt)';
}
