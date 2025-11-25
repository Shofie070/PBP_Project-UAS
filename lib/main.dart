import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'checkout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/checkout': (context) => const CheckoutPage(
              products: [],
            ),
      },
    );
  }
}
