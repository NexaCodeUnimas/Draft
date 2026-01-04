import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:version0/services/sales_report_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Default range: last 30 days
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('timestamp', isGreaterThanOrEqualTo: _selectedRange.start)
          .where('timestamp', isLessThanOrEqualTo: _selectedRange.end)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildReportHeader(docs),
            const SizedBox(height: 20),
            const OrdersAndRevenueSection(),
            const PendingAppointmentsSection(),
            const CustomersSection(),
          ],
        );
      },
    );
  }

  Widget _buildReportHeader(List<QueryDocumentSnapshot> docs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sales Reporting", style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text("${DateFormat('MMM d').format(_selectedRange.start)} - ${DateFormat('MMM d').format(_selectedRange.end)}"),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => SalesReportService.exportPdf(docs, _selectedRange),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("PDF"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => SalesReportService.exportCsv(docs),
                    icon: const Icon(Icons.table_chart),
                    label: const Text("CSV"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (range != null) setState(() => _selectedRange = range);
  }
}

/* ===================== ORDERS + MONTHLY REVENUE ===================== */

class OrdersAndRevenueSection extends StatelessWidget {
  const OrdersAndRevenueSection({super.key});

  @override
  Widget build(BuildContext context) {
    final startOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading orders');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        double totalRevenue = 0.0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalRevenue += (data['total'] as num?)?.toDouble() ?? 0.0;
        }

        return Column(
          children: [
            StatCard(
              title: 'Total Orders (This Month)',
              value: docs.length.toString(),
              trend: 'Real-time data',
              icon: Icons.shopping_cart,
              iconColor: Colors.blue,
            ),
            StatCard(
              title: 'Monthly Revenue',
              value: 'RM ${totalRevenue.toStringAsFixed(2)}',
              trend: 'Current month',
              icon: Icons.attach_money,
              iconColor: Colors.green,
            ),
          ],
        );
      },
    );
  }
}

/* ===================== PENDING APPOINTMENTS ===================== */

class PendingAppointmentsSection extends StatelessWidget {
  const PendingAppointmentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'Upcoming') // <-- matches AppointmentsPage
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading appointments');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StatCard(
          title: 'Pending Appointments',
          value: snapshot.data!.docs.length.toString(),
          trend: 'Action required',
          icon: Icons.access_time_filled,
          iconColor: Colors.orange,
        );
      },
    );
  }
}

/* ===================== CUSTOMERS ===================== */

class CustomersSection extends StatelessWidget {
  const CustomersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('profiles') // <-- matches CustomersPage
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading customers');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StatCard(
          title: 'Active Customers',
          value: snapshot.data!.docs.length.toString(),
          trend: 'Registered users',
          icon: Icons.group,
          iconColor: Colors.purple,
        );
      },
    );
  }
}

/* ===================== STAT CARD ===================== */

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                trend,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
        ],
      ),
    );
  }
}

