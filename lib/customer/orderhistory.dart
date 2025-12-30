import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: TrackOrdersScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class TrackOrdersScreen extends StatefulWidget {
  const TrackOrdersScreen({super.key});

  @override
  State<TrackOrdersScreen> createState() => _TrackOrdersScreenState();
}

class _TrackOrdersScreenState extends State<TrackOrdersScreen> {
  // 1. Define the data list
  final List<Map<String, dynamic>> allOrders = [
    {
      'orderID': 'FL12345678',
      'date': 'Dec 1, 2025',
      'quantity': '100 boxes',
      'productName': 'Waterblock XE - 33 Bali Teak',
      'status': 'Installation Scheduled',
      'statusColor': const Color(0xFFF3E5F5),
      'statusTextColor': Colors.purple,
      'footerLabel': 'Installation: Dec 10, 2025',
      'price': 'RM15050.00',
    },
    {
      'orderID': 'FL87654321',
      'date': 'Nov 28, 2025',
      'quantity': '20 boxes',
      'productName': 'Waterblock 6mm - W6601 Blanca Roble',
      'status': 'Completed',
      'statusColor': const Color(0xFFE8F5E9),
      'statusTextColor': Colors.green,
      'footerLabel': 'Installation Complete',
      'price': 'RM2830.00',
    },
    {
      'orderID': 'FL55566677',
      'date': 'Dec 2, 2025',
      'quantity': '50 boxes',
      'productName': 'Waterblock Pro 8.6mm - W02 Bianco',
      'status': 'Quote Pending',
      'statusColor': const Color(0xFFFFFDE7),
      'statusTextColor': Colors.orange,
      'footerLabel': 'Quote in progress',
      'price': 'RM10050.00',
    },
  ];

  // 2. This list will hold the filtered results
  List<Map<String, dynamic>> displayedOrders = [];

  @override
  void initState() {
    super.initState();
    // Initially show all orders
    displayedOrders = allOrders;
  }

  // 3. The search logic
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = allOrders;
    } else {
      results = allOrders
          .where(
            (order) =>
                order["orderID"].toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ) ||
                order["productName"].toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ),
          )
          .toList();
    }

    setState(() {
      displayedOrders = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Track Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.of(context).pop(), // Functional Back Button
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search by Order Number',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) =>
                  _runFilter(value), // Trigger filter on typing
              decoration: InputDecoration(
                hintText: 'Enter order number (e.g., FL12345678)',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Your Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            // Expanded allows the list to scroll within the column
            Expanded(
              child: displayedOrders.isNotEmpty
                  ? ListView.builder(
                      itemCount: displayedOrders.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: OrderCard(
                          orderID: displayedOrders[index]['orderID'],
                          date: displayedOrders[index]['date'],
                          quantity: displayedOrders[index]['quantity'],
                          productName: displayedOrders[index]['productName'],
                          status: displayedOrders[index]['status'],
                          statusColor: displayedOrders[index]['statusColor'],
                          statusTextColor:
                              displayedOrders[index]['statusTextColor'],
                          footerLabel: displayedOrders[index]['footerLabel'],
                          price: displayedOrders[index]['price'],
                        ),
                      ),
                    )
                  : const Center(child: Text('No orders found.')),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Order Card Widget
class OrderCard extends StatelessWidget {
  final String orderID;
  final String date;
  final String quantity;
  final String productName;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final String footerLabel;
  final String price;

  const OrderCard({
    super.key,
    required this.orderID,
    required this.date,
    required this.quantity,
    required this.productName,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.footerLabel,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order $orderID',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusTextColor, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(date, style: const TextStyle(color: Colors.grey)),
          Text(quantity, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Text(
            productName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(footerLabel, style: const TextStyle(color: Colors.grey)),
              Text(
                price,
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
