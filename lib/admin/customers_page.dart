import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:version0/admin/customer_page_detail.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customersRef = FirebaseFirestore.instance.collection('profiles');

    return StreamBuilder<QuerySnapshot>(
      stream: customersRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;


        int totalCustomers = docs.length;

        // Filter list for search
        final filteredDocs = docs.where((doc) {
          final name = (doc.data() as Map<String, dynamic>)['fullName']?.toString().toLowerCase() ?? '';
          return name.contains(searchQuery.toLowerCase());
        }).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              //Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Search by name, email, phone...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                    ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Active Customer: ", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        Text(totalCustomers.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                ),
              ),

              const SizedBox(height: 16),

              //Customer List builder
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final data = filteredDocs[index].data() as Map<String, dynamic>;
                  return _buildCustomerCard(data);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  // Detailed Customer Card
  Widget _buildCustomerCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CustomerPageDetail(customerData: data),
            ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.orange.shade400,
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['fullName'] ?? 'Name',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(data['customerId'] ?? 'custID',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 4),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Email:", data['email'] ?? 'email'),
            _buildInfoRow("Phone:", data['phone'] ?? '01456-7890'),


            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerPageDetail(customerData: data),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("View Details", style: TextStyle(color: Colors.black87)),
              ),
            ),
          ],
        ),
        )
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ),
          Text(value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isPrice ? Colors.orange : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
