import 'package:flutter/material.dart';
import 'package:version0/profile_edit_screen.dart';

class ProfileManagementScreen extends StatelessWidget {
  const ProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {

    const Color themeColor =Color(0xFFFF9800);
    
    return  Scaffold(

      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text("Profile Management"),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context)=> const CustEditProfileScreen())
              ),
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 18,),
            label: const Text(
              "Edit",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(themeColor),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: "Personal Information",
                    icon: Icons.person_outline,
                    iconColor: Colors.orange,
                    children: [
                      _buildInfoRow("Full Name", "John Anderson"),
                      _buildInfoRow(
                        "Email Address",
                        "john.anderson@email.com",
                        icon: Icons.email_outlined,
                        subtext: "Email cannot be changed",
                      ),
                      _buildInfoRow(
                        "Phone Number",
                        "+60 104567892",
                        icon: Icons.phone_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: "Address",
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.orange[800]!,
                    children: [
                      _buildInfoRow("Street Address", "Jalan Setia Raja"),
                      _buildInfoRow("City", "Kuching"),
                      _buildInfoRow("State", "Sarawak"),
                      _buildInfoRow("ZIP Code", "93350"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header with Profile Picture
  Widget _buildHeader(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(color: Colors.grey[50]),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: themeColor.withOpacity(0.7),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            "John Anderson",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "john.anderson@email.com",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Generic card for Information Sections
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  // Row for specific data points (Label/Value)
  Widget _buildInfoRow(String label, String value, {IconData? icon, String? subtext}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
              ],
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
          if (subtext != null)
            Text(subtext, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  // Card for Account Actions
  Widget _buildActionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Account Actions", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _actionButton("Change Password", Colors.black87),
          _actionButton("Sign Out", Colors.black87),
          _actionButton("Delete Account", Colors.red),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {},
        child: Text(label, style: TextStyle(color: color)),
      ),
    );
  }
}