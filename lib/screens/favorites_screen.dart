import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/product_image.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.favoriteItems,
    required this.onToggleFavorite,
  });

  final List<Product> favoriteItems;
  final ValueChanged<Product> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: favoriteItems.isEmpty
          ? const Center(child: Text('Список избранного пуст'))
          : ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final product = favoriteItems[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: ProductImage(
                      imageUrl: product.imageUrl,
                      width: 50,
                      height: 50,
                    ),
                    title: Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      tooltip: 'Убрать из избранного',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onToggleFavorite(product),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
