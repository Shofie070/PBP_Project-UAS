import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Tentang Aplikasi",
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // 1. Background Image (Tetap ada sebagai latar suasana)
            Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),

            // 2. Overlay Gelap (Agar background tidak terlalu terang)
            Container(
              color: Colors.black.withOpacity(0.7),
            ),

            // 3. Konten Utama
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- LOGO SECTION ---
                    _buildLogoSection(),

                    const SizedBox(height: 30),

                    // --- SOLID CARD DESCRIPTION (TIDAK TRANSPARAN) ---
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        // Warna Solid Gelap (Abu-abu Tua) agar kontras dengan teks putih
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white12), // Garis tipis
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "The Future of Streetwear",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Urban Wear hadir sebagai solusi gaya hidup modern Anda. Temukan koleksi eksklusif dari berbagai brand lokal dan internasional dalam satu genggaman.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors
                                  .white70, // Sedikit abu agar tidak menyakitkan mata
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 25),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 20),

                          // Fitur Unggulan
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFeatureItem(Icons.verified, "100% Ori"),
                              _buildFeatureItem(Icons.rocket_launch, "Cepat"),
                              _buildFeatureItem(Icons.lock, "Aman"),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // --- FOOTER ---
                    const Text(
                      "© 2025 Kelompok 1 Mobile Programming",
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Bagian Logo
  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E1E1E), // Solid background untuk logo juga
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(Icons.shopping_bag_outlined,
              size: 45, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          "URBAN WEAR",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "v1.0.0 Beta",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  // Widget Item Fitur Kecil
  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
