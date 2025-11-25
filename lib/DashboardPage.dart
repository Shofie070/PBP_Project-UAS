// lib/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_wear_app/cart_cubit.dart';
import 'package:urban_wear_app/cart_state.dart';
import 'package:urban_wear_app/profile.dart';
import 'model/model.dart';
import 'product.dart';
import 'cart.dart';
import 'about_us.dart';
import 'menu_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class DashboardPage extends StatelessWidget {
  final UserModel user;
  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CartCubit(), // otomatis load dummy dari CartState.initial()
      child: _DashboardView(user: user),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final UserModel user;
  const _DashboardView({required this.user});

  Widget _buildCatalog(BuildContext context) {
    final categories = CategoryRepository.getCategories();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductPage(
                  category: category,
                  onAddToCart: (product) {
                    context.read<CartCubit>().addItemToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "${product['name']} ditambahkan ke keranjang!"),
                        backgroundColor: Colors.pinkAccent,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.pinkAccent.withOpacity(0.2),
                  child: const Icon(Icons.category,
                      size: 44, color: Colors.pinkAccent),
                ),
                const SizedBox(height: 16),
                Text(
                  category,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Image.asset(
          "assets/images/background.png",
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Urban Wear",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              // Badge Keranjang
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  final count = state.cartItems.length;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart, size: 28),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CartPage(
                                      onRemove: (index) {},
                                      cart: const [],
                                      cartModel: null,
                                    ))),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Text(count.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Profil di AppBar (bisa diklik)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfilePage(user: user))),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.username[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.username,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Drawer
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Colors.pinkAccent),
                  accountName: Text(user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  accountEmail: Text(user.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(user.username[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 40,
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.bold)),
                  ),
                ),

                ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text("Beranda"),
                    onTap: () => Navigator.pop(context)),
                ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text("Keranjang"),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CartPage(
                                  onRemove: (index) {},
                                  cart: const [],
                                  cartModel: null,
                                )))),
                ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text("Tentang Kami"),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AboutUs()))),

                // PROFIL DI DRAWER
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profil Saya"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfilePage(user: user)));
                  },
                ),

                if (user.email == 'admin@admin.com')
                  ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text("Menu Admin"),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MenuAdmin()))),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text("Keluar", style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          // Body
          body: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Pilih Kategori",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildCatalog(context)),
            ],
          ),
        ),
      ],
    );
  }
}
