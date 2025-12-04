import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../../../service/api_service.dart';
import '../../../../model/model.dart';
import '../../../../features/shared/routes/app_router.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsif Desktop/Mobile
          bool isDesktop = constraints.maxWidth > 900;
          double responsiveSize(double mobileSp, double desktopPx) {
            return isDesktop ? desktopPx : mobileSp.sp;
          }

          return Stack(
            children: [
              // Background
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
                      // Padding Responsif
                      padding: EdgeInsets.all(isDesktop ? 20 : 2.w),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: isDesktop ? 15 : 1.h),
                          // Batasi lebar card di desktop agar tidak terlalu panjang
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: isDesktop ? 10 : 1.5.w,
                                    horizontal: isDesktop ? 20 : 3.w,
                                  ),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: isDesktop ? 80 : 15.w,
                                      height: isDesktop ? 80 : 15.w,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[800]
                                          : Colors.grey[100],
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: Image.network(
                                          product.image,
                                          fit: BoxFit
                                              .contain, // Agar gambar utuh
                                          loadingBuilder:
                                              (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(Icons.error,
                                                color: Colors.grey,
                                                size: isDesktop ? 40 : 8.w);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsiveSize(10, 16),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    formatRupiah.format(product.price),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                      fontSize: responsiveSize(9, 14),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: Theme.of(context).primaryColor,
                                    size: responsiveSize(20, 28),
                                  ),
                                  onTap: () {
                                    // Always navigate to detailProduk and pass the Product object
                                    context.push(AppRoutes.detailProduk,
                                        extra: product);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
