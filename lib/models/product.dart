class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final List<String> tags;
  final List<String> colors;
  final List<String> colorImages;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.tags = const [],
    this.colors = const [],
    this.colorImages = const [],
    this.description = "", required type,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: double.tryParse(data['price'].toString()) ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      colorImages: List<String>.from(data['colorImages'] ?? []),
      description: data['description'] ?? '', type: null,
    );
  }
}
