import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'widgets/app_bottom_nav.dart';
import 'package:version0/services/customer_invoice_service.dart';

/// =============================
/// TRACK ORDERS SCREEN
/// =============================
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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search by Product Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
            const Text('Your Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
                      final orderDoc = orders[index];
                      final data = orderDoc.data() as Map<String, dynamic>;

                      final items = (data['items'] as List<dynamic>? ?? []);
                      final status = (data['status'] ?? 'pending') as String;
                      final total = _parsePrice(data['total']);
                      final timestamp = (data['timestamp'] as Timestamp).toDate();

                      final totalQty = items.fold<int>(
                        0,
                        (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0),
                      );

                      return OrderCard(
                        orderDoc: orderDoc,
                        items: items,
                        totalQty: totalQty,
                        total: total,
                        status: status,
                        date: DateFormat('dd MMM yyyy').format(timestamp),
                        searchQuery: searchQuery,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailsScreen(orderDoc: orderDoc),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  double _parsePrice(dynamic rawPrice) {
    if (rawPrice is num) return rawPrice.toDouble();
    if (rawPrice is String) return double.tryParse(rawPrice) ?? 0.0;
    return 0.0;
  }
}

/// =============================
/// ORDER CARD WIDGET
/// =============================
class OrderCard extends StatelessWidget {
  final DocumentSnapshot orderDoc;
  final List<dynamic> items;
  final int totalQty;
  final double total;
  final String status;
  final String date;
  final String searchQuery;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.orderDoc,
    required this.items,
    required this.totalQty,
    required this.total,
    required this.status,
    required this.date,
    required this.searchQuery,
    required this.onTap,
  });

  Color get statusColor =>
      status.toLowerCase() == 'complete' ? Colors.green.shade100 : Colors.orange.shade100;

  Color get statusTextColor =>
      status.toLowerCase() == 'complete' ? Colors.green : Colors.orange;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            ...items.map((item) => OrderItemWidget(item: item)),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Items: $totalQty", style: const TextStyle(color: Colors.grey)),
                Text("RM ${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'Tap to view details & print invoice',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  const OrderItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final productId = item['productId'];
    final qty = ((item['quantity'] as num?)?.toInt() ?? 0);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final productData = snapshot.data!.data() as Map<String, dynamic>?;
        final productName = productData?['name'] ?? 'Unknown Product';
        final rawPrice = productData?['price'];
        final price = rawPrice is num
            ? rawPrice.toDouble()
            : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text("$productName × $qty (RM ${price.toStringAsFixed(2)})",
              style: const TextStyle(fontSize: 14)),
        );
      },
    );
  }
}

/// =============================
/// ORDER DETAILS SCREEN
/// =============================
class OrderDetailsScreen extends StatefulWidget {
  final DocumentSnapshot orderDoc;

  const OrderDetailsScreen({super.key, required this.orderDoc});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Map<String, Map<String, dynamic>> productsData = {};
  bool loadingProducts = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final data = widget.orderDoc.data() as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    final productIds = items.map((e) => e['productId'] as String).toSet().toList();

    try {
      final snapshots = await Future.wait(
        productIds.map((id) => FirebaseFirestore.instance.collection('products').doc(id).get()),
      );

      final Map<String, Map<String, dynamic>> fetched = {};
      for (var snap in snapshots) {
        fetched[snap.id] = snap.data() as Map<String, dynamic>? ?? {};
      }

      if (mounted) {
        setState(() {
          productsData = fetched;
          loadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loadingProducts = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load product details: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.orderDoc.data() as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    final status = (data['status'] ?? 'pending') as String;
    final orderDate = (data['timestamp'] as Timestamp).toDate();
    final total = _parsePrice(data['total']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Order #${widget.orderDoc.id}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      border: Border(bottom: BorderSide(color: _getStatusColor(status), width: 3)),
                    ),
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 40),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Order Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(status),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Order info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildRow('Order Date', DateFormat('dd MMM yyyy, HH:mm').format(orderDate)),
                        const SizedBox(height: 8),
                        _buildRow('Order ID', '#${widget.orderDoc.id}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Print invoice button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(color: Colors.orange),
                            ),
                          );

                          await CustomerInvoiceService.printInvoice(widget.orderDoc);

                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error generating invoice: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.print, size: 24),
                      label: const Text('Print Invoice', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text('Order Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  ...items.map((item) {
                    final productId = item['productId'] as String;
                    final qty = (item['quantity'] as num?)?.toInt() ?? 0;
                    final product = productsData[productId];
                    final productName = product?['name'] ?? 'Unknown Product';
                    final price = _parsePrice(product?['price']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.inventory_2, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Qty: $qty × RM ${price.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              ],
                            ),
                          ),
                          Text('RM ${(qty * price).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Total amount
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('RM ${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  double _parsePrice(dynamic rawPrice) {
    if (rawPrice is num) return rawPrice.toDouble();
    if (rawPrice is String) return double.tryParse(rawPrice) ?? 0.0;
    return 0.0;
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
      case 'completed':
      case 'delivered':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
