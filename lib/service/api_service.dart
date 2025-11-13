import 'package:dio/dio.dart';
import '../model/model.dart'; // Pastikan model ini sudah diperbarui (lihat di bawah)

class ApiService {
  final Dio _dio = Dio();
  // --- PERBAIKAN 1: Base URL diperbaiki (tanpa /products) ---
  final String _baseUrl = 'https://api.escuelajs.co/api/v1';

  Future<List<Product>> getProductsByCategory(String category) async {
    String apiCategoryId;
    if (category.toLowerCase() == 'kaos') {
      apiCategoryId = "1"; // Kategori "Clothes"
    } else if (category.toLowerCase() == 'hoodie') {
      apiCategoryId = "1"; // Kategori "Clothes"
    } else {
      apiCategoryId = "4"; // Kategori "Shoes" (atau "5" untuk "Miscellaneous")
    }

    try {
      String url = '$_baseUrl/products/?categoryId=$apiCategoryId';
      
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