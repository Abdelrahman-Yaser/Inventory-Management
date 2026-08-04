// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/inventory_provider.dart';
import 'screens/inventory_screen.dart';
import 'screens/new_sale_screen.dart';
import 'screens/reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: MaterialApp(
        title: 'تطبيق إدارة المخزن والمبيعات',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          textDirection: TextDirection.rtl,
          fontFamily: 'Scheherazade',
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const InventoryScreen(),
    const NewSaleScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'المخزن',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'بيع جديد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'التقارير',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
