import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../../model/model.dart';
import '../../../../features/shared/routes/app_router.dart';

class FavoritPage extends StatefulWidget {
  const FavoritPage({super.key});

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  final List<Product> _favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites_list') ?? [];
    _favoriteItems.clear();
    for (final s in list) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) {
          _favoriteItems.add(Product.fromJson(decoded));
        } else if (decoded is Map) {
          _favoriteItems
              .add(Product.fromJson(Map<String, dynamic>.from(decoded)));
        }
      } catch (_) {}
    }
    if (mounted) setState(() {});
  }

  Future<void> _removeFromFavorites(int index) async {
    final p = _favoriteItems[index];
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites_list') ?? [];
    // Remove first matching entry by id or name
    for (var i = 0; i < list.length; i++) {
      try {
        final decoded = jsonDecode(list[i]);
        if (decoded is Map) {
          final id = decoded['id'];
          final name = decoded['name'] ?? decoded['title'];
          if ((id != null && id == p.id) || (name != null && name == p.name)) {
            list.removeAt(i);
            break;
          }
        }
      } catch (_) {}
    }
    await prefs.setStringList('favorites_list', list);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 900;
      double responsiveSize(double mobileSp, double desktopPx) =>
          isDesktop ? desktopPx : mobileSp.sp;

      return Scaffold(
        appBar: AppBar(
          toolbarHeight: isDesktop ? 100 : 10.h,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: responsiveSize(18, 24)),
            onPressed: () => context.go(AppRoutes.dashboard),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Favorit Saya',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: responsiveSize(14, 20),
                      fontWeight: FontWeight.bold)),
              SizedBox(height: isDesktop ? 6 : 0.5.h),
              Text('${_favoriteItems.length} Items',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: responsiveSize(10, 14))),
            ],
          ),
          centerTitle: true,
        ),
        body: _favoriteItems.isEmpty
            ? Center(
                child: Text('Belum ada item favorit',
                    style: TextStyle(fontSize: responsiveSize(12, 16))))
            : ListView.separated(
                padding: EdgeInsets.all(isDesktop ? 12 : 3.w),
                itemCount: _favoriteItems.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: isDesktop ? 12 : 1.5.h),
                itemBuilder: (context, index) {
                  final product = _favoriteItems[index];
                  final name = product.name;
                  final price = product.price;
                  final image = product.image;

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 12 : 3.w),
                      child: InkWell(
                        onTap: () {
                          context.push(AppRoutes.detailProduk, extra: product);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: isDesktop ? 96 : 20.w,
                              height: isDesktop ? 96 : 20.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[100]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: image.isNotEmpty
                                    ? (image.startsWith('http')
                                        ? Image.network(image,
                                            fit: BoxFit.cover)
                                        : Image.asset(image, fit: BoxFit.cover))
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            SizedBox(width: isDesktop ? 12 : 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: responsiveSize(12, 16))),
                                  SizedBox(height: isDesktop ? 6 : 0.5.h),
                                  Text('Category: ${product.category}',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: responsiveSize(10, 14))),
                                  SizedBox(height: isDesktop ? 8 : 1.h),
                                  Text('Rp ${price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: responsiveSize(11, 15))),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.favorite,
                                      color: Colors.red,
                                      size: responsiveSize(18, 24)),
                                  onPressed: () async {
                                    await _removeFromFavorites(index);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Dihapus dari favorit')));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}
