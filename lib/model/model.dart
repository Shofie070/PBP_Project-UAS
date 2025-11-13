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

class Product {
  final int id;
  final String name; 
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

  factory Product.fromJson(Map<String, dynamic> json) {
    

    String imageUrl = '';
    if (json['images'] != null && 
        json['images'] is List && 
        (json['images'] as List).isNotEmpty) {
      imageUrl = (json['images'] as List)[0];
    } else if (json['image'] != null) {
      imageUrl = json['image'];
    }

    String categoryName = 'Uncategorized';
    if (json['category'] != null && json['category'] is Map) {
      categoryName = json['category']['name'] ?? 'Uncategorized';
    } else if (json['category'] != null && json['category'] is String) {
      categoryName = json['category'];
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['title'] ?? 'No Title',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: imageUrl, 
      category: categoryName,
    );
  }
}


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