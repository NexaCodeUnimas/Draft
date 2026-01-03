import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // --- CASE: USER NOT LOGGED IN ---
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.orange),
        body: const Center(
          child: Text(
            'You must be logged in to see notifications.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final currentUserId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.orange),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // --- LOADING STATE ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- ERROR STATE ---
          if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications: ${snapshot.error}'));
          }

          // --- NO NOTIFICATIONS ---
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          // --- SHOW NOTIFICATIONS LIST ---
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;

              return ListTile(
                title: Text(data['title'] ?? 'No Title'),
                subtitle: Text(data['body'] ?? 'No Body'),
                trailing: isRead ? null : const Icon(Icons.fiber_new, color: Colors.red),
                onTap: () {
                  // Mark as read
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(doc.id)
                      .update({'isRead': true});
                },
              );
            },
          );
        },
      ),
    );
  }
}
