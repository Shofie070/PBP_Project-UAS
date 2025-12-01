import 'dart:convert';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/model.dart';
import '../../service/api_service.dart';
import '../../service/app_router.dart';
import '../../service/theme_service.dart';
import '../../service/localization_service.dart';

// Sorting modes for product listing
enum SortMode { none, priceAsc, priceDesc, ratingDesc }

class DashboardPage extends StatefulWidget {
  final UserModel user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;
  final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Search & Filter
  String _searchQuery = "";
  String _selectedCategory = "All";
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _usingLocalFallback = false;
  List<String> _categories = ["All"];
  bool _showingAll = false; // when false show only popular subset initially

  // Carousel
  int _carouselIndex = 0;
  final PageController _pageController = PageController();
  late Timer _autoSlideTimer;
  // Per-slide accent colors to match promo images
  final List<Color> _carouselAccentColors = [
    Color(0xFF3EA3FF), // blue-ish
    Color(0xFF8E44FF), // purple
    Color(0xFF2ECC71), // green
    Color(0xFFF39C12), // orange
  ];
  Color _currentAccentColor = Color(0xFF8E44FF);
  late final AnimationController _avatarController;
  late final Animation<double> _avatarScaleAnim;
  // Sorting
  SortMode _sortMode = SortMode.none;

  List<Product> _applySort(List<Product> list) {
    final copied = List<Product>.from(list);
    switch (_sortMode) {
      case SortMode.priceAsc:
        copied.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortMode.priceDesc:
        copied.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortMode.ratingDesc:
        copied.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortMode.none:
        break;
    }
    return copied;
  }

