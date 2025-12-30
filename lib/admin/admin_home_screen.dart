import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_nav.dart';
import 'admin_product_catalogue_page.dart';
import 'admin_orders_page.dart'; // Orders page integrated

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      DashboardPage(),
      AdminOrdersPage(), 
      AdminProductCataloguePage(),
      CustomersPage(),
      AppointmentsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFFF9800);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: themeColor,
        automaticallyImplyLeading: _currentIndex != 0, // Hide back on Dashboard
        leading: _currentIndex != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentIndex = 0; // Go back to Dashboard
                  });
                },
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.white, size: 18),
              label: const Text("Sign Out", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return "Dashboard";
      case 1:
        return "Orders";
      case 2:
        return "Products";
      case 3:
        return "Customers";
      case 4:
        return "Appointments";
      default:
        return "Admin";
    }
  }
}

// Placeholder pages (replace with real implementations)
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Dashboard Content"));
  }
}

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Customers Content"));
  }
}

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Appointments Content"));
  }
}
