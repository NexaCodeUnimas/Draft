import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav.dart'; 

class AppointmentMenuScreen extends StatelessWidget {
  const AppointmentMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), 
      appBar: AppBar(
        title: const Text(
          "Appointments",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange, 
        centerTitle: true, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), 
        child: ListView(
          children: const [
            _MenuTile(
              icon: Icons.add,
              title: "Book Appointment",
              routeName: '/book_appointment',
            ),
            _MenuTile(
              icon: Icons.view_list,
              title: "View Appointments",
              routeName: '/view_appointments',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3), 
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String routeName;

  const _MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200), 
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.orange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, routeName),
      ),
    );
  }
}
