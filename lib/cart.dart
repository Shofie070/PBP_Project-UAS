// File: lib/cart.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/cubic_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/cart_state.dart';
import 'app_router.dart';

class CartPage extends StatelessWidget {
  // Parameter 'cart' dan 'onRemove' Dihilangkan,
  // data dan fungsi diambil dari Bloc.

  const CartPage(
      {super.key,
      required Null Function(dynamic index) onRemove,
      required List<Map<String, dynamic>> cart});

  @override
  Widget build(BuildContext context) {
    // Sediakan CartBloc untuk seluruh widget di bawahnya
    return BlocProvider(
      create: (context) => CartBloc(),
      child: Stack(
        children: [
          // Background image (sama dengan dashboard)
          Image.asset(
            "assets/images/background.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // BlocBuilder untuk merebuild UI saat state keranjang berubah
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final cart = state.cartItems; // Ambil data dari State
              final bloc = context.read<CartBloc>(); // Akses instance Bloc

              return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text("Keranjang"),
                  backgroundColor: Colors.pinkAccent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(AppRoutes.dashboard),
                  ),
                ),
                body: cart.isEmpty
                    ? const Center(
                        child: Text(
                          "Keranjang masih kosong",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          final product = cart[index];
                          final productName = product["name"] ?? 'No Name';
                          final productPrice = product["price"] ?? 0;

                          return Dismissible(
                            key: ValueKey(productName + index.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.red,
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              // Panggil method dari Bloc
                              bloc.removeItem(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$productName dihapus')),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.shopping_cart,
                                    color: Colors.pinkAccent),
                                title: Text(productName),
                                subtitle: Text("Rp $productPrice"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.payment,
                                          color: Colors.green),
                                      tooltip: 'Checkout',
                                      onPressed: () {
                                        context.go(AppRoutes.checkout);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => bloc.removeItem(index),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
