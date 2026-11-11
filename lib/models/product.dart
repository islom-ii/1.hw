class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isUserCreated = false,
    this.colors = const ['Черный', 'Белый', 'Синий'],
    this.sizes = const ['S', 'M', 'L', 'XL'],
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final bool isUserCreated;
  final List<String> colors;
  final List<String> sizes;

  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final description = json['description'];
    final price = json['price'];
    final image = json['image'] ?? json['thumbnail'];

    if (id == null ||
        title is! String ||
        description is! String ||
        price is! num ||
        image is! String) {
      throw const FormatException('Некорректные данные товара');
    }

    return Product(
      id: id.toString(),
      title: title,
      description: description,
      price: price.toDouble(),
      imageUrl: image,
    );
  }

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class CartItem {
  const CartItem({
    required this.product,
    this.color,
    this.size,
  });

  final Product product;
  final String? color;
  final String? size;
}
