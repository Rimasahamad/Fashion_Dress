class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.description,
  });

  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: (data['name'] ?? '').toString(),
      price: (data['price'] ?? 0).toDouble(),
      category: (data['category'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(), // ✅ fixed
      description: (data['description'] ?? '').toString(),
    );
  }
}