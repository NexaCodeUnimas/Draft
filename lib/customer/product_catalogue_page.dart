import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_details_page.dart';
import 'widgets/app_bottom_nav.dart';

class ProductCataloguePage extends StatefulWidget {
  const ProductCataloguePage({super.key});

  @override
  State<ProductCataloguePage> createState() => _ProductCataloguePageState();
}

class _ProductCataloguePageState extends State<ProductCataloguePage> {
  String searchQuery = '';
  String selectedType = 'All';
  double maxPrice = 200;

  final List<String> types = ['All', '6mm', '8.6mm', '12.6mm', 'XE', 'Accessories'];

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempType = selectedType;
        double tempMaxPrice = maxPrice;

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Filter Products', style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: tempType,
                      isExpanded: true,
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
                    const Text('Max Price:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      min: 0,
                      max: 200,
                      divisions: 200,
                      value: tempMaxPrice,
                      label: 'RM ${tempMaxPrice.toStringAsFixed(0)}',
                      activeColor: Colors.orange,
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              onChanged: (val) => setState(() {
                searchQuery = val;
              }),
            ),
            const SizedBox(height: 20),
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
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
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
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
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
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  productDoc['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => Navigator.pushNamed(context, '/cart'),
        child: const Icon(Icons.shopping_cart),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
