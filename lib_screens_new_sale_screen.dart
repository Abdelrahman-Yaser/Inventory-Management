// lib/screens/new_sale_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({Key? key}) : super(key: key);

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  Product? _selectedProduct;
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_quantityController.text.isEmpty || _priceController.text.isEmpty) {
      setState(() {
        _totalPrice = 0.0;
      });
      return;
    }

    try {
      final quantity = double.parse(_quantityController.text);
      final price = double.parse(_priceController.text);
      setState(() {
        _totalPrice = quantity * price;
      });
    } catch (e) {
      setState(() {
        _totalPrice = 0.0;
      });
    }
  }

  void _onProductSelected(Product product) {
    setState(() {
      _selectedProduct = product;
      _priceController.text = product.pricePerUnit.toStringAsFixed(2);
      _calculateTotal();
    });
  }

  Future<void> _confirmSale() async {
    if (_selectedProduct == null) {
      _showSnackBar('يرجى اختيار منتج', isError: true);
      return;
    }

    if (_quantityController.text.isEmpty) {
      _showSnackBar('يرجى إدخال الكمية', isError: true);
      return;
    }

    if (_priceController.text.isEmpty) {
      _showSnackBar('يرجى إدخال السعر', isError: true);
      return;
    }

    try {
      final quantity = double.parse(_quantityController.text);
      final price = double.parse(_priceController.text);

      if (quantity <= 0) {
        _showSnackBar('الكمية يجب أن تكون أكبر من صفر', isError: true);
        return;
      }

      if (price <= 0) {
        _showSnackBar('السعر يجب أن يكون أكبر من صفر', isError: true);
        return;
      }

      if (quantity > _selectedProduct!.stockQuantity) {
        _showSnackBar(
          'الكمية المتاحة في المخزن: ${_selectedProduct!.stockQuantity}',
          isError: true,
        );
        return;
      }

      // تأكيد البيع
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد عملية البيع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المنتج: ${_selectedProduct!.name}'),
              const SizedBox(height: 8),
              Text('الكمية: $quantity'),
              const SizedBox(height: 8),
              Text('السعر: ${price.toStringAsFixed(2)} ريال'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الإجمالي:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_totalPrice.toStringAsFixed(2)} ريال',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await context.read<InventoryProvider>().addSale(
                        productId: _selectedProduct!.id!,
                        quantitySold: quantity,
                        unitPrice: price,
                      );

                  if (mounted) {
                    Navigator.pop(context);
                    _resetForm();
                    _showSnackBar('تم تسجيل البيع بنجاح');
                  }
                } catch (e) {
                  _showSnackBar('خطأ: $e', isError: true);
                }
              },
              child: const Text('تأكيد', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar('خطأ في إدخال البيانات', isError: true);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedProduct = null;
      _quantityController.clear();
      _priceController.clear();
      _totalPrice = 0.0;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال عملية بيع'),
        backgroundColor: Colors.green,
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
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد منتجات متاحة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'يرجى إضافة منتجات من شاشة إدارة المخزن أولاً',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // قسم اختيار المنتج
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'اختر المنتج',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButton<Product>(
                          isExpanded: true,
                          hint: const Text('اختر منتجاً'),
                          value: _selectedProduct,
                          items: inventoryProvider.products
                              .map((product) => DropdownMenuItem(
                                    value: product,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(product.name),
                                        Text(
                                          'الكمية المتاحة: ${product.stockQuantity.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (product) {
                            if (product != null) {
                              _onProductSelected(product);
                            }
                          },
                        ),
                        if (_selectedProduct != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الكنية: ${_selectedProduct!.nickname}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'السعر الافتراضي: ${_selectedProduct!.pricePerUnit.toStringAsFixed(2)} ريال',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'المتاح في المخزن: ${_selectedProduct!.stockQuantity.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // قسم إدخال الكمية والسعر
                if (_selectedProduct != null) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تفاصيل البيع',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _calculateTotal(),
                            decoration: InputDecoration(
                              labelText: 'الكمية',
                              prefixIcon: const Icon(Icons.shopping_bag),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _calculateTotal(),
                            decoration: InputDecoration(
                              labelText: 'السعر (ريال)',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              border: Border.all(
                                color: Colors.green,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'الإجمالي:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_totalPrice.toStringAsFixed(2)} ريال',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _confirmSale,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('تأكيد البيع'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة تعيين'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
