import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import pages
import 'page/splash_screen.dart';
import 'page/login.dart';
import 'page/register_page.dart';
import 'page/DashboardPage.dart';
import 'page/checkout.dart' as checkout_page;
import 'page/keranjang_page.dart';
import 'page/profile.dart';
import 'page/about_us.dart';
import 'page/about_app.dart'; // <--- IMPORT FILE BARU
import 'page/product.dart';
import 'page/detail_produk.dart';
import 'page/menu_admin.dart';
import 'page/payment_page.dart';
import 'page/riwayat_pembelian.dart';
import 'page/favorit_page.dart';
import 'page/chat.dart';

// Import model dan service
import 'model/model.dart';
import 'service/app_router.dart';
import 'service/theme_service.dart';

final GoRouter _appRouter = GoRouter(
  initialLocation: AppRoutes.initialRoute,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
    GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterPage()),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) {
        final extra = state.extra;
        UserModel? user;
        if (extra is UserModel) {
          user = extra;
        } else if (extra is Map<String, dynamic>) {
          user = UserModel.fromJson(extra);
        }
        return DashboardPage(
          user: user ?? UserModel(username: 'Guest', email: 'guest@example.com'),
        );
      },
    ),
    
    GoRoute(path: AppRoutes.cart, builder: (context, state) => KeranjangPage(cartModel: DashboardModel())),
    GoRoute(path: AppRoutes.purchaseHistory, builder: (context, state) => const RiwayatPembelianPage()),
    GoRoute(path: AppRoutes.favorit, builder: (context, state) => const FavoritPage()),
    
    GoRoute(path: AppRoutes.about, builder: (context, state) => const AboutUs()),
    
    // DAFTARKAN ROUTE BARU DI SINI
    GoRoute(path: AppRoutes.aboutApp, builder: (context, state) => const AboutAppPage()),

    GoRoute(
      path: AppRoutes.profile, 
      builder: (context, state) => ProfilePage(user: UserModel(username: 'User', email: ''))
    ),
    
    GoRoute(path: AppRoutes.checkout, builder: (context, state) => const checkout_page.CheckoutPage()),
    GoRoute(path: AppRoutes.detailProduk, builder: (context, state) => DetailProduk(product: state.extra as Map<String, dynamic>)),
    
    GoRoute(path: AppRoutes.payment, builder: (context, state) {
       final extra = state.extra as Map<String, dynamic>?;
       final products = extra?['products'] as List<Product>? ?? [];
       final totalAmount = extra?['totalAmount'] as double? ?? 0.0;
       return PaymentPage(products: products, totalAmount: totalAmount);
    }),
    
    GoRoute(path: AppRoutes.chat, builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      final userId = extra?['userId'] as String? ?? '';
      final userName = extra?['userName'] as String? ?? 'User';
      final userEmail = extra?['userEmail'] as String? ?? '';
      return ChatPage(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      );
    }),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService().getThemeMode();
  await ThemeService().getLanguage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        // LISTENER 1: Tema (Dark/Light)
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeModeNotifier,
          builder: (context, themeMode, _) {
            // LISTENER 2: Bahasa (ID/EN) - INI YANG BARU
            return ValueListenableBuilder<String>(
              valueListenable: ThemeService.languageNotifier,
              builder: (context, language, _) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  routerConfig: _appRouter,
                  // Konfigurasi Tema
                  theme: ThemeService.getLightTheme(),
                  darkTheme: ThemeService.getDarkTheme(),
                  themeMode: themeMode,
                  // Bahasa akan dihandle manual via LocalizationService.get()
                );
              },
            );
          },
        );
      },
    );
  }
}