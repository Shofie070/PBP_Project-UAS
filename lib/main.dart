import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart'; // <--- BARU: Import sizer
import 'splash_screen.dart';
import 'checkout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      // <--- BARU: Bungkus dengan Sizer
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          routes: {
            '/checkout': (context) => const CheckoutPage(),
          },
        );
      },
    );
  }
}
