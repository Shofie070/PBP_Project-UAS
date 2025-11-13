import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Pastikan ini di-import
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../service/api_service.dart';
import '../model/model.dart';
import '../service/app_router.dart'; // Pastikan ini di-import

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

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.getProductsByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produk ${widget.category}"),
        // --- INI PERBAIKANNYA ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {

            context.go(AppRoutes.dashboard);
          },
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
          FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Produk tidak ditemukan"));
              } else {
                final products = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(2.w),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final productMap = {
                      "name": product.name,
                      "price": product.price,
                      "image": product.image,
                    };

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // Ukuran gambar adaptif: desktop > mobile
                        final isWide = constraints.maxWidth > 600;
                        final double imageSize =
                            isWide ? 100 : 70; // px ukuran gambar

                        return Container(
                          margin: EdgeInsets.only(bottom: 1.5.h),
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
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 1.5.w,
                              horizontal: 3.w,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: imageSize,
                                height: imageSize,
                                color: Colors.grey[100],
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.cover, // Diubah kembali ke cover
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.error,
                                      color: Colors.grey,
                                      size: imageSize * 0.5,
                                    );
                                  },
                                ),
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isWide ? 12.sp : 10.sp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              formatRupiah.format(product.price),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: isWide ? 10.sp : 9.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).primaryColor,
                              size: isWide ? 28 : 22,
                            ),
                            onTap: () {
                              String routePath;
                              if (widget.category.toLowerCase() == 'kaos') {
                                routePath = AppRoutes.detailKaos;
                              } else if (widget.category.toLowerCase() ==
                                  'hoodie') {
                                routePath = AppRoutes.detailHoodie;
                              } else {
                                routePath = AppRoutes.detailProduk;
                              }
                              context.push(routePath, extra: productMap);
                            },
                          ),
                        );
                      },
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