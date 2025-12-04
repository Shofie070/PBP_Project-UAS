import '../../../shared/domain/entities/base_entity.dart';

// Base Product Class
class BaseProduct extends BaseEntity {
  final String name;
  final int price;
  final String image;
  final String description;
  final double rating;
  final String category;

  const BaseProduct({
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.rating,
    required this.category,
    String? id,
  }) : super(id: id);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'rating': rating,
      'category': category,
      'id': id,
    };
  }
}

// Concrete Product Class
class Product extends BaseProduct {
  const Product({
    required super.name,
    required super.price,
    required super.image,
    required super.description,
    required super.rating,
    required super.category,
    super.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: json['price'],
      image: json['image'],
      description: json['description'],
      rating: (json['rating'] as num).toDouble(),
      category: json['category'],
      id: json['id'],
    );
  }
}

// Inheritance: Premium Product
class PremiumProduct extends BaseProduct {
  final bool isExclusive;

  const PremiumProduct({
    required super.name,
    required super.price,
    required super.image,
    required super.description,
    required super.rating,
    required super.category,
    this.isExclusive = true,
    super.id,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['isExclusive'] = isExclusive;
    return json;
  }
}

// Inheritance: Sale Product
class SaleProduct extends BaseProduct {
  final double discount;

  const SaleProduct({
    required super.name,
    required super.price,
    required super.image,
    required super.description,
    required super.rating,
    required super.category,
    required this.discount,
    super.id,
  });

  double get discountedPrice => price * (1 - discount);
}
