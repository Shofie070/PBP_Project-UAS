import 'package:flutter/material.dart';
import 'detail_produk.dart';
import 'detail_kaos.dart';
import 'detail_hoodie.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'model/model.dart';

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
  late Future<List<Product>> _productsFuture;
  final ApiService _apiService = ApiService();
  final formatRupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // SEARCH & SORT
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = "Nama A-Z";

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.getProductsByCategory(widget.category);
    _searchController.addListener(() => setState(() {})); // real-time filter
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(), // Pakai tema gelap
      child: Scaffold(
        extendBodyBehindAppBar: true, // Agar background menyatu ke atas
        appBar: AppBar(
          title: Text(
            "Produk ${widget.category}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.7), // Hitam Transparan
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Image
            Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),

            // 2. Overlay Gelap (Supaya tulisan terbaca)
            Container(color: Colors.black.withOpacity(0.7)),

            // 3. Konten Utama
            Column(
              children: [
                // Spacer untuk AppBar karena pakai extendBodyBehindAppBar
                const SizedBox(height: 100),

                // SEARCH + SORT BAR
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                              color: Colors.black), // Teks input hitam
                          decoration: InputDecoration(
                            hintText: "Cari ${widget.category}...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white, // Tetap putih agar kontras
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Sort Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E), // Abu Gelap Solid
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white24), // Border tipis
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            icon: const Icon(Icons.sort, color: Colors.white),
                            dropdownColor:
                                const Color(0xFF1E1E1E), // Menu dropdown gelap
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            items: [
                              "Nama A-Z",
                              "Nama Z-A",
                              "Harga Terendah",
                              "Harga Tertinggi",
                            ]
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) {
                              setState(() => _sortBy = val!);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // LIST PRODUK
                Expanded(
                  child: FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text("Error: ${snapshot.error}",
                                style: const TextStyle(color: Colors.white)));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text("Produk kosong",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)));
                      }

                      var products = snapshot.data!;
                      var query = _searchController.text.toLowerCase();
                      var filtered = products
                          .where((p) => p.name.toLowerCase().contains(query))
                          .toList();

                      // LOGIKA SORTING
                      if (_sortBy == "Nama A-Z") {
                        filtered.sort((a, b) => a.name.compareTo(b.name));
                      } else if (_sortBy == "Nama Z-A") {
                        filtered.sort((a, b) => b.name.compareTo(a.name));
                      } else if (_sortBy == "Harga Terendah") {
                        filtered.sort((a, b) => a.price.compareTo(b.price));
                      } else if (_sortBy == "Harga Tertinggi") {
                        filtered.sort((a, b) => b.price.compareTo(a.price));
                      }

                      if (filtered.isEmpty) {
                        return const Center(
                            child: Text("Produk tidak ditemukan",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          final productMap = {
                            "name": product.name,
                            "price": product.price,
                            "image": product.image,
                          };

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E), // Kartu Gelap
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white10), // Border halus
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .white, // Background putih utk gambar
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.network(
                                  product.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (_, child, progress) =>
                                      progress == null
                                          ? child
                                          : const SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.black),
                                              ),
                                            ),
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey),
                                ),
                              ),
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white), // Judul Putih
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  formatRupiah.format(product.price),
                                  style: const TextStyle(
                                      color:
                                          Colors.white70, // Harga Putih Redup
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white54,
                                  size: 20),
                              onTap: () async {
                                Widget detailPage;
                                if (widget.category.toLowerCase() == 'kaos') {
                                  detailPage = DetailKaos(product: productMap);
                                } else if (widget.category.toLowerCase() ==
                                    'hoodie') {
                                  detailPage =
                                      DetailHoodie(product: productMap);
                                } else {
                                  detailPage =
                                      DetailProduk(product: productMap);
                                }

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => detailPage),
                                );

                                if (result is Map<String, dynamic>) {
                                  widget.onAddToCart(result);
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
