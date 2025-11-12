import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl
import 'package:sizer/sizer.dart'; // <--- Import sizer DITAMBAHKAN/DIPASTIKAN

class DetailKaos extends StatelessWidget {
  final Map<String, dynamic> product;
  const DetailKaos({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatRupiah =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(product['name'] ?? 'Detail Kaos'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.png', fit: BoxFit.cover),
          Center(
            child: SingleChildScrollView(
              child: Card(
                margin: EdgeInsets.symmetric(
                    horizontal: 10.w), // Menggunakan w, Dihapus const
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(5.w), // Menggunakan w, Dihapus const
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (product['image'] != null)
                        // --- GANTI KE IMAGE.NETWORK ---
                        Image.network(
                          product['image'],
                          height: 50.w, // Menggunakan w
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error, // Dihapus const
                                size: 50.w,
                                color: Colors.grey); // Menggunakan w
                          },
                        ),
                      SizedBox(height: 2.h), // Menggunakan h, Dihapus const
                      Text(
                        product['name'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            // Dihapus const
                            fontSize: 16.sp, // Menggunakan sp
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 1.h), // Menggunakan h, Dihapus const
                      // --- FORMAT HARGA ---
                      Text(
                        formatRupiah.format(product['price']),
                        style: TextStyle(
                            fontSize: 14.sp), // Menggunakan sp, Dihapus const
                      ),
                      SizedBox(height: 2.h), // Menggunakan h, Dihapus const
                      const Text('Detail produk kaos dari API.'),
                      SizedBox(height: 2.h), // Menggunakan h, Dihapus const
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent),
                          onPressed: () {
                            Navigator.pop(context, product);
                          },
                          child: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
