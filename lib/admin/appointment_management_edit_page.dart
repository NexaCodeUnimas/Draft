import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentManagementEditPage extends StatelessWidget {
  final String appointmentId;
  final Map<String, dynamic> appointmentData;

  const AppointmentManagementEditPage({
    super.key,
    required this.appointmentId,
    required this.appointmentData,
  });

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFFF9800);
    DateTime appointmentDate = (appointmentData['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(appointmentDate);
    String uid = appointmentData['userId'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment Management"),
        backgroundColor: themeColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Appointment $appointmentId",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBadge(appointmentData['type'], Colors.blue),
                    const SizedBox(width: 8),
                    _buildBadge(appointmentData['status'], Colors.green),
                  ],
                ),
                const Divider(height: 32),
                const Text("Customer Information",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Fetch User Name, Email, and Phone from 'profiles' collection
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('profiles').doc(uid).get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                    return Column(
                      children: [
                        _infoRow("Name:", userData['fullName'] ?? 'N/A'),
                        _infoRow("Email:", userData['email'] ?? 'N/A'),
                        _infoRow("Phone:", userData['phone'] ?? 'N/A'),
                      ],
                    );
                  },
                ),

                const Divider(height: 32),
                const Text("Appointment Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _detailRow(Icons.calendar_month, formattedDate),
                _detailRow(Icons.access_time, appointmentData['time'] ?? 'N/A'),
                _detailRow(Icons.location_on_outlined, appointmentData['siteAddress'] ?? 'N/A'),

                const Divider(height: 32),
                const Text("Notes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(appointmentData['notes'] ?? 'No notes provided',
                    style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic)),

                const SizedBox(height: 32),
                // --- ACTION BUTTONS ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsCompleted(context, uid, formattedDate),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text("Mark as Completed", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _rescheduleAppointment(context, uid),
                    icon: const Icon(Icons.edit_note),
                    label: const Text("Reschedule"),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- RESCHEDULE LOGIC -----------------
  Future<void> _rescheduleAppointment(BuildContext context, String uid) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF9800)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final dt = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
    String formattedTime = DateFormat('hh:mm a').format(dt);
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(pickedDate);

    try {
      // Update appointment
      await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).update({
        'date': Timestamp.fromDate(pickedDate),
        'time': formattedTime,
        'status': 'Rescheduled',
      });

      // --- Add notification ---
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': uid,
        'title': 'Appointment Rescheduled',
        'body': 'Your appointment on $formattedDate at $formattedTime has been rescheduled.',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment rescheduled successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reschedule: $e")),
      );
    }
  }

  // ----------------- MARK AS COMPLETED -----------------
  Future<void> _markAsCompleted(BuildContext context, String uid, String formattedDate) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).update({
        'status': 'Completed',
      });

      // --- Add notification ---
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': uid,
        'title': 'Appointment Completed',
        'body': 'Your appointment on $formattedDate at ${appointmentData['time']} has been marked as completed.',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment marked as completed!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    }
  }

  // ----------------- UI HELPERS -----------------
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

