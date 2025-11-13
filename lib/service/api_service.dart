import 'package:dio/dio.dart';
import '../model/model.dart'; 

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.escuelajs.co/api/v1';

  Future<List<Product>> getProductsByCategory(String category) async {
    String apiCategoryId;
    if (category.toLowerCase() == 'kaos') {
      apiCategoryId = "1"; 
    } else if (category.toLowerCase() == 'hoodie') {
      apiCategoryId = "1";
    } else {
      apiCategoryId = "4"; 
    }

    try {
      String url = '$_baseUrl/products/?categoryId=$apiCategoryId';
      
      Response response = await _dio.get(url);
      
      List<Product> products = (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
      
      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return []; 
    }
  }
}