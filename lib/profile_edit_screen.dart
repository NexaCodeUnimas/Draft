import 'package:flutter/material.dart';

class CustEditProfileScreen extends StatefulWidget {
  const CustEditProfileScreen({super.key});

  @override
  State<CustEditProfileScreen> createState() => _CustEditProfileScreenState();
}

class _CustEditProfileScreenState extends State<CustEditProfileScreen> {
  // Define controllers to handle the input data
  final TextEditingController _nameController = TextEditingController(text: "John Anderson");
  final TextEditingController _phoneController = TextEditingController(text: "+60 104567892");
  final TextEditingController _addressController = TextEditingController(text: "123 Main Street, Apt 4B");
  final TextEditingController _cityController = TextEditingController(text: "San Francisco");
  final TextEditingController _stateController = TextEditingController(text: "CA");
  final TextEditingController _zipController = TextEditingController(text: "94102");

  final Color themeColor = const Color(0xFFE69F52); // Primary orange

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile Management",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle save logic
              },
              icon: Icon(Icons.save_outlined, color: themeColor, size: 18),
              label: Text("Save", style: TextStyle(color: themeColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildEditCard(
                    title: "Personal Information",
                    icon: Icons.person_outline,
                    children: [
                      _buildFieldLabel("Full Name"),
                      _buildTextField(_nameController),
                      const SizedBox(height: 16),
                      _buildFieldLabel("Email Address"),
                      _buildReadOnlyEmail(),
                      const SizedBox(height: 16),
                      _buildFieldLabel("Phone Number"),
                      _buildTextField(_phoneController),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEditCard(
                    title: "Address",
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildFieldLabel("Street Address"),
                      _buildTextField(_addressController),
                      const SizedBox(height: 16),
                      _buildFieldLabel("City"),
                      _buildTextField(_cityController),
                      const SizedBox(height: 16),
                      _buildFieldLabel("State"),
                      _buildTextField(_stateController),
                      const SizedBox(height: 16),
                      _buildFieldLabel("ZIP Code"),
                      _buildTextField(_zipController),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: themeColor,
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text("John Anderson", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("john.anderson@email.com", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEditCard({required String title, required IconData icon, required List<Widget> children}) {
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
              Icon(icon, color: themeColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildReadOnlyEmail() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.email_outlined, size: 18, color: Colors.grey),
            SizedBox(width: 8),
            Text("john.anderson@email.com", style: TextStyle(color: Colors.grey)),
          ],
        ),
        SizedBox(height: 4),
        Text("Email cannot be changed", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}