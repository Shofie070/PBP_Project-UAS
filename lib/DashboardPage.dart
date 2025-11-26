// lib/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import halaman-halaman lain
import 'package:urban_wear_app/cart_cubit.dart';
import 'package:urban_wear_app/cart_state.dart';
import 'package:urban_wear_app/profile.dart';
import 'package:urban_wear_app/cart.dart';
import 'package:urban_wear_app/about_us.dart';
import 'package:urban_wear_app/menu_admin.dart';
import 'package:urban_wear_app/login.dart';
import 'package:urban_wear_app/about_app.dart'; // Pastikan file ini ada!

// Import model dan data
import 'model/model.dart';
import 'product.dart'; // Pastikan file ini memuat CategoryRepository

class DashboardPage extends StatelessWidget {
  final UserModel user;
  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartCubit(),
      child: _DashboardView(user: user),
    );
  }
}

class _DashboardView extends StatefulWidget {
  final UserModel user;
  const _DashboardView({required this.user});

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  // Variabel untuk menyimpan kategori yang sedang dipilih (Default: All)
  String selectedCategory = "All";

  // --- WIDGET 1: TAB FILTER (SHORTING) DI ATAS ---
  Widget _buildCategoryTabs() {
    // Ambil list kategori dan tambahkan "All" di depannya
    final categories = ["All", ...CategoryRepository.getCategories()];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                // Jika dipilih warnanya Putih, jika tidak Transparan
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET 2: DAFTAR KATEGORI DI BAWAH ---
  Widget _buildCatalog(BuildContext context) {
    final allCategories = CategoryRepository.getCategories();

    // LOGIKA FILTER:
    final displayedCategories = selectedCategory == "All"
        ? allCategories
        : allCategories.where((c) => c == selectedCategory).toList();

    if (displayedCategories.isEmpty) {
      return const Center(
          child: Text("Kategori tidak ditemukan",
              style: TextStyle(color: Colors.white)));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: displayedCategories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = displayedCategories[index];

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
                            "${product['name']} ditambahkan ke keranjang!",
                            style: const TextStyle(color: Colors.black)),
                        backgroundColor: Colors.white,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          // Desain Kartu (List Menu Elegan)
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            ),
            child: Row(
              children: [
                // Ikon
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.checkroom,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                // Teks
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Explore Collection",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                // Panah
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
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
    return Theme(
      data: ThemeData.dark(),
      child: Stack(
        children: [
          // Background Image
          Image.asset(
            "assets/images/background.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(color: Colors.black),
          ),
          // Overlay Gelap
          Container(color: Colors.black.withOpacity(0.6)),

          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text("Urban Wear",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              backgroundColor: Colors.black,
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
                // Profil Icon
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfilePage(user: widget.user))),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.user.username[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Drawer Navigasi
            drawer: Drawer(
              backgroundColor: const Color(0xFF111111),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: Colors.black),
                    accountName: Text(widget.user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    accountEmail: Text(widget.user.email),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(widget.user.username[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 40,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  ListTile(
                      leading: const Icon(Icons.home, color: Colors.white),
                      title: const Text("Beranda",
                          style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.pop(context)),
                  ListTile(
                      leading:
                          const Icon(Icons.shopping_cart, color: Colors.white),
                      title: const Text("Keranjang",
                          style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CartPage(
                                    onRemove: (index) {},
                                    cart: const [],
                                    cartModel: null,
                                  )))),
                  ListTile(
                      leading: const Icon(Icons.groups, color: Colors.white),
                      title: const Text("Tentang Kami",
                          style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AboutUs()))),

                  // --- MENU TENTANG APLIKASI (MENGARAH KE FILE BARU) ---
                  ListTile(
                      leading:
                          const Icon(Icons.smartphone, color: Colors.white),
                      title: const Text("Tentang Aplikasi",
                          style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AboutAppPage()))),

                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: const Text("Profil Saya",
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfilePage(user: widget.user)));
                    },
                  ),
                  if (widget.user.email == 'admin@admin.com')
                    ListTile(
                        leading: const Icon(Icons.admin_panel_settings,
                            color: Colors.white),
                        title: const Text("Menu Admin",
                            style: TextStyle(color: Colors.white)),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MenuAdmin()))),
                  const Divider(color: Colors.grey),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Keluar",
                        style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (!context.mounted) return;
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

            // BODY UTAMA
            body: Column(
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "SHOP BY CATEGORY",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 1. TAMPILKAN TAB FILTER
                _buildCategoryTabs(),

                const SizedBox(height: 10),

                // 2. TAMPILKAN LIST KATEGORI
                Expanded(child: _buildCatalog(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
