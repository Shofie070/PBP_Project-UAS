import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../model/model.dart';
import '../service/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    // ... (Controller dan Animation)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, 0.1),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // GANTI TIMER LAMA DENGAN FUNGSI BARU UNTUK CEK LOGIN
    _checkLoginStatus();
  }

  // FUNGSI BARU: Cek status login
  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Cek status login persisted
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final String? currentEmail = prefs.getString('current_user_email');
    final String? username = prefs.getString('user_name');

    // Tunda selama 4 detik (agar Splash Screen tetap tampil)
    await Future.delayed(const Duration(seconds: 4));

    if (isLoggedIn && currentEmail != null && mounted) {
      // Jika user persistent login, masuk ke dashboard
      if (mounted) {
        context.go(
          AppRoutes.dashboard,
          extra: UserModel(username: username ?? 'User', email: currentEmail),
        );
      }
    } else if (currentEmail != null && username != null && mounted) {
      // Backward compatible: jika pernah registrasi tapi belum set is_logged_in
      if (mounted) {
        context.go(
          AppRoutes.dashboard,
          extra: UserModel(username: username, email: currentEmail),
        );
      }
    } else if (mounted) {
      // Jika data tidak ada (belum login), arahkan ke LoginPage
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ... (Metode build tetap sama)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi naik-turun
            SlideTransition(
              position: _offsetAnimation,
              child: Image.asset(
                'assets/images/splash.png',
                width: 50.w, // Menggunakan w
                height: 50.w, // Menggunakan w
              ),
            ),
            SizedBox(height: 5.h), // Menggunakan h, Dihapus const

            // Loading bar horizontal
            SizedBox(
              // Dihapus const
              width: 50.w, // Menggunakan w
              child: const LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                backgroundColor: Colors.black12,
                minHeight: 6,
              ),
            ),

            SizedBox(height: 3.h), // Menggunakan h, Dihapus const

            // Tambahan tulisan
            Text(
              // Dihapus const
              "dibuat oleh: Kelompok 1 IHIRRRRRRRRRRRR",
              style: TextStyle(
                // Dihapus const
                fontSize: 10.sp, // Menggunakan sp
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
