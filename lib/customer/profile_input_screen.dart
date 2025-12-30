import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:version0/models/user_profile.dart';


class ProfileInputScreen extends StatefulWidget {
  final String userId;
  const ProfileInputScreen({required this.userId, super.key});

  @override
  _ProfileInputScreenState createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _zip = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _street,
                decoration: const InputDecoration(labelText: "Street"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _city,
                decoration: const InputDecoration(labelText: "City"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _state,
                decoration: const InputDecoration(labelText: "State"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _zip,
                decoration: const InputDecoration(labelText: "ZIP Code"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FirebaseFirestore.instance
                        .collection('profiles')
                        .doc(widget.userId)
                        .set({
                      'fullName': _fullName.text.trim(),
                      'phone': _phone.text.trim(),
                      'street': _street.text.trim(),
                      'city': _city.text.trim(),
                      'state': _state.text.trim(),
                      'zip': _zip.text.trim(),
                    });
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                child: const Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
