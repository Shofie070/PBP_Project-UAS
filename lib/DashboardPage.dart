import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../model/model.dart';
import '../../service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/app_router.dart';
import '../../service/theme_service.dart';

class DashboardPage extends StatefulWidget {
  final UserModel user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Service
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;
  final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Search & Filter
  String _searchQuery = "";
  String _selectedCategory = "All"; // Filter category
  List<Product> _allProducts = []; // Simpan semua data di sini
  List<Product> _filteredProducts = []; // Data yang ditampilkan
  bool _isLoading = true;
  String? _errorMessage;
  
  // Carousel
  int _carouselIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    _productsFuture = _apiService.getDashboardProducts().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Timeout - API terlalu lambat, menggunakan data lokal...');
      },
    );
    
    _productsFuture.then((products) {
      if (mounted) {
        setState(() {
          // Filter hanya clothing dan accessories
          _allProducts = products
              .where((p) => p.category.toLowerCase() == 'kaos' || 
                           p.category.toLowerCase() == 'hoodie' ||
                           p.category.toLowerCase() == 'aksesoris')
              .toList();
          _filteredProducts = _allProducts;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Tampilkan pesan yang lebih friendly
          _errorMessage = null; // Sembunyikan error karena sudah fallback ke mock
        });
      }
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty && _selectedCategory == "All") {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((p) {
          bool matchesSearch = query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase());
          bool matchesCategory = _selectedCategory == "All" || p.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;
        
        // Helper ukuran
        double responsiveSize(double mobileSp, double desktopPx) {
          return isDesktop ? desktopPx : mobileSp.sp;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9), // Latar abu sangat muda
          appBar: _buildAppBar(context, isDesktop, responsiveSize),
          drawer: _buildDrawer(context, responsiveSize),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 50, color: Colors.red),
                          const SizedBox(height: 20),
                          Text(_errorMessage!, style: const TextStyle(fontSize: 16, color: Colors.red)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _isLoading = true);
                              _loadData();
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- WELCOME MESSAGE ---
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 5.w,
                    vertical: isDesktop ? 20 : 2.h
                  ),
                  child: Text(
                    "Halooo ${widget.user.username}👋\nHari ini mau belanja apa nihh?",
                    style: TextStyle(
                      fontSize: responsiveSize(14, 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                    ),
                  ),
                ),

                // --- 1. SEARCH BAR ---
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 5.w, 
                    vertical: isDesktop ? 20 : 2.h
                  ),
                  child: TextField(
                    onChanged: _filterProducts,
                    decoration: InputDecoration(
                      hintText: "Search shoes, clothes...",
                      hintStyle: TextStyle(fontSize: responsiveSize(10, 14), color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey, size: responsiveSize(18, 22)),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor, // Warna tombol filter
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white, size: 20),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    ),
                  ),
                ),

                // --- 2. PROMO BANNER ---
                _buildPromoBanner(isDesktop, responsiveSize),

                // --- 3. JUDUL SECTION (Popular / New) ---
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 5.w,
                    vertical: isDesktop ? 20 : 2.h
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Popular Products",
                        style: TextStyle(
                          fontSize: responsiveSize(14, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87
                        ),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(
                          fontSize: responsiveSize(10, 14),
                          color: Colors.grey,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                ),

                // --- 4. GRID PRODUK ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 5.w),
                  child: _filteredProducts.isEmpty && _searchQuery.isNotEmpty
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("Produk tidak ditemukan"),
                        ))
                      : _buildProductGrid(isDesktop, responsiveSize),
                ),
                
                SizedBox(height: 5.h), // Spasi bawah
              ],
            ),
          ),
        );
      }
    );
  }

  // --- WIDGET GRID PRODUK ---
  Widget _buildProductGrid(bool isDesktop, Function responsiveSize) {
    if (_filteredProducts.isEmpty && _searchQuery.isEmpty) {
      // Masih loading data awal
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Scroll ikut parent
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 5 : 2, // 2 kolom di HP, 5 di Desktop
        crossAxisSpacing: isDesktop ? 20 : 4.w,
        mainAxisSpacing: isDesktop ? 20 : 4.w,
        childAspectRatio: 0.7, // Rasio kartu (agak tinggi)
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product, isDesktop, responsiveSize);
      },
    );
  }

  // --- WIDGET KARTU PRODUK (Satuan) ---
  Widget _buildProductCard(Product product, bool isDesktop, Function responsiveSize) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke detail
        context.push(AppRoutes.detailProduk, extra: {
          "name": product.name,
          "price": product.price,
          "image": product.image,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover, // Gambar cover
                        errorBuilder: (context, error, stackTrace) {
                          // Try load as asset if network fails
                          if (product.image.startsWith('assets/')) {
                            return Image.asset(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, err, stack) =>
                                  const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            );
                          }
                          return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
                        },
                      ),
                    ),
                  ),
                  // Tombol Love (Favorit)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, size: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            
            // Info Produk
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsiveSize(10, 14),
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatRupiah.format(product.price),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveSize(9, 13),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      // Tombol Plus kecil
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BANNER PROMO (CAROUSEL) ---
  Widget _buildPromoBanner(bool isDesktop, Function responsiveSize) {
    final List<String> carouselImages = [
      "assets/images/Hoodie1.png",
      "assets/images/Hoodie2.png",
      "assets/images/Kaos1.png",
      "assets/images/Kaos2.png",
    ];

    return Column(
      children: [
        // Carousel with PageView
        Container(
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 5.w),
          height: isDesktop ? 250 : 22.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // PageView untuk carousel
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _carouselIndex = index);
                },
                itemCount: carouselImages.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Background image dengan gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.purple.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Image.asset(
                            carouselImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image, color: Colors.grey),
                                  ),
                                ),
                          ),
                        ),
                        // Gradient overlay untuk text visibility
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Promo text
                        Positioned(
                          left: 20,
                          top: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Get the Special Discount",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsiveSize(12, 16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                "50% OFF",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsiveSize(28, 40),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                "Limited time only!",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: responsiveSize(10, 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Shop button di kanan bawah
              Positioned(
                right: 15,
                bottom: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Shop Now",
                    style: TextStyle(
                      color: Colors.purple.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            carouselImages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _carouselIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _carouselIndex == index
                    ? Colors.purple
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  // --- APP BAR ---
  AppBar _buildAppBar(BuildContext context, bool isDesktop, Function responsiveSize) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black), // Icon hamburger hitam
        title: Flexible(
          child: Row(
        children: [
          // Logo aplikasi
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'UW',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'Urban Wear',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 18 : 14.sp,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        ),
        ),
      centerTitle: false,
      actions: [
        // Cart button
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.black),
          onPressed: () => context.go(AppRoutes.cart),
        ),
        // Chat button
        IconButton(
          icon: const Icon(Icons.chat_bubble, color: Colors.black),
          onPressed: () {
            context.push(AppRoutes.chat, extra: {
              'userId': widget.user.id.toString(),
              'userName': widget.user.username,
              'userEmail': widget.user.email,
            });
          },
        ),
        // User Avatar (kanan)
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(Icons.person, color: Theme.of(context).primaryColor),
          ),
        )
      ],
    );
  }

  // --- DRAWER (Sama seperti sebelumnya) ---
  Widget _buildDrawer(BuildContext context, Function responsiveSize) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            accountName: Text(widget.user.username),
            accountEmail: Text(widget.user.email),
            currentAccountPicture: FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person));
                }
                final prefs = snap.data!;
                final b64 = prefs.getString('profile_image');
                if (b64 == null) {
                  return const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person));
                }
                try {
                  final bytes = base64Decode(b64);
                  return CircleAvatar(backgroundColor: Colors.white, backgroundImage: MemoryImage(bytes));
                } catch (_) {
                  return const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person));
                }
              },
            ),
          ),
          // Profile entry (tap to open profile page)
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profil"),
            onTap: () {
              Navigator.pop(context);
              // Pass user object directly; route will handle Map or UserModel
              context.push(AppRoutes.profile, extra: widget.user);
            },
          ),
          const Divider(),
          // Theme toggle
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.themeModeNotifier,
            builder: (context, mode, _) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: const Icon(Icons.dark_mode),
                value: mode == ThemeMode.dark,
                onChanged: (v) async {
                  await ThemeService().setThemeMode(v);
                },
              );
            },
          ),
          // Language selector
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: ValueListenableBuilder<String>(
              valueListenable: ThemeService.languageNotifier,
              builder: (context, lang, _) {
                String label = lang;
                switch (lang) {
                  case 'id': label = 'ID'; break;
                  case 'en': label = 'EN'; break;
                  case 'es': label = 'ES'; break;
                  case 'fr': label = 'FR'; break;
                  case 'de': label = 'DE'; break;
                }
                return Text(label);
              },
            ),
            onTap: () {
              // Show simple dialog with language choices
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('Select Language'),
                  children: [
                    SimpleDialogOption(
                      child: const Text('Indonesia (ID)'),
                      onPressed: () async { await ThemeService().setLanguage('id'); Navigator.pop(ctx); },
                    ),
                    SimpleDialogOption(
                      child: const Text('English (EN)'),
                      onPressed: () async { await ThemeService().setLanguage('en'); Navigator.pop(ctx); },
                    ),
                    SimpleDialogOption(
                      child: const Text('Español (ES)'),
                      onPressed: () async { await ThemeService().setLanguage('es'); Navigator.pop(ctx); },
                    ),
                    SimpleDialogOption(
                      child: const Text('Français (FR)'),
                      onPressed: () async { await ThemeService().setLanguage('fr'); Navigator.pop(ctx); },
                    ),
                    SimpleDialogOption(
                      child: const Text('Deutsch (DE)'),
                      onPressed: () async { await ThemeService().setLanguage('de'); Navigator.pop(ctx); },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text("Keranjang"),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.cart);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About Us"),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.about);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Riwayat Pembelian"),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.purchaseHistory);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('is_logged_in');
              await prefs.remove('current_user_email');
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }
}