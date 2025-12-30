import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  String selectedColor;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedColor = "",
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() => {
        'productId': product.id,
        'quantity': quantity,
        'selectedColor': selectedColor,
      };

  factory CartItem.fromMap(Map<String, dynamic> map, Product product) {
    return CartItem(
      product: product,
      quantity: map['quantity'] ?? 1,
      selectedColor: map['selectedColor'] ?? "",
    );
  }
}
