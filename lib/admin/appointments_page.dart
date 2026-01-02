import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appointmentsRef = FirebaseFirestore.instance.collection('appointments');

    return StreamBuilder<QuerySnapshot>(
      stream: appointmentsRef.orderBy('date', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        // Statistics Calculation
        int total = docs.length;
        int siteVisits = docs.where((d) => d['type'] == 'Site Visit').length;
        int consultations = docs.where((d) => d['type'] == 'Consultation').length;
        int upcoming = docs.where((d) => d['status'] == 'Upcoming').length;

        // Filtering for Search
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // We search by userId or status as names are usually in a separate 'users' collection
          return data['status'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
              data['type'].toString().toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              // 1. Search Bar - Matches Product/Customer Pages
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Search by type or status...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // 2. Stats Grid - Matches Customer Page Layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.6,
                  children: [
                    _buildStatCard("Total Appts", total.toString(), Colors.black),
                    _buildStatCard("Upcoming", upcoming.toString(), Colors.orange),
                    _buildStatCard("Site Visits", siteVisits.toString(), Colors.blue),
                    _buildStatCard("Consultations", consultations.toString(), Colors.purple),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Appointment List Grouped by Date
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final data = filteredDocs[index].data() as Map<String, dynamic>;
                  return _buildAppointmentCard(data);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> data) {
    DateTime appointmentDate = (data['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(appointmentDate);
    String uid = data['userId'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              formattedDate,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(data['time'] ?? '00:00 AM',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    _buildBadge(data['type'], data['type'] == 'Site Visit' ? Colors.blue : Colors.purple),
                    const SizedBox(width: 8),
                    _buildBadge(data['status'], Colors.green),
                  ],
                ),
                const SizedBox(height: 16),

                // --- NEW: USER NAME LOOKUP ---
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('profiles').doc(uid).get(),
                  builder: (context, userSnapshot) {
                    String displayName = "Loading...";
                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                      displayName = userData['name'] ?? 'Unknown User';
                    } else if (userSnapshot.hasError) {
                      displayName = "Error loading name";
                    }
                    return _buildInfoRow(Icons.person_outline, displayName);
                  },
                ),

                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, data['siteAddress'] ?? 'No address provided'),
                if (data['notes'] != null && data['notes'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.note_outlined, data['notes'], isItalic: true),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isItalic = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}