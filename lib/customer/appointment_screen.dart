import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav.dart'; // <-- import the reusable bottom nav

class AppointmentMenuScreen extends StatelessWidget {
  const AppointmentMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
        backgroundColor: const Color(0xFFFF9800),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuTile(
            icon: Icons.add,
            title: "Book Appointment",
            onTap: () => Navigator.pushNamed(context, '/book_appointment'),
          ),
          _MenuTile(
            icon: Icons.view_list,
            title: "View Appointments",
            onTap: () => Navigator.pushNamed(context, '/view_appointments'),
          ),
        ],
      ),

      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      // index 2 = Appointments tab
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.orange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
