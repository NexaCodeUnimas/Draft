import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final cardNumberController = TextEditingController();
  final cardHolderController = TextEditingController();
  final mmController = TextEditingController();
  final yyController = TextEditingController();
  final cvvController = TextEditingController();
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Summary
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...cart.items.map(
              (item) => Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Color: ${item.selectedColor}\nQuantity: ${item.quantity}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    "RM ${item.totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const Divider(thickness: 1.2),
            Text(
              "Total: RM ${cart.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 20),

            // Payment Info
            const Text(
              "Payment Info",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(
                      labelText: "Card Number",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter card number" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cardHolderController,
                    decoration: const InputDecoration(
                      labelText: "Cardholder Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter cardholder name"
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: mmController,
                          decoration: const InputDecoration(
                            labelText: "MM",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                              val == null || val.isEmpty ? "MM" : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: yyController,
                          decoration: const InputDecoration(
                            labelText: "YY",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                              val == null || val.isEmpty ? "YY" : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: cvvController,
                          decoration: const InputDecoration(
                            labelText: "CVV",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                              val == null || val.isEmpty ? "CVV" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Modern Pay Now Button
                  isProcessing
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;

                              setState(() => isProcessing = true);

                              try {
                                // 1. Save order to Firestore
                                final ordersRef = FirebaseFirestore.instance.collection('orders');
                                await ordersRef.add({
                                  'userId': user?.uid ?? '',
                                  'items': cart.items.map((e) => e.toMap()).toList(),
                                  'total': cart.totalAmount,
                                  'timestamp': FieldValue.serverTimestamp(),
                                  'payment': {
                                    'cardNumber': cardNumberController.text,
                                    'cardHolder': cardHolderController.text,
                                    'mm': mmController.text,
                                    'yy': yyController.text,
                                    'cvv': cvvController.text,
                                  },
                                  'status': 'pending', // Important for FR-20 tracking
                                });

                                // 2. Clear the cart
                                cart.clearCart();

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Payment successful!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  // 3. FIXED NAVIGATION: Clear stack and go to Home
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/home',
                                        (route) => false, // This ensures every other screen is removed
                                  );
                                }
                              } catch (e) {
                                // 4. ERROR HANDLING: Reset loading state if Firestore fails
                                if (mounted) {
                                  setState(() => isProcessing = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Payment failed: $e"), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Pay Now",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
