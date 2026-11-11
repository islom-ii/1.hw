import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/product_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onRemoveFromCart,
  });

  final List<CartItem> cartItems;
  final ValueChanged<CartItem> onRemoveFromCart;

  @override
  Widget build(BuildContext context) {
    final totalPrice = cartItems.fold<double>(
      0,
      (total, item) => total + item.product.price,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Корзина пуста'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final product = item.product;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
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
                          subtitle: Text(
                            [
                              '\$${product.price.toStringAsFixed(2)}',
                              if (item.color != null) 'Цвет: ${item.color}',
                              if (item.size != null) 'Размер: ${item.size}',
                            ].join(' • '),
                          ),
                          trailing: IconButton(
                            tooltip: 'Удалить из корзины',
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => onRemoveFromCart(item),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: const Border(
                      top: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Итого: \$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Заказ успешно оформлен!'),
                            ),
                          );
                        },
                        child: const Text('Оформить заказ'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
