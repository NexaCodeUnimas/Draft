import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProductDetailPage extends StatefulWidget {
  final String? productId;
  final bool isNew;

  const AdminProductDetailPage({super.key, this.productId, required this.isNew});

  @override
  State<AdminProductDetailPage> createState() => _AdminProductDetailPageState();
}

class _AdminProductDetailPageState extends State<AdminProductDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // New field

  List<String> colors = [];
  List<String> colorImages = [];

  @override
  void initState() {
    super.initState();
    if (!widget.isNew && widget.productId != null) {
      _loadProduct();
    }
  }

  void _loadProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['name'];
        _priceController.text = data['price'];
        _typeController.text = data['type'];
        _tagsController.text = (data['tags'] as List<dynamic>).join(', ');
        _imageController.text = data['image'];
        _descriptionController.text = data['description'] ?? ''; // Load description
        colors = List<String>.from(data['colors']);
        colorImages = List<String>.from(data['colorImages']);
      });
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final productData = {
      'name': _nameController.text,
      'price': _priceController.text,
      'type': _typeController.text,
      'tags': _tagsController.text.split(',').map((e) => e.trim()).toList(),
      'image': _imageController.text,
      'description': _descriptionController.text, // Save description
      'colors': colors,
      'colorImages': colorImages,
    };

    final collection = FirebaseFirestore.instance.collection('products');
    if (widget.isNew) {
      await collection.add(productData);
    } else {
      await collection.doc(widget.productId).update(productData);
    }

    Navigator.pop(context);
  }

  void _addColor() {
    final colorController = TextEditingController();
    final imageController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Color"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: colorController,
              decoration: const InputDecoration(labelText: "Color Name"),
            ),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: "Image Path (local assets)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (colorController.text.isNotEmpty && imageController.text.isNotEmpty) {
                setState(() {
                  colors.add(colorController.text);
                  colorImages.add(imageController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? "Add Product" : "Edit Product"),
        backgroundColor: Colors.orange,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ElevatedButton.icon(
              onPressed: _saveProduct,
              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
              label: const Text("Save", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
                validator: (v) => v == null || v.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price (RM)"),
                validator: (v) => v == null || v.isEmpty ? "Enter product price" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: "Type"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: "Tags (comma separated)"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: "Main Image Path (local assets)"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController, // New field
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Colors & Images"),
                  ElevatedButton(
                      onPressed: _addColor,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text("Add Color")),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: colors.length,
                itemBuilder: (_, index) => ListTile(
                  title: Text(colors[index]),
                  subtitle: Text(colorImages[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        colors.removeAt(index);
                        colorImages.removeAt(index);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
