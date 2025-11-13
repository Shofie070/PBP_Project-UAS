import 'package:flutter/material.dart';

class DrawerItem {
  final String title;
  final IconData icon;
  final void Function(BuildContext) onTap;

  DrawerItem({required this.title, required this.icon, required this.onTap});
}

class UserModel {
  final String username;
  final String email;

  UserModel({required this.username, required this.email});
}

// --- PERUBAHAN DI SINI ---
class Product {
  final int id;
  final String name; // di API namanya 'title'
  final double price;
  final String image; // Kita tetap simpan 1 gambar (gambar pertama)
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });

  // --- PERBAIKAN 4: Fungsi mapping JSON diperbarui ---
  factory Product.fromJson(Map<String, dynamic> json) {
    
    // API baru (api.escuelajs.co) mengirim 'images' sebagai List/Array
    // Kita ambil gambar pertama dari list itu.
    String imageUrl = '';
    if (json['images'] != null && 
        json['images'] is List && 
        (json['images'] as List).isNotEmpty) {
      imageUrl = (json['images'] as List)[0];
    } else if (json['image'] != null) {
      // Fallback jika ada API lama (fakestoreapi)
      imageUrl = json['image'];
    }

    // API baru juga punya 'category' di dalam objek
    String categoryName = 'Uncategorized';
    if (json['category'] != null && json['category'] is Map) {
      categoryName = json['category']['name'] ?? 'Uncategorized';
    } else if (json['category'] != null && json['category'] is String) {
      categoryName = json['category'];
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['title'] ?? 'No Title', // API ini pakai 'title', sama seperti fakestore
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: imageUrl, // Ambil gambar pertama dari list
      category: categoryName,
    );
  }
}
// --- BATAS PERUBAHAN ---


class DashboardModel {
  final String title;
  final String? icon;
  final Function()? onTap;

  DashboardModel({this.title = '', this.icon, this.onTap});

  // Dummy cartModel getter
  List<Map<String, dynamic>> get cartModel => [];

  // Data statis ini sudah tidak terpakai oleh 'product.dart'
  List<Product> get products => [
        Product(
            id: 1,
            name: 'Kaos 1',
            price: 100000,
            image: 'assets/images/Kaos1.png',
            category: 'Kaos'),
        Product(
            id: 2,
            name: 'Kaos 2',
            price: 120000,
            image: 'assets/images/Kaos2.png',
            category: 'Kaos'),
      ];
}

class CategoryRepository {
  static List<String> getCategories() {
    return ["Kaos", "Hoodie", "Aksesoris"];
  }
}