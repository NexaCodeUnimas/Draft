import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatefulWidget {
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  @override
  Widget build(BuildContext context) {
    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('timestamp', descending: true);
    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('timestamp', descending: true);

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: ordersQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load orders'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;
          if (orders.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              final items = data['items'] as List<dynamic>? ?? [];
              final total = (data['total'] as num?)?.toDouble() ?? 0.0;
              final timestamp =
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final formattedDate =
                  "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

              final user = data['userEmail'] ?? data['userId'] ?? 'Unknown User';
              final status = data['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text("Order #${order.id} - RM ${total.toStringAsFixed(2)}"),
                  subtitle: Text("By: $user\nDate: $formattedDate\nStatus: ${status.toUpperCase()}"),
                  children: [
                    // List of items
                    ...items.map((item) {
                      final productName = item['productName'] ?? item['productId'] ?? 'Unknown';
                      final color = item['selectedColor'] ?? 'N/A';
                      final quantity = item['quantity'] ?? 1;

                      return ListTile(
                        title: Text(productName),
                        subtitle: Text("Color: $color x $quantity"),
                      );
                    }).toList(),

                    const Divider(),

                    // ===== STATUS BUTTONS =====
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: status == 'pending'
                                ? null
                                : () {
                                    order.reference.update({'status': 'pending'});
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text("Pending"),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: status == 'complete'
                                ? null
                                : () {
                                    order.reference.update({'status': 'complete'});
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text("Complete"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
