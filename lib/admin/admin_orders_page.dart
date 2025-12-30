import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance.collection('orders');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) return const Center(child: Text("No orders yet."));

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = order['items'] as List<dynamic>;
              final total = order['total'];
              final timestamp = order['timestamp']?.toDate() ?? DateTime.now();

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text("Order #${order.id} - RM $total"),
                  subtitle: Text("Date: ${timestamp.toString().split('.')[0]}"),
                  children: items.map((item) {
                    return ListTile(
                      title: Text(item['productId']),
                      subtitle: Text("Color: ${item['selectedColor']} x${item['quantity']}"),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
