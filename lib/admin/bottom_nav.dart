import 'package:flutter/material.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: "Orders",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: "Products",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: "Customers",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: "Appointments",
        ),
      ],
    );
  }
}
