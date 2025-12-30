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
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Order Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...cart.items.map((item) => ListTile(
                    title: Text(item.product.name),
                    subtitle: Text("Color: ${item.selectedColor} x${item.quantity}"),
                    trailing: Text("RM ${item.totalPrice.toStringAsFixed(2)}"),
                  )),
              const Divider(),
              Text("Total: RM ${cart.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Payment Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: cardNumberController,
                      decoration: const InputDecoration(labelText: "Card Number"),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? "Enter card number" : null,
                    ),
                    TextFormField(
                      controller: cardHolderController,
                      decoration: const InputDecoration(labelText: "Cardholder Name"),
                      validator: (val) => val == null || val.isEmpty ? "Enter cardholder name" : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: mmController,
                            decoration: const InputDecoration(labelText: "MM"),
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? "MM" : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: yyController,
                            decoration: const InputDecoration(labelText: "YY"),
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? "YY" : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: cvvController,
                            decoration: const InputDecoration(labelText: "CVV"),
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? "CVV" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    isProcessing
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              setState(() => isProcessing = true);

                              // Save order to Firestore
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
                              });

                              // Clear cart
                              cart.clearCart();

                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Payment successful!")));
                              Navigator.popUntil(context, ModalRoute.withName('/home'));
                            },
                            child: const Text("Pay Now"),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
