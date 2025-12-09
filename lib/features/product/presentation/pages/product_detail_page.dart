import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../features/shared/routes/app_router.dart';
import '../../../../model/model.dart';
import '../../../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../../../features/cart/presentation/cubit/cart_state.dart';
import '../cubit/product_detail_cubit.dart';
import '../cubit/product_detail_state.dart';

class DetailProduk extends StatelessWidget {
  final Product product;
  const DetailProduk({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductDetailCubit()..init(product),
      child: const ProductDetailView(),
    );
  }
}

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final PageController _pageController = PageController();
  final TextEditingController _reviewController = TextEditingController();
  final formatRupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Cart Animation
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  final GlobalKey _imageKey = GlobalKey();

  @override
  void dispose() {
    _pageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview(BuildContext context) {
    final comment = _reviewController.text;
    if (comment.isNotEmpty) {
      context.read<ProductDetailCubit>().submitReview(comment);
      _reviewController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terima kasih atas ulasan Anda')));
    }
  }

  void _buyNow(BuildContext context, Product product) {
    context.go(
      AppRoutes.payment,
      extra: {
        'products': [product],
        'totalAmount': product.price.toDouble(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        if (state.product == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final product = state.product!;

        // Prepare images
        List<String> images = [];
        if (product.image.isNotEmpty) {
          images.add(product.image);
        } else {
          images.add('assets/images/placeholder.png');
        }
        // If product had multiple images in legacy map, we lose them in Product model unless we extend it.
        // For now, we stick to single image from Product model or check if we can pass more.
        // The legacy code checked `p['images']`. The Product model only has `image` string.
        // We will stick to single image for now to be consistent with model.

        return LayoutBuilder(builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 900;
          double responsiveSize(double mobileSp, double desktopPx) =>
              isDesktop ? desktopPx : mobileSp.sp;
          final carouselHeight = isDesktop ? 420.0 : 46.h;
          final thumbnailHeight = isDesktop ? 72.0 : 10.w;
          final tabViewHeight = isDesktop ? 300.0 : 18.h;

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
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(AppRoutes.dashboard),
                ),
                title: Text(product.name,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: responsiveSize(12, 18))),
                actions: [
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
                            child: const Icon(Icons.shopping_cart),
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
                  const SizedBox(width: 16),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 40 : 4.w,
                              vertical: isDesktop ? 20 : 2.h),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(isDesktop ? 20 : 4.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image carousel
                                  Container(
                                    key: _imageKey,
                                    height: carouselHeight,
                                    color: Colors.transparent,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: PageView.builder(
                                              controller: _pageController,
                                              onPageChanged: (i) => context
                                                  .read<ProductDetailCubit>()
                                                  .updateCarouselIndex(i),
                                              itemCount: images.length,
                                              itemBuilder: (ctx, i) {
                                                final src = images[i];
                                                if (src.startsWith('http')) {
                                                  return Image.network(src,
                                                      fit: BoxFit.contain);
                                                }
                                                return Image.asset(src,
                                                    fit: BoxFit.contain);
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: isDesktop ? 12 : 1.h),
                                        if (images.length > 1)
                                          SizedBox(
                                            height: thumbnailHeight,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: images.length,
                                              separatorBuilder: (_, __) =>
                                                  SizedBox(
                                                      width:
                                                          isDesktop ? 12 : 3.w),
                                              itemBuilder: (ctx, i) {
                                                final src = images[i];
                                                return GestureDetector(
                                                  onTap: () {
                                                    _pageController
                                                        .animateToPage(i,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            curve: Curves
                                                                .easeInOut);
                                                    context
                                                        .read<
                                                            ProductDetailCubit>()
                                                        .updateCarouselIndex(i);
                                                  },
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    width:
                                                        isDesktop ? 72 : 10.w,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: state.carouselIndex ==
                                                                  i
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Colors
                                                                  .transparent,
                                                          width: 2),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      child: src.startsWith(
                                                              'http')
                                                          ? Image.network(src,
                                                              fit: BoxFit.cover)
                                                          : Image.asset(src,
                                                              fit:
                                                                  BoxFit.cover),
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
                                  Text(product.name,
                                      style: TextStyle(
                                          fontSize: responsiveSize(14, 30),
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: isDesktop ? 12 : 1.h),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber,
                                          size: responsiveSize(12, 18)),
                                      SizedBox(width: isDesktop ? 10 : 2.w),
                                      Text(product.rating.toStringAsFixed(1),
                                          style: TextStyle(
                                              fontSize:
                                                  responsiveSize(11, 16))),
                                      SizedBox(width: isDesktop ? 16 : 4.w),
                                      Text('•',
                                          style: TextStyle(
                                              fontSize: responsiveSize(10, 16),
                                              color: Colors.grey)),
                                      SizedBox(width: isDesktop ? 16 : 4.w),
                                      Text(
                                          product
                                              .category, // Using category as brand substitute if needed, or just category
                                          style: TextStyle(
                                              fontSize: responsiveSize(10, 16),
                                              color: Colors.grey)),
                                      const Spacer(),
                                      Text(formatRupiah.format(product.price),
                                          style: TextStyle(
                                              fontSize: responsiveSize(13, 28),
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                    ],
                                  ),
                                  SizedBox(height: isDesktop ? 20 : 2.h),

                                  // Tabs
                                  DefaultTabController(
                                    length: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TabBar(
                                          labelColor: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                          unselectedLabelColor: Colors.grey,
                                          indicatorColor:
                                              Theme.of(context).primaryColor,
                                          tabs: const [
                                            Tab(
                                                text: 'About Item',
                                                iconMargin: EdgeInsets.zero),
                                            Tab(
                                                text: 'Reviews',
                                                iconMargin: EdgeInsets.zero),
                                          ],
                                        ),
                                        SizedBox(
                                          height: tabViewHeight,
                                          child: TabBarView(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: isDesktop ? 12 : 2.h),
                                                child: Text(product.description,
                                                    style: TextStyle(
                                                        fontSize:
                                                            responsiveSize(
                                                                12, 18),
                                                        height: 1.4)),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: isDesktop ? 12 : 2.h),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text('User Reviews',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      responsiveSize(
                                                                          12,
                                                                          18))),
                                                          const SizedBox(
                                                              width: 12),
                                                          RatingBarIndicator(
                                                            rating:
                                                                product.rating,
                                                            itemBuilder: (context,
                                                                    _) =>
                                                                const Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .amber),
                                                            itemCount: 5,
                                                            itemSize: isDesktop
                                                                ? 20
                                                                : 16,
                                                            direction:
                                                                Axis.horizontal,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height: isDesktop
                                                              ? 12
                                                              : 1.h),
                                                      if (state
                                                          .reviews.isNotEmpty)
                                                        ...(state.reviews
                                                            .map((r) => Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              8.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      if (r['rating'] !=
                                                                          null)
                                                                        SingleChildScrollView(
                                                                          scrollDirection:
                                                                              Axis.horizontal,
                                                                          child:
                                                                              Row(
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
                                                                        r['comment'] ??
                                                                            '',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                responsiveSize(12, 16)),
                                                                        softWrap:
                                                                            true,
                                                                      ),
                                                                      if ((r['date'] ??
                                                                              '') !=
                                                                          '')
                                                                        Text(
                                                                          r['date']
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              fontSize: responsiveSize(10, 12),
                                                                              color: Colors.grey),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                )))
                                                      else
                                                        Text(
                                                            'Belum ada ulasan.',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    responsiveSize(
                                                                        12,
                                                                        16))),

                                                      // Input form for new review
                                                      const Divider(),
                                                      Text('Tulis Ulasan Anda',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  responsiveSize(
                                                                      12, 16))),
                                                      const SizedBox(height: 8),
                                                      RatingBar.builder(
                                                        initialRating:
                                                            state.userRating,
                                                        minRating: 1,
                                                        direction:
                                                            Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 5,
                                                        itemSize:
                                                            isDesktop ? 28 : 24,
                                                        itemBuilder: (context,
                                                                _) =>
                                                            const Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .amber),
                                                        onRatingUpdate: (r) => context
                                                            .read<
                                                                ProductDetailCubit>()
                                                            .updateUserRating(
                                                                r),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      TextField(
                                                        controller:
                                                            _reviewController,
                                                        maxLines: 3,
                                                        decoration: const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            hintText:
                                                                'Tulis komentar (opsional)'),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      ElevatedButton(
                                                          onPressed: () =>
                                                              _submitReview(
                                                                  context),
                                                          child: const Text(
                                                              'Kirim Ulasan')),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 40 : 4.w,
                          vertical: isDesktop ? 16 : 2.h),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Row(
                        children: [
                          FloatingActionButton(
                            heroTag: 'fav',
                            onPressed: () {
                              context
                                  .read<ProductDetailCubit>()
                                  .toggleFavorite();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(state.isFavorite
                                          ? 'Dihapus dari favorit'
                                          : 'Ditambahkan ke favorit')));
                            },
                            mini: true,
                            backgroundColor: Theme.of(context).cardColor,
                            child: Icon(
                                state.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: responsiveSize(18, 20)),
                          ),
                          SizedBox(width: isDesktop ? 16 : 4.w),
                          Expanded(
                            child: SizedBox(
                              height: isDesktop ? 56 : 6.h,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await runAddToCartAnimation(_imageKey);
                                  } catch (e) {
                                    debugPrint('Animation failed: $e');
                                  }
                                  if (context.mounted) {
                                    await context
                                        .read<ProductDetailCubit>()
                                        .addToCart();
                                    if (context.mounted) {
                                      context.read<CartCubit>().loadCart();
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: Text('Add to Cart',
                                    style: TextStyle(
                                        fontSize: responsiveSize(14, 18),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          SizedBox(width: isDesktop ? 16 : 3.w),
                          SizedBox(
                            width: isDesktop ? 140 : 30.w,
                            height: isDesktop ? 56 : 6.h,
                            child: OutlinedButton(
                              onPressed: () => _buyNow(context, product),
                              style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: Text('Buy Now',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsiveSize(14, 18))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
