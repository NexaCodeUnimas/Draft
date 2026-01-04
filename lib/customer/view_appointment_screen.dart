import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ViewAppointmentsScreen extends StatelessWidget {
  const ViewAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const themeColor = Color(0xFFFF9800);

    // If no user is logged in
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          title: const Text(
            "My Appointments",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: themeColor,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white), 
        ),
        body: const Center(
          child: Text(
            "Please log in to view your appointments",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          "My Appointments",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: themeColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error loading appointments: ${snapshot.error}"),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No appointments found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final appointments = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime? date;
            final rawDate = data['date'];
            if (rawDate is Timestamp) {
              date = rawDate.toDate();
            } else if (rawDate is DateTime) {
              date = rawDate;
            } else if (rawDate is String) {
              date = DateTime.tryParse(rawDate);
            }

            final type = data['type']?.toString() ?? 'Unknown';
            final time = data['time']?.toString() ?? 'Unknown';
            final status = data['status']?.toString() ?? 'Unknown';

            return {
              'type': type,
              'time': time,
              'status': status,
              'date': date,
            };
          }).toList();

          appointments.sort((a, b) {
            final dateA = a['date'] as DateTime?;
            final dateB = b['date'] as DateTime?;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateA.compareTo(dateB);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              final date = appt['date'] as DateTime?;
              final type = appt['type'] as String;
              final time = appt['time'] as String;
              final status = appt['status'] as String;

              final isCompleted = status.toLowerCase() == 'completed';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Date: ${date != null ? DateFormat('yyyy-MM-dd').format(date) : 'No date'}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Time: $time",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              isCompleted ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
