abstract class BaseEntity {
  final int _id;

  BaseEntity({required int id}) : _id = id;

  int get id => _id;
  Map<String, dynamic> toJson();
  bool isValid();
}
class UserModel extends BaseEntity {
  final String username;
  final String email;
  final String _password;

  UserModel({
    int id = 0,
    required this.username,
    required this.email,
    String password = '',
  })  : _password = password,
        super(id: id);
  String get hashedPassword => _encryptPassword(_password);

  static String _encryptPassword(String password) {
    return 'hashed_$password';
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
      };

  /// Factory constructor from JSON/Map (to safely parse data coming from routes or APIs)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as int?) ?? 0,
      username: (json['username'] ?? json['name'] ?? 'Guest') as String,
      email: (json['email'] ?? '') as String,
      password: (json['password'] ?? '') as String,
    );
  }


  @override
  bool isValid() {
    return username.isNotEmpty && email.contains('@');
  }
}

abstract class BaseProduct extends BaseEntity {
  final String name;
  final double price;
  final String image;
  final String category;
  final double _rating;
  final int _stock;

  BaseProduct({
    required int id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    int stock = 0,
    double rating = 0.0,
  })  : _stock = stock,
        _rating = rating,
        super(id: id);


  int get stock => _stock;
  double get rating => _rating;
  double calculateDiscount();
  String getDescription();
  bool isInStock() => _stock > 0;
}


class Product extends BaseProduct {
  @override
  double calculateDiscount() {
    return 0;
  }

  @override
  String getDescription() => 'Standard Product: $name';

  Product({
    required int id,
    required String name,
    required double price,
    required String image,
    required String category,
    int stock = 0,
    double rating = 0.0,
  }) : super(
    id: id,
    name: name,
    price: price,
    image: image,
    category: category,
    stock: stock,
    rating: rating,
  );

  /// Factory constructor untuk API mapping
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['title'] ?? 'No Title',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      stock: json['stock'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Override toJson (POLYMORPHISM)
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
        'category': category,
    'stock': stock,
    'rating': rating,
      };

  /// Override validation
  @override
  bool isValid() {
    return name.isNotEmpty && price > 0 && image.isNotEmpty;
  }
}


class PremiumProduct extends BaseProduct {
  final double _premiumMultiplier;

  PremiumProduct({
    required int id,
    required String name,
    required double price,
    required String image,
    required String category,
    int stock = 0,
    double premiumMultiplier = 1.2,
  })  : _premiumMultiplier = premiumMultiplier,
        super(
          id: id,
          name: name,
          price: price,
          image: image,
          category: category,
          stock: stock,
        );

  /// Override method dengan berbeda logic (POLYMORPHISM)
  @override
  double calculateDiscount() {
    return price * 0.1; // Premium products dapat 10% discount
  }

  @override
  String getDescription() => 'Premium Product: $name (x$_premiumMultiplier)';

  /// Premium specific method
  double getPremiumPrice() => price * _premiumMultiplier;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
        'category': category,
        'stock': stock,
        'premium_multiplier': _premiumMultiplier,
      };

  @override
  bool isValid() {
    return name.isNotEmpty && price > 0 && image.isNotEmpty && _premiumMultiplier > 1.0;
  }
}

class SaleProduct extends BaseProduct {
  final double discountPercentage;

  SaleProduct({
    required int id,
    required String name,
    required double price,
    required String image,
    required String category,
    int stock = 0,
    this.discountPercentage = 0.2,
  }) : super(
    id: id,
    name: name,
    price: price,
    image: image,
    category: category,
    stock: stock,
  );

  /// Override dengan logic yang berbeda (POLYMORPHISM)
  @override
  double calculateDiscount() => price * discountPercentage;

  @override
  String getDescription() =>
      'Sale Product: $name (${(discountPercentage * 100).toInt()}% off)';

  /// Sale specific method
  double getFinalPrice() => price - calculateDiscount();

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
        'category': category,
        'stock': stock,
        'discount_percentage': discountPercentage,
      };

  @override
  bool isValid() {
    return name.isNotEmpty &&
        price > 0 &&
        image.isNotEmpty &&
        discountPercentage >= 0 &&
        discountPercentage <= 1.0;
  }
}



class DashboardModel {
  final String title;
  final String? icon;
  final Function()? onTap;

  DashboardModel({this.title = '', this.icon, this.onTap});

  // Dummy cartModel getter
  List<Map<String, dynamic>> get cartModel => [];

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