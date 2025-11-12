import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/app_router.dart';

class DashboardPage extends StatefulWidget {
  final UserModel user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Map<String, dynamic>> _cart = [];

  Widget _buildCatalog(BuildContext context) {
    final categories = CategoryRepository.getCategories();
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            context.go('${AppRoutes.product}/$category');
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 10.w,
                  backgroundColor: Colors.pinkAccent.withOpacity(0.2),
                  child:
                      Icon(Icons.category, color: Colors.pinkAccent, size: 8.w),
                ),
                SizedBox(height: 1.h),
                Text(
                  category,
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _drawerMenu(BuildContext context) {
    final items = [
      DrawerItem(
        title: "Katalog",
        icon: Icons.store,
        onTap: (context) => Navigator.pop(context),
      ),
      DrawerItem(
        title: "Keranjang",
        icon: Icons.shopping_cart,
        onTap: (context) {
          Navigator.pop(context);
          context.go(AppRoutes.cart);
        },
      ),
      DrawerItem(
        title: "Tentang Kami",
        icon: Icons.info,
        onTap: (context) {
          Navigator.pop(context);
          context.go(AppRoutes.aboutUs);
        },
      ),
    ];
    return items
        .map((item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              onTap: () => item.onTap(context),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/background.png",
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Dashboard"),
            backgroundColor: Colors.pinkAccent,
            actions: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      context.go(AppRoutes.cart);
                    },
                  ),
                  if (_cart.isNotEmpty)
                    Positioned(
                      right: 1.w,
                      top: 1.h,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _cart.length.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 8.sp),
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.pinkAccent),
                  ),
                  SizedBox(width: 2.w), // Menggunakan w
                  Text(
                    widget.user.username,
                    style: TextStyle(
                      // Dihapus const
                      fontSize: 12.sp, // Menggunakan sp
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4.w), // Menggunakan w
                ],
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Colors.pinkAccent),
                  accountName: Text(widget.user.username),
                  accountEmail: Text(widget.user.email),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.pinkAccent),
                  ),
                ),
                ..._drawerMenu(context),
                if (widget.user.email == 'admin@admin.com')
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text("Menu Admin"),
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.menuAdmin);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Logout"),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('is_logged_in');
                    await prefs.remove('current_user_email');
                    if (mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(child: _buildCatalog(context)),
              // Removed Menu Admin button from the body
            ],
          ),
        ),
      ],
    );
  }
}
