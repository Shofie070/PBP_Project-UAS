import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../service/app_router.dart';
import '../../model/model.dart';

class DetailProduk extends StatefulWidget {
  final Map<String, dynamic> product;
  const DetailProduk({super.key, required this.product});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  late List<String> images;
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  double _userRating = 5.0;
  final TextEditingController _reviewController = TextEditingController();
  final List<Map<String, dynamic>> _reviews = [];
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p.containsKey('images') && p['images'] is List && (p['images'] as List).isNotEmpty) {
      images = List<String>.from(p['images']);
    } else if (p['image'] != null && (p['image'] is String)) {
      images = [p['image'] as String];
    } else {
      images = ['assets/images/placeholder.png'];
    }
    _loadReviews();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favorites_list') ?? [];
    bool isFav = false;
    final prodId = widget.product['id'];
    final prodName = widget.product['name'];
    for (final favStr in favList) {
      try {
        final favDecoded = jsonDecode(favStr);
        if (favDecoded is Map) {
          final favId = favDecoded['id'];
          final favName = favDecoded['name'] ?? favDecoded['title'];
          if ((favId != null && favId == prodId) || (favName != null && favName == prodName)) {
            isFav = true;
            break;
          }
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _isFavorite = isFav);
  }

  Future<String> _reviewKey() async {
    final id = widget.product['id']?.toString();
    final name = widget.product['name']?.toString();
    return 'reviews_${id ?? name ?? 'unknown'}';
  }

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _reviewKey();
    final list = prefs.getStringList(key) ?? [];
    _reviews.clear();
    if (list.isNotEmpty) {
      for (final s in list) {
        try {
          final decoded = jsonDecode(s);
          if (decoded is Map<String, dynamic>) _reviews.add(decoded);
        } catch (_) {}
      }
    } else if (widget.product['reviews'] is List) {
      for (final r in widget.product['reviews']) {
        _reviews.add({'rating': null, 'comment': r.toString(), 'date': ''});
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _submitReview() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _reviewKey();
    final list = prefs.getStringList(key) ?? [];
    final entry = {
      'rating': _userRating,
      'comment': _reviewController.text.trim(),
      'date': DateTime.now().toIso8601String(),
    };
    list.add(jsonEncode(entry));
    await prefs.setStringList(key, list);
    _reviewController.clear();
    await _loadReviews();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terima kasih atas ulasan Anda')));
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites_list') ?? [];
    
    if (_isFavorite) {
      // Remove from favorites
      final prodId = widget.product['id'];
      final prodName = widget.product['name'];
      for (var i = 0; i < list.length; i++) {
        try {
          final decoded = jsonDecode(list[i]);
          if (decoded is Map) {
            final id = decoded['id'];
            final name = decoded['name'] ?? decoded['title'];
            if ((id != null && id == prodId) || (name != null && name == prodName)) {
              list.removeAt(i);
              break;
            }
          }
        } catch (_) {}
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dihapus dari favorit')));
    } else {
      // Add to favorites
      final encoded = jsonEncode(widget.product);
      if (!list.contains(encoded)) list.add(encoded);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ditambahkan ke favorit')));
    }
    
    await prefs.setStringList('favorites_list', list);
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('cart_items') ?? [];
    final encoded = jsonEncode(widget.product);
    if (!list.contains(encoded)) list.add(encoded);
    await prefs.setStringList('cart_items', list);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk ditambahkan ke keranjang')));
  }

  void _buyNow() {
    double total = 0.0;
    final p = widget.product['price'];
    if (p is num) total = p.toDouble();
    else {
      try {
        total = double.parse(p.toString());
      } catch (_) {
        total = 0.0;
      }
    }
    
    // Create Product object from widget.product
    try {
      final product = Product.fromJson(widget.product);
      context.push(
        AppRoutes.payment,
        extra: {
          'products': [product],
          'totalAmount': total,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error preparing payment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return LayoutBuilder(builder: (context, constraints) {
      final bool isDesktop = constraints.maxWidth > 900;
      double responsiveSize(double mobileSp, double desktopPx) => isDesktop ? desktopPx : mobileSp.sp;
      final carouselHeight = isDesktop ? 420.0 : 46.h;
      final thumbnailHeight = isDesktop ? 72.0 : 10.w;
      final tabViewHeight = isDesktop ? 300.0 : 18.h;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
          title: Text(product['name'] ?? 'Detail Produk', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: responsiveSize(12, 18))),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 4.w, vertical: isDesktop ? 20 : 2.h),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 20 : 4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image carousel
                            Container(
                              height: carouselHeight,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: PageView.builder(
                                        controller: _pageController,
                                        onPageChanged: (i) => setState(() => _currentIndex = i),
                                        itemCount: images.length,
                                        itemBuilder: (ctx, i) {
                                          final src = images[i];
                                          if (src.startsWith('http')) {
                                            return Image.network(src, fit: BoxFit.contain);
                                          }
                                          return Image.asset(src, fit: BoxFit.contain);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isDesktop ? 12 : 1.h),
                                  SizedBox(
                                    height: thumbnailHeight,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: images.length,
                                      separatorBuilder: (_, __) => SizedBox(width: isDesktop ? 12 : 3.w),
                                      itemBuilder: (ctx, i) {
                                        final src = images[i];
                                        return GestureDetector(
                                          onTap: () {
                                            _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                            setState(() => _currentIndex = i);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: isDesktop ? 72 : 10.w,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: _currentIndex == i ? Theme.of(context).primaryColor : Colors.transparent, width: 2),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: src.startsWith('http') ? Image.network(src, fit: BoxFit.cover) : Image.asset(src, fit: BoxFit.cover),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isDesktop ? 20 : 2.h),

                            // Title, rating, brand, price
                            Text(product['name'] ?? '', style: TextStyle(fontSize: responsiveSize(14, 30), fontWeight: FontWeight.bold)),
                            SizedBox(height: isDesktop ? 12 : 1.h),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: responsiveSize(12, 18)),
                                SizedBox(width: isDesktop ? 10 : 2.w),
                                Text((product['rating'] is num) ? (product['rating'] as num).toStringAsFixed(1) : (product['rating']?.toString() ?? '0.0'), style: TextStyle(fontSize: responsiveSize(11, 16))),
                                SizedBox(width: isDesktop ? 16 : 4.w),
                                Text('•', style: TextStyle(fontSize: responsiveSize(10, 16), color: Colors.grey)),
                                SizedBox(width: isDesktop ? 16 : 4.w),
                                Text(product['brand'] ?? '', style: TextStyle(fontSize: responsiveSize(10, 16), color: Colors.grey)),
                                Spacer(),
                                Text(formatRupiah.format(product['price'] ?? 0), style: TextStyle(fontSize: responsiveSize(13, 28), fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                              ],
                            ),
                            SizedBox(height: isDesktop ? 20 : 2.h),

                            // Tabs
                            DefaultTabController(
                              length: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TabBar(
                                    labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                                    unselectedLabelColor: Colors.grey,
                                    indicatorColor: Theme.of(context).primaryColor,
                                    tabs: [
                                      Tab(text: 'About Item', iconMargin: EdgeInsets.zero),
                                      Tab(text: 'Reviews', iconMargin: EdgeInsets.zero),
                                    ],
                                  ),
                                  SizedBox(
                                    height: tabViewHeight,
                                    child: TabBarView(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: isDesktop ? 12 : 2.h),
                                          child: Text(product['description'] ?? 'Tidak ada deskripsi', style: TextStyle(fontSize: responsiveSize(12, 18), height: 1.4)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: isDesktop ? 12 : 2.h),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('User Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsiveSize(12, 18))),
                                                    const SizedBox(width: 12),
                                                    // Show rating indicator from library
                                                    if (product['rating'] != null)
                                                      RatingBarIndicator(
                                                        rating: (product['rating'] is num) ? (product['rating'] as num).toDouble() : double.tryParse(product['rating'].toString()) ?? 0.0,
                                                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                                        itemCount: 5,
                                                        itemSize: isDesktop ? 20 : 16,
                                                        direction: Axis.horizontal,
                                                      ),
                                                  ],
                                                ),
                                              SizedBox(height: isDesktop ? 12 : 1.h),
                                              if (_reviews.isNotEmpty)
                                                ...(_reviews.map((r) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if (r['rating'] != null)
                                                        SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: Row(
                                                            children: [
                                                              RatingBarIndicator(
                                                                rating: (r['rating'] as num).toDouble(),
                                                                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                                                itemCount: 5,
                                                                itemSize: isDesktop ? 18 : 14,
                                                              ),
                                                              const SizedBox(width: 8),
                                                            ],
                                                          ),
                                                        ),
                                                      Text(
                                                        r['comment'] ?? '',
                                                        style: TextStyle(fontSize: responsiveSize(12, 16)),
                                                        softWrap: true,
                                                      ),
                                                      if ((r['date'] ?? '') != '')
                                                        Text(
                                                          r['date'].toString(),
                                                          style: TextStyle(fontSize: responsiveSize(10, 12), color: Colors.grey),
                                                        ),
                                                    ],
                                                  ),
                                                )))
                                              else
                                                Text('Belum ada ulasan.', style: TextStyle(fontSize: responsiveSize(12, 16))),

                                              // Input form for new review
                                              const Divider(),
                                              Text('Tulis Ulasan Anda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsiveSize(12, 16))),
                                              SizedBox(height: 8),
                                              RatingBar.builder(
                                                initialRating: _userRating,
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: isDesktop ? 28 : 24,
                                                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                                onRatingUpdate: (r) => setState(() => _userRating = r),
                                              ),
                                              SizedBox(height: 8),
                                              TextField(
                                                controller: _reviewController,
                                                maxLines: 3,
                                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Tulis komentar (opsional)'),
                                              ),
                                              SizedBox(height: 8),
                                              ElevatedButton(onPressed: _submitReview, child: const Text('Kirim Ulasan')),
                                            ],
                                          ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom action bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 4.w, vertical: isDesktop ? 16 : 2.h),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  children: [
                    FloatingActionButton(
                      heroTag: 'fav',
                      onPressed: _toggleFavorite,
                      mini: true,
                      backgroundColor: Colors.white,
                      child: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: responsiveSize(18, 20)),
                    ),
                    SizedBox(width: isDesktop ? 16 : 4.w),
                    Expanded(
                      child: SizedBox(
                        height: isDesktop ? 56 : 6.h,
                        child: ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: Text('Add to Cart', style: TextStyle(fontSize: responsiveSize(14, 18), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 16 : 3.w),
                    SizedBox(
                      width: isDesktop ? 140 : 30.w,
                      height: isDesktop ? 56 : 6.h,
                      child: OutlinedButton(
                        onPressed: _buyNow,
                        style: OutlinedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Buy Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: responsiveSize(14, 18))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
