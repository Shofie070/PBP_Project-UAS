import 'package:flutter/material.dart';
import 'detail_produk.dart'; // default detail produk
import 'detail_kaos.dart';
import 'detail_hoodie.dart';
// HAPUS IMPORT DATA STATIS
// import 'kaos_data.dart';
// import 'hoodie_data.dart';
import 'package:intl/intl.dart'; 

// IMPORT SERVICE DAN MODEL BARU
import 'api_service.dart';
import 'model/model.dart';


// 1. UBAH JADI STATEFULWIDGET
class ProductPage extends StatefulWidget {
  final String category;
  final Function(Map<String, dynamic>) onAddToCart;

  const ProductPage({
    super.key,
    required this.category,
    required this.onAddToCart,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // 2. BUAT VARIABEL UNTUK API
  late Future<List<Product>> _productsFuture;
  final ApiService _apiService = ApiService();
  final formatRupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // 3. PANGGIL API SAAT HALAMAN DIBUKA
    _productsFuture = _apiService.getProductsByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    // 4. HAPUS SEMUA LOGIKA 'products' STATIS
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Produk ${widget.category}"),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 5. GANTI LISTVIEW DENGAN FUTUREBUILDER
          FutureBuilder<List<Product>>(
            future: _productsFuture, // Ambil data dari API
            builder: (context, snapshot) {
              // Saat loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } 
              // Jika ada error
              else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } 
              // Jika data kosong
              else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Produk tidak ditemukan"));
              } 
              // Jika data sukses
              else {
                final products = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index]; // Ini model Product

                    // Siapkan data Map untuk halaman detail
                    final productMap = {
                      "name": product.name,
                      "price": product.price,
                      "image": product.image,
                      // kamu bisa tambahkan field lain jika perlu
                    };

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 110,
                            height: 110,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              
                              // 6. GANTI IMAGE.ASSET JADI IMAGE.NETWORK
                              child: Image.network(
                                product.image, // Ambil gambar dari URL API
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error, color: Colors.grey);
                                },
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          product.name, // Ambil dari model Product
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 2, // Batasi nama produk jadi 2 baris
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          formatRupiah.format(product.price), // Ambil dari model Product
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.pinkAccent,
                          size: 30,
                        ),
                        onTap: () async {
                          Widget detailPage;
                          // 'productMap' sekarang datanya dari API
                          // Logika ini masih sama kayak kodemu
                          if (widget.category.toLowerCase() == 'kaos') {
                            detailPage = DetailKaos(product: productMap);
                          } else if (widget.category.toLowerCase() == 'hoodie') {
                            detailPage = DetailHoodie(product: productMap);
                          } else {
                            // Aksesoris akan pakai DetailProduk (default)
                            detailPage = DetailProduk(product: productMap);
                          }
                          
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => detailPage),
                          );
                          if (result != null && result is Map<String, dynamic>) {
                            widget.onAddToCart(result);
                          }
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}