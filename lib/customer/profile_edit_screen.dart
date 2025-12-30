import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:version0/models/user_profile.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserProfile profile;
  const ProfileEditScreen({super.key, required this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;

  final user = FirebaseAuth.instance.currentUser;
  final Color themeColor = const Color(0xFFFF9800);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _streetController = TextEditingController(text: widget.profile.street);
    _cityController = TextEditingController(text: widget.profile.city);
    _stateController = TextEditingController(text: widget.profile.state);
    _zipController = TextEditingController(text: widget.profile.zip);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (user == null) return;

    final updatedProfile = UserProfile(
      fullName: _nameController.text,
      phone: _phoneController.text,
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      zip: _zipController.text,
    );

    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(user!.uid)
        .set(updatedProfile.toMap(), SetOptions(merge: true));

    Navigator.pop(context); // Return to profile screen
  }

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
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
              label: const Text("Save", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField("Full Name", _nameController),
            const SizedBox(height: 16),
            _buildTextField("Phone Number", _phoneController),
            const SizedBox(height: 16),
            _buildTextField("Street Address", _streetController),
            const SizedBox(height: 16),
            _buildTextField("City", _cityController),
            const SizedBox(height: 16),
            _buildTextField("State", _stateController),
            const SizedBox(height: 16),
            _buildTextField("ZIP Code", _zipController),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
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
        ),
      ],
    );
  }
}
