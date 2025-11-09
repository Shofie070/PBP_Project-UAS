import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl

class DetailKaos extends StatelessWidget {
  final Map<String, dynamic> product;
  const DetailKaos({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatRupiah =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
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
                margin: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (product['image'] != null)
                        // --- GANTI KE IMAGE.NETWORK ---
                        Image.network(
                          product['image'],
                          height: 200,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error,
                                size: 200, color: Colors.grey);
                          },
                        ),
                      const SizedBox(height: 16),
                      Text(
                        product['name'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // --- FORMAT HARGA ---
                      Text(
                        formatRupiah.format(product['price']),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      const Text('Detail produk kaos dari API.'),
                      const SizedBox(height: 16),
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