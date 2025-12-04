// Product Service dengan OOP Concepts:
// - Encapsulation: Private methods dan fields (_methodName, _fieldName)
// - Inheritance: Base ProductService yang bisa di-extend
// - Polymorphism: Virtual methods yang bisa di-override

import '../../../../model/model.dart';
import '../../../../service/api_service.dart';

/// Encapsulation: Base class dengan private fields dan methods
abstract class BaseProductService {
  /// Private field - hanya accessible dalam class ini
  final List<Product> _cachedProducts = [];

  /// Private method untuk cache management
  void _updateCache(List<Product> products) {
    _cachedProducts.clear();
    _cachedProducts.addAll(products);
  }

  /// Protected getter - accessible dari subclass
  List<Product> get cachedProducts => List.unmodifiable(_cachedProducts);

  /// Abstract method - harus di-implement oleh subclass (Polymorphism)
  Future<List<Product>> fetchProducts(String category);

  /// Abstract method untuk cart operations
  void addToCart(Product product);
  void removeFromCart(Product product);

  /// Common method
  bool isProductInCache(String productId) {
    return _cachedProducts.any((p) => p.id == productId);
  }
}

/// Inheritance: Konkret implementation dari BaseProductService
class ProductService extends BaseProductService {
  final ApiService _apiService;

  ProductService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<List<Product>> fetchProducts(String category) async {
    try {
      final products = await _apiService.getProductsByCategory(category);
      _updateCache(products);
      return products;
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final products = await _apiService.getDashboardProducts();
      _updateCache(products);
      return products;
    } catch (e) {
      throw Exception('Failed to fetch dashboard products: $e');
    }
  }

  @override
  void addToCart(Product product) {
    // Implementasi add to cart
  }

  @override
  void removeFromCart(Product product) {
    // Implementasi remove from cart
  }
}

/// Inheritance: Cart management dengan reusable logic
class CartManager {
  /// Private list - encapsulation
  final List<Product> _cartItems = [];

  /// Getter untuk readonly access
  List<Product> get cartItems => List.unmodifiable(_cartItems);
  int get itemCount => _cartItems.length;

  /// Method untuk add to cart
  void add(Product product) {
    if (!_cartItems.any((item) => item.id == product.id)) {
      _cartItems.add(product);
    }
  }

  /// Method untuk remove from cart
  void remove(Product product) {
    _cartItems.removeWhere((item) => item.id == product.id);
  }

  /// Private method untuk calculate total
  double _calculateSubtotal(List<Product> items) {
    return items.fold(0.0, (sum, item) => sum);
  }

  /// Public method yang menggunakan private method
  double get total => _calculateSubtotal(_cartItems);

  /// Clear cart
  void clear() {
    _cartItems.clear();
  }
}
