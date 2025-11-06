import 'package:flutter/material.dart';
import 'detail_produk.dart'; // default detail produk
import 'detail_kaos.dart';
import 'detail_hoodie.dart';
import 'kaos_data.dart';
import 'hoodie_data.dart';
import 'package:intl/intl.dart'; //

class ProductPage extends StatelessWidget {
  final String category;
  final Function(Map<String, dynamic>) onAddToCart;

  const ProductPage({
    super.key,
    required this.category,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil produk sesuai kategori
    List<Map<String, dynamic>> products;
    if (category.toLowerCase() == 'kaos') {
      products = kaosProducts.take(3).toList(); // Ambil 3 produk dari kaos
    } else if (category.toLowerCase() == 'hoodie') {
      products = hoodieProducts.take(3).toList(); // Ambil 3 produk dari hoodie
    } else {
      products = [
        {
          "name": "$category 1",
          "price": 100000,
          "image": "assets/images/product1.png"
        },
        {
          "name": "$category 2",
          "price": 120000,
          "image": "assets/images/product2.png"
        },
        {
          "name": "$category 3",
          "price": 150000,
          "image": "assets/images/product3.png"
        },
      ];
    }

    // ✅ Buat instance NumberFormat dari intl untuk format Rupiah
    final formatRupiah =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text("Produk $category"),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Daftar Produk
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
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
                      child: product["image"] != null
                          ? Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                product["image"],
                                fit: BoxFit.contain,
                              ),
                            )
                          : const Icon(Icons.image,
                              size: 60, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    product["name"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  // ✅ Gunakan intl di sini untuk format harga
                  subtitle: Text(
                    formatRupiah.format(product["price"]),
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
                    if (category.toLowerCase() == 'kaos') {
                      detailPage = DetailKaos(product: product);
                    } else if (category.toLowerCase() == 'hoodie') {
                      detailPage = DetailHoodie(product: product);
                    } else {
                      detailPage = DetailProduk(product: product);
                    }
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => detailPage),
                    );
                    if (result != null && result is Map<String, dynamic>) {
                      onAddToCart(result);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
