// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/sale_transaction.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // إنشاء جداول قاعدة البيانات
  Future<void> _onCreate(Database db, int version) async {
    // جدول المنتجات
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        nickname TEXT NOT NULL,
        stock_quantity REAL NOT NULL,
        price_per_unit REAL NOT NULL
      )
    ''');

    // جدول المبيعات
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity_sold REAL NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // إنشاء فهرس على product_id لتسريع البحث
    await db.execute('''
      CREATE INDEX idx_sales_product_id ON sales (product_id)
    ''');

    // إنشاء فهرس على created_at لتسريع البحث الزمني
    await db.execute('''
      CREATE INDEX idx_sales_created_at ON sales (created_at)
    ''');
  }

  // ============ عمليات المنتجات ============

  // إضافة منتج جديد
  Future<int> addProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // الحصول على جميع المنتجات
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  // الحصول على منتج بواسطة ID
  Future<Product?> getProductById(int id) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  // تحديث منتج
  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // حذف منتج
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // تحديث كمية المنتج (خصم الكمية المباعة)
  Future<int> updateProductStock(int productId, double quantitySold) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
      [quantitySold, productId],
    );
  }

  // ============ عمليات المبيعات ============

  // إضافة عملية بيع
  Future<int> addSale(SaleTransaction sale) async {
    final db = await database;
    return await db.insert(
      'sales',
      sale.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // الحصول على جميع المبيعات
  Future<List<SaleTransaction>> getAllSales() async {
    final db = await database;
    final maps = await db.query(
      'sales',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => SaleTransaction.fromMap(map)).toList();
  }

  // الحصول على مبيعات شهر معين
  Future<List<SaleTransaction>> getSalesByMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    final maps = await db.query(
      'sales',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => SaleTransaction.fromMap(map)).toList();
  }

  // الحصول على مبيعات خلال فترة زمنية محددة
  Future<List<SaleTransaction>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'sales',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => SaleTransaction.fromMap(map)).toList();
  }

  // الحصول على مبيعات منتج معين
  Future<List<SaleTransaction>> getSalesByProduct(int productId) async {
    final db = await database;
    final maps = await db.query(
      'sales',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => SaleTransaction.fromMap(map)).toList();
  }

  // حساب إجمالي المبيعات خلال فترة زمنية
  Future<double> getTotalSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(total_price) as total FROM sales WHERE created_at >= ? AND created_at <= ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  // حساب إجمالي المبيعات لشهر معين
  Future<double> getTotalSalesByMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    return getTotalSalesByDateRange(startDate, endDate);
  }

  // حذف عملية بيع
  Future<int> deleteSale(int id) async {
    final db = await database;
    return await db.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // إغلاق قاعدة البيانات
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
