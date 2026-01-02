import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  @override
  Widget build(BuildContext context) {
    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('timestamp', descending: true);

    return StreamBuilder<QuerySnapshot>(
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
          padding: const EdgeInsets.all(8),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final data = order.data() as Map<String, dynamic>;
            final items = data['items'] as List<dynamic>? ?? [];
            final total = (data['total'] as num?)?.toDouble() ?? 0.0;
            final timestamp =
                (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            final formattedDate =
                "${timestamp.year}-${timestamp.month.toString().padLeft(2,'0')}-${timestamp.day.toString().padLeft(2,'0')} ${timestamp.hour.toString().padLeft(2,'0')}:${timestamp.minute.toString().padLeft(2,'0')}";
            final status = data['status'] ?? 'pending';
            final userId = data['userId'];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #${order.id}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('profiles')
                                  .doc(userId)
                                  .get(),
                              builder: (context, userSnapshot) {
                                String userEmail = "Unknown User";
                                if (userSnapshot.hasData &&
                                    userSnapshot.data!.exists) {
                                  final userData =
                                      userSnapshot.data!.data() as Map<String, dynamic>;
                                  userEmail = userData['email'] ??
                                      userData['userId'] ??
                                      'Unknown User';
                                } else if (userSnapshot.hasError) {
                                  userEmail = "Error loading user";
                                }
                                return Text(
                                  "By: $userEmail",
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Date: $formattedDate",
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IntrinsicWidth(
                        child: _statusDropdown(order.reference, status),
                      ),
                    ],
                  ),
                  children: [
                    const Divider(),
                    // Items list as cards
                    Column(
                      children: items.map((item) {
                        final productId = item['productId'];
                        final color = item['selectedColor'] ?? 'N/A';
                        final quantity = item['quantity'] ?? 1;

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('products')
                              .doc(productId)
                              .get(),
                          builder: (context, productSnapshot) {
                            String productName = productId ?? 'Unknown';
                            if (productSnapshot.hasData &&
                                productSnapshot.data!.exists) {
                              final productData =
                                  productSnapshot.data!.data() as Map<String, dynamic>;
                              productName = productData['name'] ?? productId;
                            } else if (productSnapshot.hasError) {
                              productName = 'Error loading';
                            }

                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      productName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Qty: $quantity"),
                                      Text("Color: $color"),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Total: RM ${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusDropdown(DocumentReference orderRef, String currentStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: currentStatus == 'complete'
            ? Colors.green.shade100
            : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'complete', child: Text('Complete')),
          ],
          onChanged: (value) {
            if (value != null) {
              orderRef.update({'status': value});
            }
          },
        ),
      ),
    );
  }
}
