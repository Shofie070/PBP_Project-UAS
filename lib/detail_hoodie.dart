import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailHoodie extends StatelessWidget {
  final Map<String, dynamic> product;
  const DetailHoodie({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Formatter Rupiah
    final formatRupiah =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Theme(
      data: ThemeData.dark(), // Pakai tema gelap agar konsisten dengan About Us
      child: Scaffold(
        extendBodyBehindAppBar:
            true, // Agar background menyatu ke atas (seperti About Us)
        appBar: AppBar(
          title: Text(
            product['name'] ?? 'Detail Hoodie',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.transparent, // Transparan
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Image (Sama seperti About Us)
            Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),

            // 2. Overlay Gelap (Agar tulisan terbaca jelas)
            Container(color: Colors.black.withOpacity(0.7)),

            // 3. Konten Utama
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kartu Produk
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFF1E1E1E), // Warna Solid Gelap (Sama kayak About Us)
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white12), // Border tipis
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
                          // Gambar Produk
                          if (product['image'] != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Background putih di belakang gambar agar jelas
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.network(
                                product['image'],
                                height: 200,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const SizedBox(
                                    height: 200,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.black)),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                    height: 200,
                                    child: Icon(Icons.broken_image,
                                        size: 80, color: Colors.grey),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Nama Produk
                          Text(
                            product['name'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Harga
                          Text(
                            formatRupiah.format(product['price']),
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 15),

                          // Deskripsi
                          const Text(
                            'The Future of Streetwear. Dibuat dengan bahan berkualitas premium untuk gaya urban maksimal.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Tombol Add to Cart (Putih kontras, seperti tombol v1.0.0 di About Us)
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Tombol Putih
                                foregroundColor: Colors.black, // Teks Hitam
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context, product);
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_cart_outlined),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add to Cart',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
