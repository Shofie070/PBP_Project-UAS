import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:urban_wear_app/features/shared/services/localization_service.dart';
import 'package:urban_wear_app/features/shared/routes/app_router.dart';
import 'package:urban_wear_app/features/auth/domain/entities/user.dart';
import 'package:urban_wear_app/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:urban_wear_app/features/cart/presentation/cubit/cart_state.dart';
import 'package:urban_wear_app/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:urban_wear_app/features/home/presentation/cubit/dashboard_state.dart';
import 'package:urban_wear_app/features/product/domain/entities/product.dart';
import 'package:urban_wear_app/service/api_service.dart';
import 'package:urban_wear_app/features/shared/services/theme_service.dart';

class DashboardPage extends StatefulWidget {
  final UserModel user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 1000);
  Timer? _autoSlideTimer;
  final formatRupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  late final AnimationController _avatarController;
  late final Animation<double> _avatarScaleAnim;
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  // Carousel Images
  final List<String> _carouselImages = [
    "assets/images/Hoodie1.png",
    "assets/images/Hoodie2.png",
    "assets/images/Kaos2.png",
  ];

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _avatarScaleAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
        CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut));
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _pageController.hasClients) {
        int nextPage = (_pageController.page?.round() ?? 0) + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _showFilterSheet(
      BuildContext context, DashboardState state, String currentLang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                  const Text('Filter',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      context.read<DashboardCubit>().selectCategory('Popular');
                      Navigator.pop(ctx);
                    },
                    child: Text(LocalizationService.get(currentLang, 'clear')),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.categories.map((c) {
                  final selected = state.selectedCategory == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (sel) {
                      context.read<DashboardCubit>().selectCategory(c);
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
    return BlocProvider(
      create: (context) =>
          DashboardCubit(ApiService())..loadDashboardData(widget.user),
      child: BlocListener<DashboardCubit, DashboardState>(
        listenWhen: (previous, current) =>
            previous.carouselIndex != current.carouselIndex,
        listener: (context, state) {
          // Trigger avatar animation on slide change
          _avatarController.forward().then((_) {
            if (!mounted) return;
            _avatarController.reverse();
          });
        },
        child: ValueListenableBuilder<String>(
          valueListenable: ThemeService.languageNotifier,
          builder: (context, currentLang, _) {
            return LayoutBuilder(builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth > 900;

              double responsiveSize(double mobileSp, double desktopPx) =>
                  isDesktop ? desktopPx : mobileSp.sp;

              final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final cardColor =
                  isDark ? Theme.of(context).cardColor : Colors.grey[200]!;
              final textColor = Theme.of(context).textTheme.bodyLarge?.color ??
                  Colors.black87;

              return AddToCartAnimation(
                cartKey: cartKey,
                height: 30,
                width: 30,
                opacity: 0.85,
                dragAnimation: const DragToCartAnimationOptions(
                  rotation: true,
                ),
                jumpAnimation: const JumpAnimationOptions(),
                createAddToCartAnimation: (runAddToCartAnimation) {
                  this.runAddToCartAnimation = runAddToCartAnimation;
                },
                child: Scaffold(
                  backgroundColor: backgroundColor,
                  appBar: _buildAppBar(context, isDesktop, responsiveSize,
                      textColor, currentLang),
                  drawer: _buildDrawer(context, currentLang),
                  body: BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, state) {
                      // Compute a readable foreground color on top of the current accent
                      final accentOnColor =
                          state.currentAccentColor.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white;

                      if (state.status == DashboardStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return RefreshIndicator(
                        onRefresh: () async => context
                            .read<DashboardCubit>()
                            .loadDashboardData(widget.user),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 40 : 5.w,
                                    vertical: isDesktop ? 10 : 1.h),
                                child: Text(
                                  "${LocalizationService.get(currentLang, 'welcome')} ${state.username}👋\n${LocalizationService.get(currentLang, 'shopping')}",
                                  style: TextStyle(
                                      fontSize: responsiveSize(12, 18),
                                      fontWeight: FontWeight.bold,
                                      color: textColor),
                                ),
                              ),

                              // Search & Filter Row
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 40 : 5.w,
                                    vertical: isDesktop ? 20 : 2.h),
                                child: Row(
                                  children: [
                                    // Search field
                                    Expanded(
                                      child: Container(
                                        height: isDesktop ? 48 : 44,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.grey[800]
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: TextField(
                                          onChanged: (val) => context
                                              .read<DashboardCubit>()
                                              .filterProducts(val),
                                          style: TextStyle(color: textColor),
                                          decoration: InputDecoration(
                                            hintText: LocalizationService.get(
                                                currentLang, 'search'),
                                            hintStyle: TextStyle(
                                                fontSize: responsiveSize(9, 14),
                                                color: Colors.grey),
                                            prefixIcon: Icon(Icons.search,
                                                color: Colors.grey,
                                                size: responsiveSize(16, 22)),
                                            filled: false,
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Filter button
                                    Material(
                                      color: state.currentAccentColor,
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        onTap: () => _showFilterSheet(
                                            context, state, currentLang),
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

                              if (state.usingLocalFallback)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 40 : 5.w,
                                      vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning,
                                          color: Colors.orange, size: 18),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Data produk gagal dimuat dari API, menampilkan data lokal.',
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: responsiveSize(8, 12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Promo banner
                              _buildPromoBanner(context, state, isDesktop,
                                  responsiveSize, currentLang),

                              // Header
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 40 : 5.w,
                                    vertical: isDesktop ? 20 : 2.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Builder(builder: (ctx) {
                                      String headerBase =
                                          state.selectedCategory == 'All'
                                              ? LocalizationService.get(
                                                  currentLang, 'popular')
                                              : state.selectedCategory;
                                      String sortSuffix = '';
                                      if (state.sortMode == SortMode.priceAsc) {
                                        sortSuffix =
                                            ' • ${LocalizationService.get(currentLang, 'sortPriceAsc')}';
                                      }
                                      if (state.sortMode ==
                                          SortMode.priceDesc) {
                                        sortSuffix =
                                            ' • ${LocalizationService.get(currentLang, 'sortPriceDesc')}';
                                      }
                                      if (state.sortMode ==
                                          SortMode.ratingDesc) {
                                        sortSuffix =
                                            ' • ${LocalizationService.get(currentLang, 'sortRating')}';
                                      }
                                      return Text(
                                        '$headerBase$sortSuffix',
                                        style: TextStyle(
                                            fontSize: responsiveSize(12, 20),
                                            fontWeight: FontWeight.bold,
                                            color: textColor),
                                      );
                                    }),
                                    // Sort / View All
                                    Builder(builder: (ctx) {
                                      final bool isFilteredActive =
                                          state.selectedCategory != 'All' ||
                                              state.searchQuery.isNotEmpty;

                                      if (!isFilteredActive) {
                                        return Row(
                                          children: [
                                            _buildSortMenu(context,
                                                responsiveSize, currentLang),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () {
                                                context
                                                    .read<DashboardCubit>()
                                                    .showAllProducts();
                                              },
                                              child: Text(
                                                LocalizationService.get(
                                                    currentLang, 'viewAll'),
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize:
                                                        responsiveSize(10, 14)),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return _buildSortMenu(
                                          context, responsiveSize, currentLang);
                                    }),
                                  ],
                                ),
                              ),

                              // Grid
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 40 : 5.w),
                                child: state.filteredProducts.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            LocalizationService.get(
                                                currentLang, 'notFound'),
                                            style: TextStyle(color: textColor),
                                          ),
                                        ),
                                      )
                                    : _buildProductGrid(
                                        context,
                                        state,
                                        isDesktop,
                                        responsiveSize,
                                        cardColor,
                                        textColor),
                              ),

                              SizedBox(height: 5.h),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildSortMenu(
      BuildContext context, Function responsiveSize, String currentLang) {
    return PopupMenuButton<SortMode>(
      tooltip: 'Sort',
      onSelected: (mode) {
        context.read<DashboardCubit>().changeSortMode(mode);
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
            value: SortMode.none,
            child: Text(LocalizationService.get(currentLang, 'sortDefault'))),
        PopupMenuItem(
            value: SortMode.priceAsc,
            child: Text(LocalizationService.get(currentLang, 'sortPriceAsc'))),
        PopupMenuItem(
            value: SortMode.priceDesc,
            child: Text(LocalizationService.get(currentLang, 'sortPriceDesc'))),
        PopupMenuItem(
            value: SortMode.ratingDesc,
            child: Text(LocalizationService.get(currentLang, 'sortRating'))),
      ],
      icon: Icon(Icons.sort, color: Colors.grey, size: responsiveSize(16, 20)),
    );
  }

  Widget _buildProductGrid(
      BuildContext context,
      DashboardState state,
      bool isDesktop,
      Function responsiveSize,
      Color cardColor,
      Color textColor) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 5 : 2,
        crossAxisSpacing: isDesktop ? 20 : 4.w,
        mainAxisSpacing: isDesktop ? 20 : 4.w,
        childAspectRatio: 0.7,
      ),
      itemCount: state.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];
        final isFav = state.favoriteIds.contains(product.id);
        return _buildProductCard(context, product, isFav, isDesktop,
            responsiveSize, cardColor, textColor);
      },
    );
  }

  Widget _buildProductCard(
      BuildContext context,
      Product product,
      bool isFav,
      bool isDesktop,
      Function responsiveSize,
      Color cardColor,
      Color textColor) {
    GlobalKey widgetKey = GlobalKey();
    return GestureDetector(
      onTap: () => context.push(AppRoutes.detailProduk, extra: product),
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            key: widgetKey,
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
                                    errorBuilder: (ctx, err, st) =>
                                        const Center(
                                      child: Icon(Icons.broken_image,
                                          color:
                                              Color.fromARGB(255, 221, 68, 68)),
                                    ),
                                  );
                                }
                                return const Center(
                                    child: Icon(Icons.broken_image,
                                        color: Colors.grey));
                              },
                            ),
                          ),
                        ),
                        // Price badge top-left
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              formatRupiah.format(product.price),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsiveSize(7, 12)),
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
                          fontSize: responsiveSize(9, 14),
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Kategori di bawah nama produk
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
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
                              const Icon(Icons.star,
                                  size: 12, color: Colors.amber),
                              const SizedBox(width: 6),
                              Text(product.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                      fontSize: responsiveSize(8, 11),
                                      color: Colors.grey[700])),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              await runAddToCartAnimation(widgetKey);
                              if (context.mounted) {
                                await context
                                    .read<DashboardCubit>()
                                    .addToCart(product);
                                if (context.mounted) {
                                  context.read<CartCubit>().loadCart();
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            // Favorite heart
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: () {
                  context.read<DashboardCubit>().toggleFavorite(product);
                },
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey,
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

  Widget _buildPromoBanner(BuildContext context, DashboardState state,
      bool isDesktop, Function responsiveSize, String currentLang) {
    // Gradients for each slide
    final List<List<Color>> gradients = [
      [const Color(0xFF6A11CB), const Color(0xFF2575FC)], // Purple - Blue
      [const Color(0xFFFF512F), const Color(0xFFDD2476)], // Orange - Pink
      [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Green - Teal
    ];

    return Column(
      children: [
        // Carousel with PageView
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
              ),
            ],
          ),
          child: Stack(
            children: [
              // PageView untuk carousel
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ScrollConfiguration(
                  behavior: _DesktopScrollBehavior(),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      context
                          .read<DashboardCubit>()
                          .updateCarouselIndex(index % _carouselImages.length);
                    },
                    // Infinite scroll: no itemCount
                    itemBuilder: (context, index) {
                      final realIndex = index % _carouselImages.length;
                      return Stack(
                        children: [
                          // Background Gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradients[realIndex % gradients.length],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          // Hoodie Image (Centered)
                          Positioned.fill(
                            child: Center(
                              child: Image.asset(
                                _carouselImages[realIndex],
                                fit: BoxFit.contain,
                                width: isDesktop ? 300 : 200,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image,
                                        size: 50, color: Colors.white),
                              ),
                            ),
                          ),
                          // Text Content (Left Side, slightly up)
                          Positioned(
                            left: isDesktop ? 40 : 16,
                            top: 0,
                            bottom: 20, // Push content slightly up
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocalizationService.get(
                                      currentLang, 'promoGet'),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsiveSize(12, 20),
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0, 1),
                                        blurRadius: 3.0,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  LocalizationService.get(
                                      currentLang, 'promoDiscount'),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsiveSize(24, 48),
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0, 2),
                                        blurRadius: 4.0,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  LocalizationService.get(
                                      currentLang, 'promoLimited'),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: responsiveSize(10, 16),
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0, 1),
                                        blurRadius: 2.0,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
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
              // Pagination Dots
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _carouselImages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: state.carouselIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: state.carouselIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDesktop,
      Function responsiveSize, Color textColor, String currentLang) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leadingWidth: isDesktop ? 200 : 200, // Beri ruang untuk logo di kiri
      leading: Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: textColor),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              const SizedBox(width: 4),
              // Logo & Text
              Text(
                'UrbanWear',
                style: TextStyle(
                  color: Colors.deepPurple, // Sesuaikan warna ungu
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 18 : 14.sp,
                ),
              ),
            ],
          );
        },
      ),
      title: Text(
        LocalizationService.get(currentLang, 'home'),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: isDesktop ? 18 : 16.sp,
        ),
      ),
      actions: [
        // Cart button
        // Cart button
        BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            return GestureDetector(
              onTap: () {
                context.go(AppRoutes.cart);
              },
              child: AddToCartIcon(
                key: cartKey,
                icon: Badge(
                  label: Text(cartState.items.length.toString()),
                  isLabelVisible: cartState.items.isNotEmpty,
                  child: Icon(Icons.shopping_cart, color: textColor),
                ),
                badgeOptions: const BadgeOptions(
                  active: false,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            );
          },
        ),
        // Chat button
        IconButton(
          icon: Icon(Icons.smart_toy, color: textColor),
          tooltip: 'Chat Bot',
          onPressed: () {
            context.go(AppRoutes.chat, extra: {
              'userId': widget.user.id.toString(),
              'userName': widget.user.username,
              'userEmail': widget.user.email,
            });
          },
        ),
        // User Avatar (kanan)
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () async {
              context.go(AppRoutes.profile, extra: widget.user);
            },
            child: FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return ScaleTransition(
                    scale: _avatarScaleAnim,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person,
                          color: Theme.of(context).primaryColor),
                    ),
                  );
                }
                final b64 = snap.data!.getString('profile_image');
                if (b64 == null) {
                  return ScaleTransition(
                    scale: _avatarScaleAnim,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person,
                          color: Theme.of(context).primaryColor),
                    ),
                  );
                }
                try {
                  final bytes = base64Decode(b64);
                  return ScaleTransition(
                    scale: _avatarScaleAnim,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage: MemoryImage(bytes),
                    ),
                  );
                } catch (_) {
                  return ScaleTransition(
                    scale: _avatarScaleAnim,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person,
                          color: Theme.of(context).primaryColor),
                    ),
                  );
                }
              },
            ),
          ),
        )
      ],
    );
  }

  // --- DRAWER ---
  Widget _buildDrawer(BuildContext context, String lang) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snap) {
              String name = widget.user.username;
              String email = widget.user.email;
              String? b64;

              if (snap.hasData) {
                final prefs = snap.data!;
                name = prefs.getString('user_name') ?? name;
                email = prefs.getString('user_email') ?? email;
                b64 = prefs.getString('profile_image');
              }

              return UserAccountsDrawerHeader(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                accountName: Text(name),
                accountEmail: Text(email),
                currentAccountPicture: Builder(builder: (context) {
                  if (b64 == null) {
                    return const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person));
                  }
                  try {
                    final bytes = base64Decode(b64);
                    return CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: MemoryImage(bytes));
                  } catch (_) {
                    return const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person));
                  }
                }),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profil"),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.profile, extra: widget.user);
            },
          ),
          const Divider(),
          // Home Pindah ke sini (sebelum Settings) dan Padding dihapus
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          // Settings Section
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.settings);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text("Keranjang"),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.cart);
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
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Favorit"),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.favorit);
            },
          ),
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text("About Us"),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.about);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Tentang Aplikasi"),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.aboutApp);
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
              context.read<DashboardCubit>().logout();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
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
