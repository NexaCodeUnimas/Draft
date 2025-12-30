import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  final userCartRef = FirebaseFirestore.instance.collection('carts');

  List<CartItem> get items => _items;

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(Product product, {String color = ""}) {
    final index = _items.indexWhere(
        (item) => item.product.id == product.id && item.selectedColor == color);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product, selectedColor: color));
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Persist cart for a specific user
  Future<void> saveCart(String userId) async {
    final data = _items.map((e) => e.toMap()).toList();
    await userCartRef.doc(userId).set({'items': data});
  }

  Future<void> loadCart(String userId) async {
    final doc = await userCartRef.doc(userId).get();
    if (doc.exists) {
      final data = doc.data()?['items'] as List<dynamic>? ?? [];
      _items = [];
      for (var item in data) {
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(item['productId'])
            .get();
        if (productDoc.exists) {
          final product = Product.fromMap(productDoc.id, productDoc.data()!);
          _items.add(CartItem.fromMap(item, product));
        }
      }
      notifyListeners();
    }
  }
}
