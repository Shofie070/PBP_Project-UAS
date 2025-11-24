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
    return Scaffold(
      appBar: AppBar(
        title: Text("Produk ${widget.category}"),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // SEARCH + SORT BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Cari ${widget.category}...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.95),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        icon: const Icon(Icons.sort, color: Colors.white),
                        dropdownColor: Colors.pinkAccent,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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

            // LIST PRODUK DENGAN FUTUREBUILDER
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Produk kosong",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)));
                  }

                  var products = snapshot.data!;
                  var query = _searchController.text.toLowerCase();
                  var filtered = products
                      .where((p) => p.name.toLowerCase().contains(query))
                      .toList();

                  // SORTING
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
                        child: Text("Ga ada yang cocok",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)));
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4))
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.image,
                              width: 110,
                              height: 110,
                              fit: BoxFit.contain,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                      ? child
                                      : const CircularProgressIndicator(),
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            formatRupiah.format(product.price),
                            style: const TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.pinkAccent, size: 30),
                          onTap: () async {
                            Widget detailPage;
                            if (widget.category.toLowerCase() == 'kaos') {
                              detailPage = DetailKaos(product: productMap);
                            } else if (widget.category.toLowerCase() ==
                                'hoodie') {
                              detailPage = DetailHoodie(product: productMap);
                            } else {
                              detailPage = DetailProduk(product: productMap);
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
      ),
    );
  }
}
