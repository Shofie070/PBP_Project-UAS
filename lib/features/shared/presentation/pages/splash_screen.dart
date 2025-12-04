import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart'; // Pastikan package ini ada di pubspec.yaml
import 'package:go_router/go_router.dart'; // Pastikan package ini ada di pubspec.yaml

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Variabel Animasi
  late Animation<Offset> _textSlideAnim1; // "UNDER"
  late Animation<Offset> _textSlideAnim2; // "WEAR"
  late Animation<double> _splashScaleAnim; // Background Merah
  late Animation<double> _textScalePunch; // Efek Hentakan
  late Animation<Offset> _slideUpExitAnim; // Layar naik ke atas
  late Animation<double> _footerFadeAnim; // Animasi teks nama pembuat

  // Variabel untuk menampung rute tujuan
  String _targetRoute = '/login'; 
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();

    // Mengatur status bar transparan
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // 1. Setup Controller (Durasi animasi disesuaikan)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // 3 Detik total
    );

    // 2. Setup Animasi (Staggered)
    
    // Teks "UNDER" muncul
    _textSlideAnim1 = Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutExpo)),
    );

    // Teks "WEAR" muncul
    _textSlideAnim2 = Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.15, 0.45, curve: Curves.easeOutExpo)),
    );

    // Background merah melebar
    _splashScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.easeOutExpo)),
    );

    // Efek hentakan teks
    _textScalePunch = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.35, 0.55, curve: Curves.elasticOut)),
    );

    // Footer nama muncul pelan-pelan
    _footerFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeIn)),
    );

    // Seluruh layar geser ke atas untuk selesai
    _slideUpExitAnim = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.85, 1.0, curve: Curves.easeInOutCubic)),
    );

    // 3. Jalankan Logika
    _controller.forward();
    _checkLoginStatus(); // Cek data secara async di background

    // 4. Listener saat animasi selesai
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNext();
      }
    });
  }

  // LOGIKA CEK LOGIN (Dipertahankan dari kode Anda)
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final String? currentEmail = prefs.getString('current_user_email');
    final String? username = prefs.getString('user_name');

    // Tentukan rute tujuan
    if (isLoggedIn && currentEmail != null) {
      _targetRoute = '/dashboard';
    } else if (currentEmail != null && username != null) {
      _targetRoute = '/dashboard';
    } else {
      _targetRoute = '/login';
    }

    _isDataLoaded = true;
    
    // Jika animasi sudah selesai duluan tapi data belum siap (jarang terjadi karena durasi 3 detik),
    // fungsi ini akan dipanggil manual nanti.
    // Tapi karena kita pakai listener onComplete di controller, 
    // kita biarkan controller yang memicu navigasi.
  }

  void _navigateToNext() {
    // Pastikan data sudah selesai dimuat sebelum pindah
    if (_isDataLoaded) {
       // Gunakan pushReplacement atau go agar user tidak bisa back ke splash
       context.go(_targetRoute); 
    } else {
      // Fallback jika HP sangat lambat membaca SharedPrefs (tunggu data)
      Future.delayed(const Duration(milliseconds: 200), _navigateToNext);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Warna dasar hitam (di belakang slide up)
      body: SlideTransition(
        position: _slideUpExitAnim, // Efek layar naik di akhir
        child: Container(
          color: Colors.black, // Warna Splash Screen
          width: 100.w,
          height: 100.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              
              // --- LAYER 1: Splash Merah Background ---
              AnimatedBuilder(
                animation: _splashScaleAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scaleX: _splashScaleAnim.value,
                    scaleY: 1.0,
                    child: Container(
                      width: 150.w, // Menggunakan Sizer
                      height: 15.h, // Menggunakan Sizer
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 4, 26, 224).withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 16, 5, 227).withOpacity(0.5),
                            blurRadius: 50,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),

              // --- LAYER 2: Teks Utama (UNDER WEAR) ---
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _textScalePunch.value > 1.0 
                        ? _textScalePunch.value 
                        : (_textScalePunch.status == AnimationStatus.completed ? 1.0 : _textScalePunch.value),
                    child: Transform(
                      transform: Matrix4.skewX(-0.1), // Efek miring
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMaskedText("UNDER", _textSlideAnim1, Colors.white),
                          _buildMaskedText("WEAR", _textSlideAnim2, const Color.fromARGB(255, 253, 253, 253)),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // --- LAYER 3: Footer Nama Pembuat ---
              Positioned(
                bottom: 5.h, // Jarak dari bawah pakai Sizer
                child: FadeTransition(
                  opacity: _footerFadeAnim,
                  child: Text(
                    "dibuat oleh: Kelompok 1",
                    style: TextStyle(
                      fontSize: 5.sp, // Menggunakan Sizer
                      fontWeight: FontWeight.w500,
                      color: Colors.white54, // Warna disesuaikan dengan background gelap
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Pembantu untuk Efek Masking Teks
  Widget _buildMaskedText(String text, Animation<Offset> anim, Color color) {
    return ClipRect(
      child: SlideTransition(
        position: anim,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 45.sp, // Ukuran font responsif dengan Sizer
            fontWeight: FontWeight.w900,
            color: color,
            height: 0.9,
            letterSpacing: -2.0,
          ),
        ),
      ),
    );
  }
}