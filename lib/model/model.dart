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
      name: json['title'] ?? json['name'] ?? 'No Title',
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

// ============ CHAT MODELS ============

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromAdmin;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isFromAdmin,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isFromAdmin': isFromAdmin,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isFromAdmin: json['isFromAdmin'] ?? false,
    );
  }
}

class ChatRoom {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final bool isActive;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.messages,
    required this.createdAt,
    required this.lastMessageAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'messages': messages.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'lastMessageAt': lastMessageAt.toIso8601String(),
    'isActive': isActive,
  };

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final messagesList = (json['messages'] as List<dynamic>?)
        ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList() ?? [];
    
    return ChatRoom(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      messages: messagesList,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastMessageAt: DateTime.parse(json['lastMessageAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }
}