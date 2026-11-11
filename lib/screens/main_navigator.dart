import 'package:flutter/material.dart';

import '../models/product.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'favorites_screen.dart';

class MainNavigatorScreen extends StatefulWidget {
  const MainNavigatorScreen({super.key});

  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreen> {
  int _currentIndex = 0;
  final List<CartItem> _cartItems = [];
  final List<Product> _favoriteItems = [];

  void _toggleFavorite(Product product) {
    setState(() {
      if (_favoriteItems.contains(product)) {
        _favoriteItems.remove(product);
      } else {
        _favoriteItems.add(product);
      }
    });
  }

  void _addToCart(CartItem item) {
    setState(() => _cartItems.add(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Товар "${item.product.title}" добавлен в корзину!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(CartItem item) {
    setState(() => _cartItems.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CatalogScreen(
        favoriteItems: _favoriteItems,
        onToggleFavorite: _toggleFavorite,
        onAddToCart: _addToCart,
      ),
      FavoritesScreen(
        favoriteItems: _favoriteItems,
        onToggleFavorite: _toggleFavorite,
      ),
      CartScreen(cartItems: _cartItems, onRemoveFromCart: _removeFromCart),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _favoriteItems.isNotEmpty,
              label: Text('${_favoriteItems.length}'),
              child: const Icon(Icons.favorite),
            ),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _cartItems.isNotEmpty,
              label: Text('${_cartItems.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Корзина',
          ),
        ],
      ),
    );
  }
}
