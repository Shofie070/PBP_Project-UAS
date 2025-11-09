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
  final String image;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });

  // Fungsi untuk mapping JSON dari API ke Model Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['title'] ?? 'No Title', // 'title' dari API di-map ke 'name'
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // 'price' dari API
      image: json['image'] ?? '', // 'image' dari API
      category: json['category'] ?? 'Uncategorized', // 'category' dari API
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
  // tapi kita biarkan saja, mungkin dipakai di tempat lain.
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