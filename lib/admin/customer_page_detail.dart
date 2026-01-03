import 'package:flutter/material.dart';

class CustomerPageDetail extends StatelessWidget {
  final Map<String, dynamic> customerData;

  const CustomerPageDetail({super.key, required this.customerData});

  static const themeColor = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text("Customer Details"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoCard(
                    title: "Personal Information",
                    icon: Icons.person_outline,
                    children: [
                      _infoRow("Full Name", customerData['fullName'] ?? 'N/A'),
                      _infoRow("Email", customerData['email'] ?? 'N/A'),
                      _infoRow("Phone", customerData['phone'] ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoCard(
                    title: "Address Details",
                    icon: Icons.location_on_outlined,
                    children: [
                      _infoRow("Street", customerData['street'] ?? 'N/A'),
                      _infoRow("City", customerData['city'] ?? 'N/A'),
                      _infoRow("State", customerData['state'] ?? 'N/A'),
                      _infoRow("ZIP Code", customerData['zip'] ?? 'N/A'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: themeColor),
          ),
          const SizedBox(height: 10),
          Text(
            customerData['fullName'] ?? 'Customer',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: themeColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}