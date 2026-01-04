import 'package:fl_chart/fl_chart.dart';
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
            const Divider(height: 40),
            const ProductPerformanceSection(),
            const SizedBox(height: 20),
            const CustomerActivitySection(),
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


class ProductPerformanceSection extends StatelessWidget {
  const ProductPerformanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        //Aggregate quantities by Product ID
        Map<String, int> productSales = {};
        for (var doc in snapshot.data!.docs) {
          final items = (doc.data() as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
          for (var item in items) {
            String productId = item['productId'] ?? 'Unknown';
            int qty = (item['quantity'] as num?)?.toInt() ?? 0;
            productSales[productId] = (productSales[productId] ?? 0) + qty;
          }
        }

        var sortedList = productSales.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        var top5 = sortedList.take(5).toList();

       //look for product name by product id
        return FutureBuilder<List<String>>(
          future: Future.wait(top5.map((e) async {
            final doc = await FirebaseFirestore.instance.collection('products').doc(e.key).get();
            return doc.exists ? doc['name'] as String : 'Unknown';
          })),
          builder: (context, nameSnapshot) {
            if (!nameSnapshot.hasData) return const SizedBox(height: 200);
            final productNames = nameSnapshot.data!;

            return _buildChartContainer(
              title: "Top Selling Products",
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text("${value.toInt()}"),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < productNames.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                productNames[index].length > 8
                                    ? "${productNames[index].substring(0, 8)}..."
                                    : productNames[index],
                                style: const TextStyle(fontSize: 9),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: top5.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.value.toDouble(),
                          color: Colors.orange,
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


class CustomerActivitySection extends StatelessWidget {
  const CustomerActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('profiles').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        Map<int, int> monthlyGrowth = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['registeredDate'] != null) {
            DateTime date = (data['registeredDate'] as Timestamp).toDate();
            monthlyGrowth[date.month] = (monthlyGrowth[date.month] ?? 0) + 1;
          }
        }

        List<FlSpot> spots = [];
        for (int i = 1; i <= 12; i++) {
          if (monthlyGrowth.containsKey(i)) {
            spots.add(FlSpot(i.toDouble(), monthlyGrowth[i]!.toDouble()));
          }
        }

        return _buildChartContainer(
          title: "Customer Registration Trends",
          child: spots.isEmpty
              ? const Center(child: Text("No registration dates found"))
              : LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              // --- ADDED LABELS LOGIC ---
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                      int m = value.toInt();
                      if (m >= 1 && m <= 12) {
                        return Text(months[m], style: const TextStyle(fontSize: 10));
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.purple,
                  barWidth: 4,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Colors.purple.withOpacity(0.1)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildChartContainer({required String title, required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        SizedBox(height: 180, child: child),
      ],
    ),
  );
}
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

