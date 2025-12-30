import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CustBookAppointmentScreen extends StatefulWidget {
  const CustBookAppointmentScreen({super.key});

  @override
  State<CustBookAppointmentScreen> createState() => _CustBookAppointmentScreenState();
}

class _CustBookAppointmentScreenState extends State<CustBookAppointmentScreen> {
  final Color themeColor = const Color(0xFFFF9800);
  final user = FirebaseAuth.instance.currentUser;

  String appointmentType = "Consultation";
  DateTime? selectedDate;
  String? selectedTime;
  final TextEditingController siteAddressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final List<String> timeSlots = [
    "09:00 AM", "10:00 AM", "11:00 AM",
    "01:00 PM", "02:00 PM", "03:00 PM", "04:00 PM"
  ];

  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> saveAppointment() async {
    if (selectedDate == null || selectedTime == null) return;

    final doc = FirebaseFirestore.instance.collection('appointments').doc();
    await doc.set({
      'userId': user?.uid,
      'type': appointmentType,
      'date': selectedDate,
      'time': selectedTime,
      'siteAddress': appointmentType == "Site Visit" ? siteAddressController.text : null,
      'notes': notesController.text,
      'status': 'Upcoming',
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointment booked!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: themeColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment Type
            const Text("Appointment Type", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: appointmentType,
              items: ["Consultation", "Site Visit"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => appointmentType = val!),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            if (appointmentType == "Site Visit") ...[
              const Text("Site Visit Address", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: siteAddressController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: "Enter site address",
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Date picker
            const Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(selectedDate == null
                    ? "Pick a date"
                    : DateFormat('yyyy-MM-dd').format(selectedDate!)),
              ),
            ),
            const SizedBox(height: 16),

            // Time picker
            const Text("Select Time", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: timeSlots.map((t) {
                final isSelected = selectedTime == t;
                return ChoiceChip(
                  label: Text(t),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedTime = t),
                  selectedColor: themeColor,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Additional Notes
            const Text("Additional Notes", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: "Any special requirements?",
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveAppointment,
                style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                child: const Text("Confirm Appointment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
