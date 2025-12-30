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
  String? selectedPrice;
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    final productRef = FirebaseFirestore.instance.collection('products');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Browse Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => FilterDialog(
                  selectedPrice: selectedPrice,
                  selectedType: selectedType,
                  onApply: (price, type) {
                    setState(() {
                      selectedPrice = price;
                      selectedType = type;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
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

          // Product Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs
                    .where((doc) => (doc['name'] as String)
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();

                // Filter by price/type
                final filteredDocs = docs.where((doc) {
                  bool matchesPrice = true;
                  bool matchesType = true;

                  // Price filter
                  if (selectedPrice != null) {
                    final priceValue = double.tryParse(
                            doc['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
                        0;
                    if (selectedPrice == "<150") matchesPrice = priceValue < 150;
                    if (selectedPrice == ">150") matchesPrice = priceValue >= 150;
                  }

                  // Type filter
                  if (selectedType != null) {
                    matchesType = doc['type'] == selectedType;
                  }

                  return matchesPrice && matchesType;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No products found."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDocs.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final product = filteredDocs[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsPage(productId: product.id),
                        ),
                      ),
                      child: ProductTile(product: product),
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

// Filter Dialog (reuse your previous one)
class FilterDialog extends StatefulWidget {
  final String? selectedPrice;
  final String? selectedType;
  final Function(String?, String?) onApply;

  const FilterDialog({
    super.key,
    required this.selectedPrice,
    required this.selectedType,
    required this.onApply,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? price;
  String? type;

  @override
  void initState() {
    super.initState();
    price = widget.selectedPrice;
    type = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filter Products"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Price"),
          CheckboxListTile(
            title: const Text("Below RM150"),
            value: price == "<150",
            onChanged: (val) {
              setState(() {
                price = val! ? "<150" : null;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Above RM150"),
            value: price == ">150",
            onChanged: (val) {
              setState(() {
                price = val! ? ">150" : null;
              });
            },
          ),
          const SizedBox(height: 8),
          const Text("Type"),
          CheckboxListTile(
            title: const Text("6mm"),
            value: type == "6mm",
            onChanged: (val) {
              setState(() {
                type = val! ? "6mm" : null;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("8mm"),
            value: type == "8mm",
            onChanged: (val) {
              setState(() {
                type = val! ? "8mm" : null;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("12.6mm"),
            value: type == "12.6mm",
            onChanged: (val) {
              setState(() {
                type = val! ? "12.6mm" : null;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onApply(price, type);
            Navigator.pop(context);
          },
          child: const Text("Apply"),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              price = null;
              type = null;
            });
          },
          child: const Text("Clear"),
        ),
      ],
    );
  }
}

// ProductTile using Firestore doc
class ProductTile extends StatelessWidget {
  final QueryDocumentSnapshot product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final data = product.data() as Map<String, dynamic>;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              data['image'],
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: (data['tags'] as List<dynamic>)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(tag,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              data['price'],
              style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