  // Favorites & cart (stored in SharedPreferences)
  final Set<int> _favoriteIds = {};

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites_list') ?? [];
    setState(() {
      _favoriteIds.clear();
      for (final jsonStr in favs) {
        try {
          final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
          final product = Product.fromJson(jsonMap);
          _favoriteIds.add(product.id);
        } catch (e) {
          // Skip malformed JSON
        }
      }
    });
  }

  void _toggleFavorite(Product p) async {
    final prefs = await SharedPreferences.getInstance();
    final favsList = prefs.getStringList('favorites_list') ?? [];
    
    // Check if product is already favorited by ID
    bool isFavorited = false;
    int favoriteIndex = -1;
    for (int i = 0; i < favsList.length; i++) {
      try {
        final jsonMap = jsonDecode(favsList[i]) as Map<String, dynamic>;
        final product = Product.fromJson(jsonMap);
        if (product.id == p.id) {
          isFavorited = true;
          favoriteIndex = i;
          break;
        }
      } catch (e) {
        // Skip malformed JSON
      }
    }
    
    // Toggle: remove if favorited, add if not
    if (isFavorited && favoriteIndex >= 0) {
      favsList.removeAt(favoriteIndex);
      setState(() {
        _favoriteIds.remove(p.id);
      });
      await prefs.setStringList('favorites_list', favsList);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dihapus dari favorit')));
    } else {
      // Add product as JSON to favorites_list
      final encoded = jsonEncode(p.toJson());
      favsList.add(encoded);
      await prefs.setStringList('favorites_list', favsList);
      setState(() {
        _favoriteIds.add(p.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ditambahkan ke favorit')));
    }
  }

  Future<void> _addToCart(Product p) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('cart_items') ?? [];
    // store product json
    final encoded = jsonEncode(p.toJson());
    if (!list.contains(encoded)) list.add(encoded);
    await prefs.setStringList('cart_items', list);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk ditambahkan ke keranjang')));
  }

  bool _isLaptopProduct(Product p) {
    final n = p.name.toLowerCase();
    // Common laptop keywords / models / brands to exclude
    final keywords = [
      'laptop', 'macbook', 'notebook', 'dell', 'asus', 'lenovo', 'hp', 'xps', 'zenbook', 'surface',
      'thinkpad', 'ideapad', 'acer', 'predator', 'alienware', 'mac pro', 'macbook pro', 'chromebook'
    ];
    for (final k in keywords) {
      if (n.contains(k)) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoSlide();
    _avatarController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _avatarScaleAnim = Tween<double>(begin: 1.0, end: 1.18).animate(CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut));
    // load favorites from prefs
    _loadPrefs();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && _pageController.hasClients) {
        final nextPage = (_carouselIndex + 1) % _carouselAccentColors.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onCarouselPageChanged(int index) {
    // update current accent color and make avatar blink briefly
    setState(() {
      _carouselIndex = index;
      _currentAccentColor = _carouselAccentColors[index % _carouselAccentColors.length];
    });
    // trigger avatar pulse explicitly
    _avatarController.forward().then((_) {
      if (!mounted) return;
      _avatarController.reverse();
    });
  }

  void _loadData() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _usingLocalFallback = false;
    });

    _productsFuture = _apiService.getDashboardProducts().timeout(const Duration(seconds: 15), onTimeout: () => []);

    _productsFuture.then((products) {
      if (!mounted) return;
      // Deteksi fallback lokal
      bool fallback = false;
      if (products.isNotEmpty && products.first.image.startsWith('assets/')) {
        fallback = true;
      }
      // Ambil kategori unik (Kaos, Hoodie, Aksesoris)
  // Use a fixed set of filters: All, Popular, Pakaian, Aksesoris, Sepatu
  final categories = ["All", "Popular", "Pakaian", "Aksesoris", "Sepatu"];
      // Pastikan Aksesoris selalu ada kalau ada di data
      if (!categories.contains("Aksesoris") && products.any((p) => p.category == "Aksesoris")) {
        categories.add("Aksesoris");
      }
      setState(() {
        // Remove laptop-like products from global list so they don't appear anywhere
        final visibleProducts = products.where((p) => !_isLaptopProduct(p)).toList();
        _allProducts = visibleProducts;
        // Determine which categories are allowed to be displayed as "all"/popular per user request
        final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'}; // show-only categories for View All
        if (_selectedCategory == 'Popular' || (!_showingAll && _selectedCategory == 'All')) {
          // Popular subset: top-rated items in allowed categories (use visibleProducts without laptops)
          final popular = visibleProducts.where((p) => allowedShow.contains(p.category)).toList();
          popular.sort((a, b) => b.rating.compareTo(a.rating));
          _filteredProducts = _applySort(popular.take(6).toList());
        } else if (_showingAll || _selectedCategory == 'All') {
          // Show all allowed categories (when toggled to show all or when 'All' explicitly selected)
          _filteredProducts = _applySort(visibleProducts.where((p) => allowedShow.contains(p.category)).toList());
        } else {
          // Specific category selected (Pakaian/Aksesoris/Sepatu)
          _filteredProducts = _applySort(visibleProducts.where((p) => p.category == _selectedCategory).toList());
        }
        _isLoading = false;
        _usingLocalFallback = fallback;
        _categories = categories;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _allProducts = [];
        _filteredProducts = [];
        _usingLocalFallback = true;
      });
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      // Determine base list depending on selected filter and showing mode
      final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'};

      List<Product> baseList;
      if (_selectedCategory == 'Popular' || (!_showingAll && _selectedCategory == 'All')) {
        // popular subset: top-rated items in allowed categories
  final pop = _allProducts.where((p) => allowedShow.contains(p.category) && !_isLaptopProduct(p)).toList();
        pop.sort((a, b) => b.rating.compareTo(a.rating));
        baseList = pop;
      } else if (_selectedCategory != 'All') {
        baseList = _allProducts.where((p) => p.category == _selectedCategory).toList();
      } else {
        // 'All' and showing all: full allowed set
  baseList = _allProducts.where((p) => allowedShow.contains(p.category) && !_isLaptopProduct(p)).toList();
      }

      // Apply search and sort
      if (query.isEmpty) {
        _filteredProducts = _applySort(List.from(baseList));
      } else {
        _filteredProducts = _applySort(baseList.where((p) {
          return p.name.toLowerCase().contains(query.toLowerCase());
        }).toList());
      }
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      // Reset to initial Popular view
                      setState(() {
                        _selectedCategory = 'Popular';
                        _showingAll = false;
                        final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'};
                        final pop = _allProducts.where((p) => allowedShow.contains(p.category) && !_isLaptopProduct(p)).toList();
                        pop.sort((a, b) => b.rating.compareTo(a.rating));
                        _filteredProducts = _applySort(pop.take(6).toList());
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Clear'),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final selected = _selectedCategory == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (sel) {
                      setState(() {
                        _selectedCategory = c;
                        if (c == 'Popular') {
                          _showingAll = false;
                          final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'};
                          final pop = _allProducts.where((p) => allowedShow.contains(p.category) && !_isLaptopProduct(p)).toList();
                          pop.sort((a, b) => b.rating.compareTo(a.rating));
                          _filteredProducts = _applySort(pop.take(6).toList());
                        } else if (c == 'All') {
                          _showingAll = true;
                          final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'};
                          _filteredProducts = _applySort(_allProducts.where((p) => allowedShow.contains(p.category) && !_isLaptopProduct(p)).toList());
                        } else {
                          // specific category selected -> show all in that category
                          _showingAll = true;
                          _filteredProducts = _applySort(_allProducts.where((p) => p.category == c).toList());
                        }
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ThemeService.languageNotifier,
      builder: (context, currentLang, _) {
        return LayoutBuilder(builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 900;

          double responsiveSize(double mobileSp, double desktopPx) => isDesktop ? desktopPx : mobileSp.sp;

          final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardColor = isDark
              ? Theme.of(context).cardColor
              : Colors.grey[200]!; // Pergelap kartu di light mode
          final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
          // Compute a readable foreground color on top of the current accent
          final accentOnColor = _currentAccentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Custom leading with hamburger menu + logo
              leadingWidth: isDesktop ? 180 : 200,
              leading: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: Icon(Icons.menu, color: textColor, size: 28),
                        tooltip: 'Menu',
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 8 : 4),
                    // Logo text dengan Flexible agar responsif
                    Flexible(
                      child: Text(
                        'UrbanWear',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 18 : 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Use theme text color for the title so it is readable in both light and dark modes
              title: Text('Home', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        tooltip: 'Keranjang',
                        onPressed: () {
                          context.push(AppRoutes.cart);
                        },
                      ),
                      FutureBuilder<SharedPreferences>(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snap) {
                          if (!snap.hasData) return const SizedBox.shrink();
                          final prefs = snap.data!;
                          final cartList = prefs.getStringList('cart_items') ?? [];
                          if (cartList.isEmpty) return const SizedBox.shrink();
                          return Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                              child: Text(cartList.length.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Chat button next to cart
                IconButton(
                  icon: const Icon(Icons.chat_bubble),
                  tooltip: 'Chat',
                  onPressed: () {
                    context.push(AppRoutes.chat, extra: {
                      'userId': widget.user.id.toString(),
                      'userName': widget.user.username,
                      'userEmail': widget.user.email,
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.profile, extra: widget.user);
                    },
                    child: FutureBuilder<SharedPreferences>(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return ScaleTransition(
                            scale: _avatarScaleAnim,
                            child: CircleAvatar(
                              radius: isDesktop ? 18 : 16,
                              backgroundImage: const AssetImage('assets/images/logo.png'),
                              backgroundColor: Colors.grey[300],
                            ),
                          );
                        }
                        final prefs = snap.data!;
                        final b64 = prefs.getString('profile_image');
                        
                        if (b64 != null && b64.isNotEmpty) {
                            try {
                              final bytes = base64Decode(b64);
                              return ScaleTransition(
                                scale: _avatarScaleAnim,
                                child: CircleAvatar(
                                  radius: isDesktop ? 18 : 16,
                                  backgroundImage: MemoryImage(bytes),
                                ),
                              );
                            } catch (_) {
                              return ScaleTransition(
                                scale: _avatarScaleAnim,
                                child: CircleAvatar(
                                  radius: isDesktop ? 18 : 16,
                                  backgroundImage: const AssetImage('assets/images/logo2.png'),
                                  backgroundColor: Colors.grey[300],
                                ),
                              );
                            }
                        }
                        
                        return ScaleTransition(
                          scale: _avatarScaleAnim,
                          child: CircleAvatar(
                            radius: isDesktop ? 18 : 16,
                            backgroundImage: const AssetImage('assets/images/logo2.png'),
                            backgroundColor: Colors.grey[300],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            drawer: _buildDrawer(context, currentLang),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 5.w, vertical: isDesktop ? 10 : 1.h),
                            child: Text(
                              "${LocalizationService.get(currentLang, 'welcome')} ${widget.user.username}👋\n${LocalizationService.get(currentLang, 'shopping')}",
                              style: TextStyle(fontSize: responsiveSize(14, 18), fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ),

                          // Search & Filter Row
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 5.w, vertical: isDesktop ? 20 : 2.h),
                            child: Row(
                              children: [
                                // Search field
                                Expanded(
                                  child: Container(
                                    height: isDesktop ? 48 : 44,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: TextField(
                                      onChanged: _filterProducts,
                                      style: TextStyle(color: textColor),
                                      decoration: InputDecoration(
                                        hintText: LocalizationService.get(currentLang, 'search'),
                                        hintStyle: TextStyle(fontSize: responsiveSize(10, 14), color: Colors.grey),
                                        prefixIcon: Icon(Icons.search, color: Colors.grey, size: responsiveSize(18, 22)),
                                        filled: false,
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Filter button - follow carousel accent color
                                Material(
                                  color: _currentAccentColor,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () => _showFilterSheet(),
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      height: isDesktop ? 48 : 44,
                                      width: isDesktop ? 48 : 44,
                                      child: Icon(
                                        Icons.filter_list,
                                        color: accentOnColor,
                                        size: isDesktop ? 26 : 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Indikator fallback data lokal
                          if (_usingLocalFallback)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 5.w, vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, color: Colors.orange, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Data produk gagal dimuat dari API, menampilkan data lokal.',
                                      style: TextStyle(color: Colors.orange, fontSize: responsiveSize(8, 12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Promo banner / carousel
                          _buildPromoBanner(isDesktop, responsiveSize, currentLang),

                          // Header
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 5.w, vertical: isDesktop ? 20 : 2.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Header title: change according to selected filter and sort
                                Builder(builder: (ctx) {
                                  String headerBase = _selectedCategory == 'All'
                                      ? LocalizationService.get(currentLang, 'popular')
                                      : _selectedCategory;
                                  String sortSuffix = '';
                                  if (_sortMode == SortMode.priceAsc) sortSuffix = ' • Harga: Rendah';
                                  if (_sortMode == SortMode.priceDesc) sortSuffix = ' • Harga: Tinggi';
                                  if (_sortMode == SortMode.ratingDesc) sortSuffix = ' • Rating';
                                  return Text(
                                    '$headerBase$sortSuffix',
                                    style: TextStyle(fontSize: responsiveSize(14, 20), fontWeight: FontWeight.bold, color: textColor),
                                  );
                                }),
                                // Right-side actions: show 'View All' text on initial main page,
                                // but when the user filters/searches (i.e. a filter is active),
                                // hide that text and display the sort icon in its place.
                                Builder(builder: (ctx) {
                                  final bool isFilteredActive = _selectedCategory != 'All' || _searchQuery.isNotEmpty;
                                  // When not filtered (initial main page), show the 'View All' text button
                                  // alongside the sort icon. When filtered, hide the text and move the
                                  // sort icon into the same place (so only the sort icon is visible).
                                  if (!isFilteredActive) {
                                    return Row(
                                      children: [
                                        // Sort menu (icon)
                                        PopupMenuButton<SortMode>(
                                          tooltip: 'Sort',
                                          onSelected: (mode) {
                                            setState(() {
                                              _sortMode = mode;
                                              // Ensure full dataset when sorting so user sees full results
                                              _showingAll = true;
                                              _filteredProducts = _applySort(_allProducts.where((p) => {'Pakaian', 'Aksesoris', 'Sepatu'}.contains(p.category)).toList());
                                            });
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(value: SortMode.none, child: Text('Default')),
                                            const PopupMenuItem(value: SortMode.priceAsc, child: Text('Harga: Rendah → Tinggi')),
                                            const PopupMenuItem(value: SortMode.priceDesc, child: Text('Harga: Tinggi → Rendah')),
                                            const PopupMenuItem(value: SortMode.ratingDesc, child: Text('Rating: Tinggi')),
                                          ],
                                          icon: Icon(Icons.sort, color: Colors.grey, size: responsiveSize(16, 20)),
                                        ),
                                        const SizedBox(width: 8),
                                        // 'View All' text shown on the main page (clickable)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _showingAll = true;
                                              _selectedCategory = 'All';
                                              _filteredProducts = _applySort(_allProducts.where((p) => {'Pakaian', 'Aksesoris', 'Sepatu'}.contains(p.category) && !_isLaptopProduct(p)).toList());
                                            });
                                          },
                                          child: Text(
                                            LocalizationService.get(currentLang, 'viewAll'),
                                            style: TextStyle(color: Colors.grey, fontSize: responsiveSize(10, 14)),
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  // Filter is active: show only the sort icon in the same spot
                                  return PopupMenuButton<SortMode>(
                                    tooltip: 'Sort',
                                    onSelected: (mode) {
                                      setState(() {
                                        _sortMode = mode;
                                        // When sorting while filtered, keep filtered dataset and apply sort
                                        _filteredProducts = _applySort(_filteredProducts);
                                      });
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(value: SortMode.none, child: Text('Default')),
                                      const PopupMenuItem(value: SortMode.priceAsc, child: Text('Harga: Rendah → Tinggi')),
                                      const PopupMenuItem(value: SortMode.priceDesc, child: Text('Harga: Tinggi → Rendah')),
                                      const PopupMenuItem(value: SortMode.ratingDesc, child: Text('Rating: Tinggi')),
                                    ],
                                    icon: Icon(Icons.sort, color: Colors.grey, size: responsiveSize(16, 20)),
                                  );
                                }),
                              ],
                            ),
                          ),

                          // Grid
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 5.w),
                            child: _filteredProducts.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        LocalizationService.get(currentLang, 'notFound'),
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  )
                                : _buildProductGrid(isDesktop, responsiveSize, cardColor, textColor),
                          ),

                          SizedBox(height: 5.h),
                        ],
                      ),
                    ),
                  ),
          );
        });
      },
    );
  }

  Widget _buildProductGrid(bool isDesktop, Function responsiveSize, Color cardColor, Color textColor) {
    if (_filteredProducts.isEmpty) return const Center(child: CircularProgressIndicator());

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 5 : 2,
        crossAxisSpacing: isDesktop ? 20 : 4.w,
        mainAxisSpacing: isDesktop ? 20 : 4.w,
        childAspectRatio: 0.7,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product, isDesktop, responsiveSize, cardColor, textColor);
      },
    );
  }

  Widget _buildProductCard(Product product, bool isDesktop, Function responsiveSize, Color cardColor, Color textColor) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.detailProduk, extra: product.toJson()),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            color: Colors.grey[100],
                            child: Image.network(
                              product.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                if (product.image.startsWith('assets/')) {
                                  return Image.asset(
                                    product.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => const Center(
                                      child: Icon(Icons.broken_image, color: Color.fromARGB(255, 221, 68, 68)),
                                    ),
                                  );
                                }
                                return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
                              },
                            ),
                          ),
                        ),
                        // Price badge top-left
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              formatRupiah.format(product.price),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: responsiveSize(8, 12)),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: responsiveSize(10, 14),
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Kategori di bawah nama produk
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category.toString(),
                          style: TextStyle(
                            fontSize: responsiveSize(7, 9),
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 6),
                              Text(product.rating.toStringAsFixed(1), style: TextStyle(fontSize: responsiveSize(8, 11), color: Colors.grey[700])),
                            ],
                          ),
                          InkWell(
                            onTap: () => _addToCart(product),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            // Favorite heart in top-right separated to float above image
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: () {
                  _toggleFavorite(product);
                },
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Icon(
                    _favoriteIds.contains(product.id) ? Icons.favorite : Icons.favorite_border,
                    color: _favoriteIds.contains(product.id) ? Colors.red : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner(bool isDesktop, Function responsiveSize, String lang) {
    final List<String> carouselImages = [
      "assets/images/Hoodie1.png",
      "assets/images/Hoodie2.png",
      "assets/images/Kaos3.png",
      "assets/images/Kaos2.png",
    ];

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 5.w),
          height: isDesktop ? 280 : 22.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ScrollConfiguration(
              behavior: _DesktopScrollBehavior(),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => _onCarouselPageChanged(index),
                itemCount: carouselImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      // Image with fit: BoxFit.contain for desktop, cover for mobile
                      Container(
                        color: Colors.grey[200],
                        child: Image.asset(
                          carouselImages[index],
                          fit: isDesktop ? BoxFit.contain : BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (ctx, e, st) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
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
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              carouselImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _carouselIndex == index ? 24 : 8,
                height: 8,
                  decoration: BoxDecoration(
                    color: _carouselIndex == index ? _currentAccentColor : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, String lang) {
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
                  return const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey),
                  );
                }
                final prefs = snap.data!;
                final b64 = prefs.getString('profile_image');
                if (b64 == null) {
                  return const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey),
                  );
                }
                try {
                  final bytes = base64Decode(b64);
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: MemoryImage(bytes),
                  );
                } catch (_) {
                  return const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey),
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profil"),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.profile, extra: widget.user);
            },
          ),
          const Divider(),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.themeModeNotifier,
            builder: (context, mode, _) {
              return SwitchListTile(
                title: Text(LocalizationService.get(lang, 'darkMode')),
                secondary: const Icon(Icons.dark_mode),
                value: mode == ThemeMode.dark,
                onChanged: (v) async => await ThemeService().setThemeMode(v),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(LocalizationService.get(lang, 'language')),
            subtitle: Text(lang == 'id' ? 'Indonesia' : 'English'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: Text(LocalizationService.get(lang, 'language')),
                  children: [
                    SimpleDialogOption(
                      child: const Text('Indonesia (ID)'),
                      onPressed: () async {
                        await ThemeService().setLanguage('id');
                        Navigator.pop(ctx);
                        if (context.mounted) setState(() {});
                      },
                    ),
                    SimpleDialogOption(
                      child: const Text('English (EN)'),
                      onPressed: () async {
                        await ThemeService().setLanguage('en');
                        Navigator.pop(ctx);
                        if (context.mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Riwayat Pembelian'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.purchaseHistory);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorit'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.favorit);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About Us"),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.about);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              LocalizationService.get(lang, 'logout'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('is_logged_in');
              await prefs.remove('current_user_email');
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autoSlideTimer.cancel();
    _pageController.dispose();
    _avatarController.dispose();
    super.dispose();
  }
}

class _DesktopScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}