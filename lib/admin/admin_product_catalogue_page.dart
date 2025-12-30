import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_product_detail_page.dart';

class AdminProductCataloguePage extends StatefulWidget {
  const AdminProductCataloguePage({super.key});

  @override
  State<AdminProductCataloguePage> createState() =>
      _AdminProductCataloguePageState();
}

class _AdminProductCataloguePageState
    extends State<AdminProductCataloguePage> {
  String searchQuery = '';

  void _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Product deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productRef = FirebaseFirestore.instance.collection('products');

    return Stack(
      children: [
        Column(
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
            // Products list
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

                  if (docs.isEmpty) {
                    return const Center(child: Text("No products found."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final product = docs[index];
                      final colors = List<String>.from(product['colors'] ?? []);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminProductDetailPage(
                                productId: product.id,
                                isNew: false,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.asset(
                                  product['image'],
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children:
                                          (product['tags'] as List<dynamic>)
                                              .map((tag) => Container(
                                                    padding:
                                                        const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 6,
                                                            vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.orange.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(tag,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black)),
                                                  ))
                                              .toList(),
                                    ),
                                    const SizedBox(height: 6),
                                    // Color preview
                                    SizedBox(
                                      height: 24,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: colors.length,
                                        itemBuilder: (_, i) {
                                          return Container(
                                            margin:
                                                const EdgeInsets.only(right: 6),
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: Center(
                                              child: Text(
                                                colors[i][0],
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product['price'],
                                      style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.orange, size: 20),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AdminProductDetailPage(
                                                  productId: product.id,
                                                  isNew: false,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red, size: 20),
                                          onPressed: () {
                                            _deleteProduct(product.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
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
        // Floating add button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminProductDetailPage(
                    isNew: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
