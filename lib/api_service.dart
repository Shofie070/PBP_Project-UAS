import 'package:dio/dio.dart';
import 'model/model.dart'; // Import model Product

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://fakestoreapi.com';

  // Fungsi untuk mengambil produk berdasarkan kategori
  Future<List<Product>> getProductsByCategory(String category) async {
    
    // API-nya pakai "men's clothing" & "women's clothing"
    // Kita mapping kategori dari app kamu ke kategori API
    String apiCategory;
    if (category.toLowerCase() == 'kaos') {
      apiCategory = "men's clothing"; // Kaos kita anggap Baju Pria
    } else if (category.toLowerCase() == 'hoodie') {
      apiCategory = "women's clothing"; // Hoodie kita anggap Baju Wanita
    } else {
      // Kategori "Aksesoris" di API-nya "jewelery"
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