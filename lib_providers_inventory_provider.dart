// lib/providers/inventory_provider.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale_transaction.dart';
import '../services/database_service.dart';

class InventoryProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Product> _products = [];
  List<SaleTransaction> _sales = [];
  double _totalSales = 0.0;

  List<Product> get products => _products;
  List<SaleTransaction> get sales => _sales;
  double get totalSales => _totalSales;

  InventoryProvider() {
    _initializeData();
  }

  // تحميل البيانات من قاعدة البيانات
  Future<void> _initializeData() async {
    await loadProducts();
    await loadAllSales();
  }

  // ============ عمليات المنتجات ============

  Future<void> loadProducts() async {
    _products = await _databaseService.getAllProducts();
    notifyListeners();
  }

  Future<void> addProduct({
    required String name,
    required String nickname,
    required double stockQuantity,
    required double pricePerUnit,
  }) async {
    final product = Product(
      name: name,
      nickname: nickname,
      stockQuantity: stockQuantity,
      pricePerUnit: pricePerUnit,
    );

    final id = await _databaseService.addProduct(product);
    _products.add(product.copyWith(id: id.toInt()));
    notifyListeners();
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required String nickname,
    required double stockQuantity,
    required double pricePerUnit,
  }) async {
    final product = Product(
      id: id,
      name: name,
      nickname: nickname,
      stockQuantity: stockQuantity,
      pricePerUnit: pricePerUnit,
    );

    await _databaseService.updateProduct(product);
    _products = _products.map((p) => p.id == id ? product : p).toList();
    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    await _databaseService.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============ عمليات المبيعات ============

  Future<void> loadAllSales() async {
    _sales = await _databaseService.getAllSales();
    notifyListeners();
  }

  Future<void> loadSalesByMonth(int year, int month) async {
    _sales = await _databaseService.getSalesByMonth(year, month);
    _totalSales = await _databaseService.getTotalSalesByMonth(year, month);
    notifyListeners();
  }

  Future<void> loadSalesByDateRange(DateTime startDate, DateTime endDate) async {
    _sales = await _databaseService.getSalesByDateRange(startDate, endDate);
    _totalSales = await _databaseService.getTotalSalesByDateRange(startDate, endDate);
    notifyListeners();
  }

  Future<void> addSale({
    required int productId,
    required double quantitySold,
    required double unitPrice,
  }) async {
    final product = getProductById(productId);
    if (product == null) return;

    // التحقق من وجود كمية كافية في المخزن
    if (product.stockQuantity < quantitySold) {
      throw Exception('الكمية المتاحة في المخزن غير كافية');
    }

    final totalPrice = quantitySold * unitPrice;
    final sale = SaleTransaction(
      productId: productId,
      productName: product.name,
      quantitySold: quantitySold,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
    );

    // حفظ عملية البيع
    await _databaseService.addSale(sale);

    // تحديث كمية المنتج في المخزن
    await _databaseService.updateProductStock(productId, quantitySold);

    // تحديث البيانات المحلية
    await loadProducts();
    await loadAllSales();
  }

  Future<void> deleteSale(int saleId) async {
    await _databaseService.deleteSale(saleId);
    await loadAllSales();
  }

  // الحصول على إجمالي المبيعات الحالي
  Future<double> getCurrentMonthTotal() async {
    final now = DateTime.now();
    return await _databaseService.getTotalSalesByMonth(now.year, now.month);
  }

  // الحصول على إجمالي المبيعات لكل المنتجات
  double getTotalProductsValue() {
    return _products.fold<double>(
      0.0,
      (sum, product) => sum + (product.stockQuantity * product.pricePerUnit),
    );
  }

  // الحصول على عدد المنتجات
  int get productsCount => _products.length;

  // الحصول على إجمالي الكمية المخزنة
  double getTotalStockQuantity() {
    return _products.fold<double>(
      0.0,
      (sum, product) => sum + product.stockQuantity,
    );
  }
}
