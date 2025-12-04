import '../entities/product.dart';

abstract class CategoryRepository {
  List<Product> getProductsByCategory(String category);
}
