import 'package:flutter/material.dart';
// ✅ Tambahkan library WebView

class DetailKaos extends StatefulWidget {
  final Map<String, dynamic> product;
  const DetailKaos({super.key, required this.product});

  @override
  State<DetailKaos> createState() => _DetailKaosState();
}

class _DetailKaosState extends State<DetailKaos> {
  @override
  void initState() {
    super.initState();
    // ✅ Inisialisasi WebViewController dan muat halaman produk (contoh link)
  }

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}
