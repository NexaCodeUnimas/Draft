import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../provider/cart_provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map<String, dynamic>? productData;
  bool isLoading = true;
  String displayedImage = '';
  String selectedColorName = '';
  int quantity = 1;
  double unitPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    if (doc.exists) {
      setState(() {
        productData = doc.data();
        displayedImage = productData!['image'];
        selectedColorName = productData!['colors'][0];
        unitPrice = double.tryParse(
                productData!['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
            0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || productData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalPrice = (unitPrice * quantity).toStringAsFixed(2);
    final description = productData!['description'] ?? "No description available";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Product Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                displayedImage,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(productData!['name'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: (productData!['tags'] as List<dynamic>)
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(tag, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text(productData!['price'],
                style: const TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 28)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade700),
              ),
              child: Text(description),
            ),
            const SizedBox(height: 12),
            Text('Color: $selectedColorName',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(productData!['colors'].length, (index) {
                  final colorName = productData!['colors'][index];
                  final isSelected = selectedColorName == colorName;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColorName = colorName;
                        displayedImage = productData!['colorImages'][index];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange.shade200 : Colors.grey.shade200,
                        border: Border.all(
                            color: isSelected ? Colors.orange : Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          colorName,
                          style: TextStyle(
                            color: isSelected ? Colors.orange.shade900 : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Quantity:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                      ),
                      Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("Total: RM $totalPrice",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final cart = context.read<CartProvider>();
                  cart.addItem(Product.fromMap(widget.productId, productData!),
                      color: selectedColorName);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Added to cart!')));
                },
                child: const Text("Add to Cart",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
