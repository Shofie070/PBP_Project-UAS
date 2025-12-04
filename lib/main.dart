import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import pages
import 'features/shared/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/home/presentation/pages/dashboard_page.dart';
import 'features/checkout/presentation/pages/checkout_page.dart'
    as checkout_page;
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/about/presentation/pages/about_us_page.dart';
import 'features/about/presentation/pages/about_app_page.dart';
import 'features/product/presentation/pages/product_detail_page.dart';
import 'features/checkout/presentation/pages/payment_page.dart';
import 'features/checkout/presentation/pages/purchase_history_page.dart';
import 'features/product/presentation/pages/favorite_page.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

// Import model dan service
import 'model/model.dart';
import 'features/shared/routes/app_router.dart';
import 'features/shared/services/theme_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/product/presentation/cubit/product_cubit.dart';
import 'features/product/data/datasources/product_service.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';

final GoRouter _appRouter = GoRouter(
  initialLocation: AppRoutes.initialRoute,
  routes: [
    GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen()),
    GoRoute(
        path: AppRoutes.login, builder: (context, state) => const LoginPage()),
    GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage()),
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
          user: user ??
              const UserModel(
                  username: 'Guest', email: 'guest@example.com', password: ''),
        );
      },
    ),
    GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const KeranjangPage()),
    GoRoute(
        path: AppRoutes.purchaseHistory,
        builder: (context, state) => const RiwayatPembelianPage()),
    GoRoute(
        path: AppRoutes.favorit,
        builder: (context, state) => const FavoritPage()),
    GoRoute(
        path: AppRoutes.about, builder: (context, state) => const AboutUs()),
    GoRoute(
        path: AppRoutes.aboutApp,
        builder: (context, state) => const AboutAppPage()),
    GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(
            user: UserModel(username: 'User', email: '', password: ''))),
    GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const checkout_page.CheckoutPage()),
    GoRoute(
        path: AppRoutes.detailProduk,
        builder: (context, state) =>
            DetailProduk(product: state.extra as Product)),
    GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final products = extra?['products'] as List<Product>? ?? [];
          final totalAmount = extra?['totalAmount'] as double? ?? 0.0;
          return PaymentPage(products: products, totalAmount: totalAmount);
        }),
    GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
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
    GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage()),
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()..checkLoginStatus()),
        BlocProvider(
            create: (context) =>
                ProductCubit(ProductService())..fetchProducts()),
        BlocProvider(create: (context) => CartCubit()..loadCart()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.themeModeNotifier,
            builder: (context, themeMode, _) {
              return ValueListenableBuilder<String>(
                valueListenable: ThemeService.languageNotifier,
                builder: (context, language, _) {
                  return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    routerConfig: _appRouter,
                    theme: ThemeService.getLightTheme(),
                    darkTheme: ThemeService.getDarkTheme(),
                    themeMode: themeMode,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
