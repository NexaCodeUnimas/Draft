import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_details_page.dart';

class ProductCataloguePage extends StatefulWidget {
  const ProductCataloguePage({super.key});

  @override
  State<ProductCataloguePage> createState() => _ProductCataloguePageState();
}

class _ProductCataloguePageState extends State<ProductCataloguePage> {
  String searchQuery = '';
  String selectedType = 'All';
  double maxPrice = 200;

  final List<String> types = ['All', '6mm', '8.6mm', '12.6mm', 'XE'];

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempType = selectedType;
        double tempMaxPrice = maxPrice;

        return AlertDialog(
          title: const Text('Filter Products'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type:'),
                    DropdownButton<String>(
                      value: tempType,
                      items: types
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          tempType = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Max Price:'),
                    Slider(
                      min: 0,
                      max: 200,
                      divisions: 200,
                      value: tempMaxPrice,
                      label: 'RM ${tempMaxPrice.toStringAsFixed(0)}',
                      onChanged: (val) {
                        setState(() {
                          tempMaxPrice = val;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedType = tempType;
                  maxPrice = tempMaxPrice;
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productRef = FirebaseFirestore.instance.collection('products');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          )
        ],
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search products...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() {
                searchQuery = val;
              }),
            ),
          ),
          // Products grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs
                    .where((doc) {
                      final nameMatch = (doc['name'] as String)
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());
                      final typeMatch = selectedType == 'All'
                          ? true
                          : (doc['type'] as String) == selectedType;
                      final price = double.tryParse(
                              doc['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
                          0;
                      final priceMatch = price <= maxPrice;

                      return nameMatch && typeMatch && priceMatch;
                    })
                    .toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No products found."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final productDoc = docs[index];

                    final price = double.tryParse(
                            productDoc['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
                        0;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsPage(
                              productId: productDoc.id,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.asset(
                                    productDoc['image'],
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    productDoc['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 40), // space for price
                              ],
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'RM ${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
