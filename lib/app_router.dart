import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pages
import 'splash_screen.dart';
import 'login.dart';
import 'register_page.dart';
import 'DashboardPage.dart';
import 'product.dart';
import 'cart.dart';
import 'checkout.dart';
import 'profile.dart';
import 'about_us.dart';
import 'menu_admin.dart';
import 'detail_produk.dart';
import 'detail_kaos.dart';
import 'detail_hoodie.dart';

// Models
import 'model/model.dart';

// Wrapper widget untuk Dashboard dengan auto-load user
class DashboardPageWrapper extends StatefulWidget {
  const DashboardPageWrapper({Key? key}) : super(key: key);

  @override
  State<DashboardPageWrapper> createState() => _DashboardPageWrapperState();
}

class _DashboardPageWrapperState extends State<DashboardPageWrapper> {
  late Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserFromPrefs();
  }

  Future<UserModel> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email') ?? '';
    final username = prefs.getString('user_name') ?? 'User';
    return UserModel(username: username, email: email);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SplashScreen();
        }

        return DashboardPage(user: snapshot.data!);
      },
    );
  }
}

// Definisi routes sebagai constants
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String product = '/product';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String profile = '/profile';
  static const String aboutUs = '/about-us';
  static const String menuAdmin = '/menu-admin';
  static const String detailProduk = '/detail-produk';
  static const String detailKaos = '/detail-kaos';
  static const String detailHoodie = '/detail-hoodie';
}

// Go Router Configuration
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: <GoRoute>[
    // Splash Screen
    GoRoute(
      path: AppRoutes.splash,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),

    // Login Page
    GoRoute(
      path: AppRoutes.login,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),

    // Register Page
    GoRoute(
      path: AppRoutes.register,
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterPage();
      },
    ),

    // Dashboard Page
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (BuildContext context, GoRouterState state) {
        // Coba ambil user dari extra terlebih dahulu
        var user = state.extra as UserModel?;

        // Jika tidak ada extra, rebuild widget ketika data siap
        if (user == null) {
          return const DashboardPageWrapper();
        }
        return DashboardPage(user: user);
      },
    ),

    // Product Page
    GoRoute(
      path: '${AppRoutes.product}/:category',
      builder: (BuildContext context, GoRouterState state) {
        final category = state.pathParameters['category'] ?? 'All';
        return ProductPage(
          category: category,
          onAddToCart: (product) {
            // Handle add to cart
          },
        );
      },
    ),

    // Cart Page
    GoRoute(
      path: AppRoutes.cart,
      builder: (BuildContext context, GoRouterState state) {
        return CartPage(
          onRemove: (index) {},
          cart: const [],
        );
      },
    ),

    // Checkout Page
    GoRoute(
      path: AppRoutes.checkout,
      builder: (BuildContext context, GoRouterState state) {
        return const CheckoutPage();
      },
    ),

    // Profile Page
    GoRoute(
      path: AppRoutes.profile,
      builder: (BuildContext context, GoRouterState state) {
        final user = state.extra as UserModel?;
        if (user == null) {
          return const SplashScreen();
        }
        return ProfilePage(user: user);
      },
    ),

    // About Us Page
    GoRoute(
      path: AppRoutes.aboutUs,
      builder: (BuildContext context, GoRouterState state) {
        return const AboutUs();
      },
    ),

    // Menu Admin Page
    GoRoute(
      path: AppRoutes.menuAdmin,
      builder: (BuildContext context, GoRouterState state) {
        return const MenuAdmin();
      },
    ),

    // Detail Produk Page
    GoRoute(
      path: AppRoutes.detailProduk,
      builder: (BuildContext context, GoRouterState state) {
        final product = state.extra as Map<String, dynamic>?;
        if (product == null) {
          return const SplashScreen();
        }
        return DetailProduk(product: product);
      },
    ),

    // Detail Kaos Page
    GoRoute(
      path: AppRoutes.detailKaos,
      builder: (BuildContext context, GoRouterState state) {
        final product = state.extra as Map<String, dynamic>?;
        if (product == null) {
          return const SplashScreen();
        }
        return DetailKaos(product: product);
      },
    ),

    // Detail Hoodie Page
    GoRoute(
      path: AppRoutes.detailHoodie,
      builder: (BuildContext context, GoRouterState state) {
        final product = state.extra as Map<String, dynamic>?;
        if (product == null) {
          return const SplashScreen();
        }
        return DetailHoodie(product: product);
      },
    ),
  ],
);
