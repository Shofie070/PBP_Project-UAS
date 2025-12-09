import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../features/shared/routes/app_router.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class KeranjangPage extends StatelessWidget {
  const KeranjangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartCubit()..loadCart(),
      child: const CartView(),
    );
  }
}

class CartView extends StatelessWidget {
  const CartView({super.key});

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
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.dashboard),
          ),
          title: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your cart',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: responsiveSize(14, 20),
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: isDesktop ? 6 : 0.5.h),
                  Text('${state.items.length} Products in Your cart',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: responsiveSize(10, 14))),
                ],
              );
            },
          ),
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state.status == CartStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final isWide = constraints.maxWidth > 900;
            Widget listColumn = state.items.isEmpty
                ? Center(
                    child: Text('Your cart is empty',
                        style: TextStyle(fontSize: responsiveSize(12, 16))))
                : ListView.separated(
                    padding: EdgeInsets.all(isDesktop ? 12 : 3.w),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: isDesktop ? 12 : 1.5.h),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      final product = item.product;
                      final isFav = state.favoriteIds.contains(product.id);

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 12 : 3.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: item.isSelected,
                                onChanged: (v) => context
                                    .read<CartCubit>()
                                    .toggleSelection(index, v),
                              ),
                              Container(
                                width: isWide ? 96 : 16.w,
                                height: isWide ? 96 : 16.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[100]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: product.image.isNotEmpty
                                      ? (product.image.startsWith('http')
                                          ? Image.network(product.image,
                                              fit: BoxFit.cover)
                                          : Image.asset(product.image,
                                              fit: BoxFit.cover))
                                      : const SizedBox.shrink(),
                                ),
                              ),
                              SizedBox(width: isDesktop ? 12 : 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: responsiveSize(11, 14))),
                                    SizedBox(height: isDesktop ? 6 : 0.5.h),
                                    Text('Category: ${product.category}',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: responsiveSize(9, 12))),
                                    SizedBox(height: isDesktop ? 8 : 1.h),
                                    Row(
                                      children: [
                                        Text('Qty:',
                                            style: TextStyle(
                                                fontSize:
                                                    responsiveSize(10, 13))),
                                        SizedBox(width: isDesktop ? 8 : 2.w),
                                        DropdownButton<int>(
                                          value: item.quantity,
                                          items: List.generate(10, (i) => i + 1)
                                              .map((q) => DropdownMenuItem(
                                                  value: q,
                                                  child: Text(q.toString(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              responsiveSize(
                                                                  10, 13)))))
                                              .toList(),
                                          onChanged: (v) {
                                            if (v == null) return;
                                            context
                                                .read<CartCubit>()
                                                .updateQuantity(index, v);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Rp ${product.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: responsiveSize(11, 14))),
                                  SizedBox(height: isDesktop ? 8 : 1.h),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                            isFav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.red,
                                            size: responsiveSize(16, 20)),
                                        onPressed: () => context
                                            .read<CartCubit>()
                                            .toggleFavorite(product),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close,
                                            color: Colors.grey,
                                            size: responsiveSize(16, 20)),
                                        onPressed: () => context
                                            .read<CartCubit>()
                                            .removeFromCart(index),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

            Widget summaryPanel() {
              final subtotal = state.totalAmount;
              const delivery = 25000.0;
              final tax = subtotal * 0.02;
              const discount = 0.0;
              final total = subtotal + delivery + tax - discount;

              return Card(
                margin: EdgeInsets.all(isDesktop ? 12 : 3.w),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 16 : 4.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isDesktop ? 12 : 1.h),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Items:',
                                style: TextStyle(
                                    fontSize: responsiveSize(11, 14))),
                            Text('${state.items.length}',
                                style:
                                    TextStyle(fontSize: responsiveSize(11, 14)))
                          ]),
                      SizedBox(height: isDesktop ? 6 : 0.5.h),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Delivery cost:',
                                style: TextStyle(
                                    fontSize: responsiveSize(11, 14))),
                            Text('Rp ${delivery.toStringAsFixed(0)}',
                                style:
                                    TextStyle(fontSize: responsiveSize(11, 14)))
                          ]),
                      SizedBox(height: isDesktop ? 6 : 0.5.h),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tax:',
                                style: TextStyle(
                                    fontSize: responsiveSize(11, 14))),
                            Text('Rp ${tax.toStringAsFixed(0)}',
                                style:
                                    TextStyle(fontSize: responsiveSize(11, 14)))
                          ]),
                      SizedBox(height: isDesktop ? 6 : 0.5.h),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Discount:',
                                style: TextStyle(
                                    fontSize: responsiveSize(11, 14))),
                            Text('- Rp ${discount.toStringAsFixed(0)}',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: responsiveSize(11, 14)))
                          ]),
                      Divider(height: isDesktop ? 20 : 2.h),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: responsiveSize(12, 16))),
                            Text('Rp ${total.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: responsiveSize(12, 16)))
                          ]),
                      SizedBox(height: isDesktop ? 12 : 1.5.h),
                      ElevatedButton(
                          onPressed: () {
                            final selectedProducts = state.selectedProducts;
                            if (selectedProducts.isNotEmpty) {
                              context.push(
                                AppRoutes.payment,
                                extra: {
                                  'products': selectedProducts,
                                  'totalAmount': total,
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Pilih produk terlebih dahulu!')));
                            }
                          },
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: isDesktop ? 12 : 1.5.h),
                              child: Text('Checkout',
                                  style: TextStyle(
                                      fontSize: responsiveSize(12, 16))))),
                    ],
                  ),
                ),
              );
            }

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: listColumn),
                  SizedBox(
                      width: isDesktop ? 350 : 30.w, child: summaryPanel()),
                ],
              );
            }

            return Column(
              children: [
                Expanded(child: listColumn),
                summaryPanel(),
              ],
            );
          },
        ),
      );
    });
  }
}
