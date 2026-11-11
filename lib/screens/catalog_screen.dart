import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_image.dart';
import 'add_product_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    required this.favoriteItems,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  final List<Product> favoriteItems;
  final ValueChanged<Product> onToggleFavorite;
  final ValueChanged<CartItem> onAddToCart;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  String _query = '';
  String _selectedCategory = 'Все';
  bool _isSearching = false;
  bool _isGrid = false;

  List<String> get _categories => [
    'Все',
    ..._allProducts.map((product) => product.category).toSet(),
  ];

  List<Product> get _filteredProducts {
    final query = _query.toLowerCase();
    return _allProducts
        .where(
          (product) =>
              (_selectedCategory == 'Все' ||
                  product.category == _selectedCategory) &&
              (_query.isEmpty || product.title.toLowerCase().contains(query)),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Product>> _loadProducts() async {
    final products = await _productService.fetchProducts();
    if (mounted) {
      setState(() {
        final userProducts = _allProducts.where(
          (product) => product.isUserCreated,
        );
        _allProducts = [...userProducts, ...products];
      });
    }
    return products;
  }

  Future<void> _openAddProductScreen() async {
    final product = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
    if (!mounted || product == null) return;

    setState(() {
      _allProducts.insert(0, product);
      _query = '';
      _selectedCategory = 'Все';
      _searchController.clear();
      _isSearching = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ваш товар опубликован в каталоге')),
    );
  }

  Future<void> _refreshProducts() async {
    final future = _loadProducts();
    setState(() => _productsFuture = future);
    await future;
  }

  void _filterProducts(String query) {
    setState(() => _query = query.trim());
  }

  Future<void> _showProductDetails(Product product) async {
    var isFavorite = widget.favoriteItems.contains(product);
    String? selectedColor = product.colors.isEmpty
        ? null
        : product.colors.first;
    String? selectedSize = product.sizes.isEmpty ? null : product.sizes.first;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ProductImage(
                      imageUrl: product.imageUrl,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          tooltip: isFavorite
                              ? 'Убрать из избранного'
                              : 'В избранное',
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            widget.onToggleFavorite(product);
                            setDialogState(() => isFavorite = !isFavorite);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(product.category),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (product.isUserCreated) ...[
                        const SizedBox(height: 8),
                        const Chip(
                          avatar: Icon(Icons.person_outline, size: 18),
                          label: Text('Ваш товар'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      if (product.colors.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Text(
                          'Выберите цвет:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: product.colors
                              .map(
                                (color) => ChoiceChip(
                                  label: Text(color),
                                  selected: selectedColor == color,
                                  onSelected: (_) => setDialogState(
                                    () => selectedColor = color,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (product.sizes.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Выберите размер:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: product.sizes
                              .map(
                                (size) => ChoiceChip(
                                  label: Text(size),
                                  selected: selectedSize == size,
                                  onSelected: (_) =>
                                      setDialogState(() => selectedSize = size),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Закрыть'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onAddToCart(
                  CartItem(
                    product: product,
                    color: selectedColor,
                    size: selectedSize,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('В корзину'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Заказ оформлен!${selectedColor == null ? '' : ' Цвет: $selectedColor,'}'
                      '${selectedSize == null ? '' : ' Размер: $selectedSize'}',
                    ),
                  ),
                );
              },
              child: const Text('Заказать'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Поиск...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: _filterProducts,
              )
            : const Text('Каталог товаров'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: _isGrid ? 'Показать списком' : 'Показать сеткой',
            icon: Icon(_isGrid ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          IconButton(
            tooltip: _isSearching ? 'Закрыть поиск' : 'Поиск',
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _query = '';
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Не удалось загрузить товары:\n${snapshot.error}'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        setState(() => _productsFuture = _loadProducts());
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = _filteredProducts;
          return Column(
            children: [
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: Colors.deepPurple.shade100,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.deepPurple.shade900
                              : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshProducts,
                  child: products.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 240,
                              child: Center(
                                child: Text(
                                  _allProducts.isEmpty
                                      ? 'Товары не найдены'
                                      : _query.isNotEmpty
                                      ? 'По запросу ничего не найдено'
                                      : 'В этой категории нет товаров',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        )
                      : _isGrid
                      ? _buildGrid(products)
                      : _buildList(products),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        tooltip: 'Продать свой товар',
        onPressed: _openAddProductScreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGrid(List<Product> products) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isFavorite = widget.favoriteItems.contains(product);
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showProductDetails(product),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ProductImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          tooltip: isFavorite
                              ? 'Убрать из избранного'
                              : 'В избранное',
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => widget.onToggleFavorite(product),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List<Product> products) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isFavorite = widget.favoriteItems.contains(product);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () => widget.onToggleFavorite(product),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
            onTap: () => _showProductDetails(product),
          ),
        );
      },
    );
  }
}
