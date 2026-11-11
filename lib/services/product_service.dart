import '../models/product.dart';

class ProductService {
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return const [
      Product(
        id: '1',
        title: 'Кроссовки Nike Air',
        description:
            'Удобные спортивные кроссовки для повседневной носки и тренировок.',
        price: 120,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
        category: 'Обувь',
      ),
      Product(
        id: '2',
        title: 'Смарт-часы Pro',
        description: 'Водонепроницаемые смарт-часы с трекером активности и пульсометром.',
        price: 85.50,
        imageUrl:
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
        category: 'Электроника',
      ),
      Product(
        id: '3',
        title: 'Рюкзак городской',
        description:
            'Вместительный рюкзак с отделением для ноутбука и защитой от воды.',
        price: 45,
        imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62',
        category: 'Аксессуары',
      ),
      Product(
        id: '4',
        title: 'Беспроводные наушники',
        description:
            'Стильные наушники с активным шумоподавлением и чистым звуком.',
        price: 99.99,
        imageUrl:
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
        category: 'Электроника',
      ),
      Product(
        id: '5',
        title: 'Солнцезащитные очки',
        description: 'Классические очки с поляризацией и защитой от ультрафиолета UV400.',
        price: 30,
        imageUrl:
            'https://images.unsplash.com/photo-1572635196237-14b3f281503f',
        category: 'Аксессуары',
      ),
    ];
  }
}
