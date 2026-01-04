import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'widgets/app_bottom_nav.dart'; // <-- Add bottom nav

class TrackOrdersScreen extends StatefulWidget {
  const TrackOrdersScreen({super.key});

  @override
  State<TrackOrdersScreen> createState() => _TrackOrdersScreenState();
}

class _TrackOrdersScreenState extends State<TrackOrdersScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    final ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user!.uid)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Track Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search by Product Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search product...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Your Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: ordersQuery.snapshots(),
                builder: (context, snapshot) {
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
                      final data =
                          orders[index].data() as Map<String, dynamic>;

                      final items = (data['items'] as List<dynamic>? ?? []);
                      final status = data['status'] ?? 'pending';
                      final total = (data['total'] as num?)?.toDouble() ?? 0.0;
                      final timestamp = (data['timestamp'] as Timestamp).toDate();

                      // total quantity
                      final totalQty = items.fold<int>(
                        0,
                        (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0),
                      );

                      return OrderCard(
                        items: items,
                        totalQty: totalQty,
                        total: total,
                        status: status,
                        date: DateFormat('dd MMM yyyy').format(timestamp),
                        searchQuery: searchQuery,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ====================
      // Bottom Navigation
      // ====================
      bottomNavigationBar: const AppBottomNav(currentIndex: 4), // Orders tab
    );
  }
}

/* ============================================================
   ORDER CARD
============================================================ */

class OrderCard extends StatelessWidget {
  final List<dynamic> items;
  final int totalQty;
  final double total;
  final String status;
  final String date;
  final String searchQuery;

  const OrderCard({
    super.key,
    required this.items,
    required this.totalQty,
    required this.total,
    required this.status,
    required this.date,
    required this.searchQuery,
  });

  Color get statusColor =>
      status == 'complete' ? Colors.green.shade100 : Colors.orange.shade100;

  Color get statusTextColor =>
      status == 'complete' ? Colors.green : Colors.orange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // PRODUCTS
          ...items.map((item) {
            final productId = item['productId'];
            final qty = ((item['quantity'] as num?)?.toInt() ?? 0);

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('products')
                  .doc(productId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final productData =
                    snapshot.data!.data() as Map<String, dynamic>?;
                final productName = productData?['name'] ?? 'Unknown Product';

                if (searchQuery.isNotEmpty &&
                    !productName.toLowerCase().contains(searchQuery)) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    "$productName  × $qty",
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              },
            );
          }),

          const Divider(height: 28),

          // FOOTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Items: $totalQty",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                "RM ${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
