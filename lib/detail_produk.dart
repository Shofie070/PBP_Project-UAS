import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart'; // <--- Import sizer DITAMBAHKAN/DIPASTIKAN

class DetailProduk extends StatelessWidget {
  final Map<String, dynamic> product;

  const DetailProduk({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(product["name"]),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content with overlay
          SingleChildScrollView(
            child: Column(
              children: [
                // Product Image (Centered and Bigger)
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        vertical: 2.h), // Menggunakan h, Dihapus const
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/images/kaos1.png", // Gambar kaos pertama
                        width: MediaQuery.of(context).size.width *
                            0.8, // Lebar 80% layar
                        height: 40.h, // Menggunakan h
                        fit: BoxFit.contain, // Gambar tidak terpotong
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h), // Menggunakan h, Dihapus const

                // Product Details with White Background
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w), // Menggunakan w, Dihapus const
                  decoration: BoxDecoration(
                    color: Colors.white, // Overlay putih untuk teks
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(
                      horizontal: 4.w), // Menggunakan w, Dihapus const
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Product Name
                      Text(
                        product["name"],
                        style: TextStyle(
                          // Dihapus const
                          fontSize: 17.sp, // Menggunakan sp
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.5.h), // Menggunakan h, Dihapus const

                      // Product Price
                      Text(
                        "Rp ${product["price"]}",
                        style: TextStyle(
                          // Dihapus const
                          fontSize: 15.sp, // Menggunakan sp
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 3.h), // Menggunakan h, Dihapus const

                      // Add to Cart Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${product["name"]} ditambahkan ke keranjang",
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h), // Menggunakan h, Dihapus const
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            // Dihapus const
                            "Tambah ke Keranjang",
                            style: TextStyle(fontSize: 13.sp), // Menggunakan sp
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
