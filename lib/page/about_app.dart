import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. BACKGROUND (Dengan Error Handler)
          Container(
            color: Colors.black, // Warna dasar jika gambar gagal
            child: Image.asset(
              'assets/images/bg3.jpg', // Pastikan nama file ini benar (huruf kecil semua)
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Jika bg3.jpg tidak ketemu, pakai warna gradient ini
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. OVERLAY GELAP
          Container(
            color: Colors.black.withOpacity(0.7), // Sedikit lebih gelap agar teks kontras
          ),

          // 3. KONTEN TENGAH
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO (Dengan Error Handler)
                  Container(
                    width: 35.w,
                    height: 35.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.5), // Glow Ungu
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/gg.jpg', // Pastikan logo.png ada di assets/images/
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.android, size: 60, color: Colors.white),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 3.h),

                  // TEKS JUDUL
                  const Text(
                    "URBAN WEAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // BADGE VERSI
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white54),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Versi 1.0.0",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // DESKRIPSI
                  const Text(
                    "Aplikasi E-Commerce Terlengkap\nuntuk Gaya Hidup Anda.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // FOOTER
                  const Text(
                    "© 2025 Kelompok 1 PBP",
                    style: TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}