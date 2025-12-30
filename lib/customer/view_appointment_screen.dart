import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ViewAppointmentsScreen extends StatelessWidget {
  const ViewAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeColor = const Color(0xFFFF9800);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: themeColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return const Center(child: Text("No appointments found"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              final type = data['type'] ?? '';
              final time = data['time'] ?? '';
              final status = data['status'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text("$type - ${DateFormat('yyyy-MM-dd').format(date)}"),
                  subtitle: Text("Time: $time\nStatus: $status"),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
