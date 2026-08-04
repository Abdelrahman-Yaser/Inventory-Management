// lib/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل المنتجات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المخزن'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, child) {
          if (inventoryProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد منتجات مضافة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddProductDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة منتج'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: inventoryProvider.products.length,
            itemBuilder: (context, index) {
              final product = inventoryProvider.products[index];
              return _buildProductCard(context, product);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: Colors.blue,
        tooltip: 'إضافة منتج جديد',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final isLowStock = product.stockQuantity < 10;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isLowStock ? Colors.orange[100] : Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.inventory_2,
              color: isLowStock ? Colors.orange : Colors.blue,
              size: 32,
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'الكنية: ${product.nickname}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'السعر: ${product.pricePerUnit.toStringAsFixed(2)} ريال',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLowStock ? Colors.orange[200] : Colors.green[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'الكمية: ${product.stockQuantity.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isLowStock ? Colors.orange[900] : Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              child: const Text('تعديل'),
              onTap: () => _showEditProductDialog(context, product),
            ),
            PopupMenuItem(
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
              onTap: () => _showDeleteConfirmation(context, product),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final nicknameController = TextEditingController();
    final stockController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'إضافة منتج جديد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildTextField('اسم المنتج', nameController),
                const SizedBox(height: 16),
                _buildTextField('الاسم المستعار', nicknameController),
                const SizedBox(height: 16),
                _buildTextField('الكمية الأولية', stockController, isNumber: true),
                const SizedBox(height: 16),
                _buildTextField('سعر الوحدة', priceController, isNumber: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        nicknameController.text.isEmpty ||
                        stockController.text.isEmpty ||
                        priceController.text.isEmpty) {
                      _showSnackBar('يرجى ملء جميع الحقول', isError: true);
                      return;
                    }

                    try {
                      await context.read<InventoryProvider>().addProduct(
                            name: nameController.text,
                            nickname: nicknameController.text,
                            stockQuantity: double.parse(stockController.text),
                            pricePerUnit: double.parse(priceController.text),
                          );

                      if (mounted) {
                        Navigator.pop(context);
                        _showSnackBar('تم إضافة المنتج بنجاح');
                      }
                    } catch (e) {
                      _showSnackBar('حدث خطأ: $e', isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'حفظ',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    nameController.dispose();
    nicknameController.dispose();
    stockController.dispose();
    priceController.dispose();
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final nicknameController = TextEditingController(text: product.nickname);
    final stockController = TextEditingController(text: product.stockQuantity.toString());
    final priceController = TextEditingController(text: product.pricePerUnit.toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'تعديل المنتج',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildTextField('اسم المنتج', nameController),
                const SizedBox(height: 16),
                _buildTextField('الاسم المستعار', nicknameController),
                const SizedBox(height: 16),
                _buildTextField('الكمية', stockController, isNumber: true),
                const SizedBox(height: 16),
                _buildTextField('سعر الوحدة', priceController, isNumber: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        nicknameController.text.isEmpty ||
                        stockController.text.isEmpty ||
                        priceController.text.isEmpty) {
                      _showSnackBar('يرجى ملء جميع الحقول', isError: true);
                      return;
                    }

                    try {
                      await context.read<InventoryProvider>().updateProduct(
                            id: product.id!,
                            name: nameController.text,
                            nickname: nicknameController.text,
                            stockQuantity: double.parse(stockController.text),
                            pricePerUnit: double.parse(priceController.text),
                          );

                      if (mounted) {
                        Navigator.pop(context);
                        _showSnackBar('تم تحديث المنتج بنجاح');
                      }
                    } catch (e) {
                      _showSnackBar('حدث خطأ: $e', isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'حفظ التغييرات',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    nameController.dispose();
    nicknameController.dispose();
    stockController.dispose();
    priceController.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المنتج "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<InventoryProvider>().deleteProduct(product.id!);
                if (mounted) {
                  Navigator.pop(context);
                  _showSnackBar('تم حذف المنتج بنجاح');
                }
              } catch (e) {
                _showSnackBar('حدث خطأ في الحذف', isError: true);
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
