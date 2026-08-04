// lib/screens/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sale_transaction.dart';
import '../providers/inventory_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _useCurrentMonth = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentMonthData();
    });
  }

  void _loadCurrentMonthData() {
    final now = DateTime.now();
    context.read<InventoryProvider>().loadSalesByMonth(now.year, now.month);
  }

  void _loadCustomDateRange() {
    if (_startDate == null || _endDate == null) {
      _showSnackBar('يرجى تحديد التاريخ البداية والنهاية', isError: true);
      return;
    }

    context
        .read<InventoryProvider>()
        .loadSalesByDateRange(_startDate!, _endDate!);
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _useCurrentMonth = false;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _useCurrentMonth = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
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
        title: const Text('التقارير والمبيعات'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, inventoryProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // قسم الفلاتر
                Container(
                  color: Colors.orange[50],
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'خيارات الفلترة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // زر الشهر الحالي
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _useCurrentMonth = true;
                          });
                          _loadCurrentMonthData();
                        },
                        icon: const Icon(Icons.today),
                        label: const Text('الشهر الحالي'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _useCurrentMonth
                              ? Colors.orange
                              : Colors.grey[300],
                          foregroundColor:
                              _useCurrentMonth ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // اختيار نطاق مخصص
                      const Text(
                        'اختر نطاق مخصص',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _selectStartDate,
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                _startDate == null
                                    ? 'من التاريخ'
                                    : _formatDate(_startDate!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _selectEndDate,
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                _endDate == null
                                    ? 'إلى التاريخ'
                                    : _formatDate(_endDate!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_startDate != null && _endDate != null)
                        ElevatedButton.icon(
                          onPressed: _loadCustomDateRange,
                          icon: const Icon(Icons.search),
                          label: const Text('بحث'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ),

                // قسم ملخص المبيعات
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملخص المبيعات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'إجمالي المبيعات:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${inventoryProvider.totalSales.toStringAsFixed(2)} ريال',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'عدد العمليات:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${inventoryProvider.sales.length}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              if (inventoryProvider.sales.isNotEmpty) ...[
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'متوسط العملية:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${(inventoryProvider.totalSales / inventoryProvider.sales.length).toStringAsFixed(2)} ريال',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // قائمة المبيعات
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text(
                    'تفاصيل المبيعات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (inventoryProvider.sales.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد مبيعات خلال هذه الفترة',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: inventoryProvider.sales.length,
                    itemBuilder: (context, index) {
                      final sale = inventoryProvider.sales[index];
                      return _buildSaleCard(sale);
                    },
                  ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaleCard(SaleTransaction sale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sale.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${sale.totalPrice.toStringAsFixed(2)} ريال',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الكمية: ${sale.quantitySold.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'السعر: ${sale.unitPrice.toStringAsFixed(2)} ريال',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'التاريخ: ${_formatDateTime(sale.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
