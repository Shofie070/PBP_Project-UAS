import 'package:dio/dio.dart';
import '../model/model.dart';

class ApiService {
  final Dio _dio;
  // Ganti ke DummyJSON biar stabil
  final String _baseUrl = 'https://dummyjson.com';

  ApiService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ));

  static List<Product> getMockProducts() {
    return [
      Product(
          id: '1',
          name: 'Kaos Polos Hitam',
          price: 75000,
          image: 'assets/images/Kaos1.png',
          category: 'Kaos',
          description: 'Kaos polos hitam berkualitas tinggi.',
          rating: 4.5),
      Product(
          id: '2',
          name: 'Hoodie Urban Navy',
          price: 250000,
          image: 'assets/images/Hoodie1.png',
          category: 'Hoodie',
          description: 'Hoodie nyaman untuk gaya urban.',
          rating: 4.8),
      Product(
          id: '3',
          name: 'Kaos Graphic Art',
          price: 120000,
          image: 'assets/images/Kaos2.png',
          category: 'Kaos',
          description: 'Kaos dengan desain grafis artistik.',
          rating: 4.2),
      Product(
          id: '4',
          name: 'Topi Snapback',
          price: 50000,
          image: 'assets/images/hoodie2.png',
          category: 'Aksesoris',
          description: 'Topi snapback keren.',
          rating: 4.0),
    ];
  }

  Future<List<Product>> getDashboardProducts() async {
    try {
      final response = await _dio.get('$_baseUrl/products?limit=100');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['products'];

        List<Product> products = data.map((json) {
          // --- LOGIKA MAPPING KATEGORI BIAR SESUAI APLIKASI ---
          String rawCategory =
              (json['category'] ?? '').toString().toLowerCase();
          String title = (json['title'] ?? '').toString().toLowerCase();
          String appCategory = 'Lainnya'; // Default

          // Deteksi Sepatu
          if (rawCategory.contains('shoe') ||
              rawCategory.contains('sneaker') ||
              title.contains('shoe') ||
              title.contains('sneaker')) {
            appCategory = 'Sepatu';
          }

          // Deteksi Celana (pants/jeans/trouser)
          else if (rawCategory.contains('pant') ||
              rawCategory.contains('jean') ||
              rawCategory.contains('trouser') ||
              title.contains('pants') ||
              title.contains('jeans')) {
            appCategory = 'Celana';
          }

          // Deteksi Pakaian / Kaos (shirt/top/t-shirt)
          else if (rawCategory.contains('shirt') ||
              rawCategory.contains('top') ||
              title.contains('t-shirt') ||
              title.contains('shirt')) {
            appCategory = 'Pakaian';
          }

          // Deteksi Aksesoris (Watch, Jewelry, Bag, Sunglasses)
          else if (rawCategory.contains('watch') ||
              rawCategory.contains('jewel') ||
              rawCategory.contains('bag') ||
              rawCategory.contains('sunglass') ||
              title.contains('watch') ||
              title.contains('jam')) {
            appCategory = 'Aksesoris';
          }

          // Deteksi Hoodie explicitly by title/keywords
          if (title.contains('hoodie') ||
              title.contains('sweat') ||
              title.contains('jacket')) {
            appCategory = 'Hoodie';
          }

          // Biar hoodie tetep ada isinya, kalau ID kelipatan 5 dan dia Pakaian, jadikan Hoodie
          if (appCategory == 'Pakaian' && (json['id'] as int) % 5 == 0) {
            appCategory = 'Hoodie';
          }

          // Konversi harga USD ke IDR (asumsi kurs 15.000)
          double price = ((json['price'] as num?)?.toDouble() ?? 0) * 15000;

          return Product(
            id: json['id'].toString(),
            name: json['title'],
            price: price.toInt(),
            image: json['thumbnail'], // Gambar dari API
            category: appCategory,
            description: json['description'] ?? '',
            rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

        // Return all mapped products (Dashboard will decide which to show as "popular" vs "view all")
        if (products.isNotEmpty) return products;
      }

      return getMockProducts();
    } catch (e) {
      // print('API Error: $e');
      return getMockProducts();
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      List<Product> all = await getDashboardProducts();
      return all
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      return getMockProducts();
    }
  }
}
