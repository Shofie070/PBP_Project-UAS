import 'package:dio/dio.dart';
import '../model/model.dart'; // Import model Product

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> getProductsByCategory(String category) async {
    
    String apiCategory;
    if (category.toLowerCase() == 'kaos') {
      apiCategory = "men's clothing"; 
    } else if (category.toLowerCase() == 'hoodie') {
      apiCategory = "women's clothing"; 
    } else {
      
      apiCategory = "jewelery"; 
    }

    try {
      // Panggil API pakai dio
      String url = '$_baseUrl/products/category/$apiCategory';
      Response response = await _dio.get(url);
      
      // Ubah data JSON (List) menjadi List<Product>
      List<Product> products = (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
      
      return products;
    } catch (e) {
      print('Error fetching products: $e');
      // Kembalikan list kosong jika error
      return []; 
    }
  }
}