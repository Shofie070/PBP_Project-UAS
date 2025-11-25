// lib/keranjang_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/model.dart';
import 'checkout.dart'; // pastikan file checkout.dart ada

class KeranjangPage extends StatefulWidget {
  final DashboardModel cartModel;
  const KeranjangPage({super.key, required this.cartModel});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final rupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  late List<CartItem> items;

  @override
  void initState() {
    super.initState();
    items = widget.cartModel.products.map((p) => CartItem(product: p)).toList();
  }

  double get totalHarga => items
      .where((i) => i.selected)
      .fold(0, (sum, i) => sum + (i.product.price * i.quantity));

  int get totalItemTerpilih => items.where((i) => i.selected).length;

  void selectAll(bool selected) {
    setState(() {
      for (var item in items) {
        item.selected = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Keranjang Saya",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})
        ],
      ),

      body: items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Keranjang kosong",
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                // Voucher & Koin
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.local_offer, color: Colors.orange),
                        title: const Text("Voucher Toko",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text(
                            "Gunakan voucher untuk diskon lebih besar"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Fitur voucher segera hadir!")),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text("Gunakan Koin Urban"),
                        subtitle: const Text("Dapatkan cashback"),
                        value: false,
                        onChanged: (v) {},
                        secondary: const Icon(Icons.monetization_on,
                            color: Colors.amber),
                      ),
                    ],
                  ),
                ),

                // Header Toko + Chat Admin
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: items.isEmpty
                            ? false
                            : items.every((i) => i.selected),
                        onChanged:
                            items.isEmpty ? null : (v) => selectAll(v ?? false),
                      ),
                      const Icon(Icons.store, size: 20),
                      const SizedBox(width: 8),
                      const Text("Urban Wear Official",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text("Chat Admin"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Membuka chat dengan Admin Urban Wear...")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Daftar Produk
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: item.selected,
                                onChanged: (v) =>
                                    setState(() => item.selected = v!),
                              ),
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.image,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    const Text("Hitam • Ukuran L",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 13)),
                                    const SizedBox(height: 8),
                                    Text(rupiah.format(item.product.price),
                                        style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () =>
                                        setState(() => items.removeAt(i)),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        onPressed: item.quantity > 1
                                            ? () =>
                                                setState(() => item.quantity--)
                                            : null,
                                      ),
                                      Text("${item.quantity}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        onPressed: () =>
                                            setState(() => item.quantity++),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

      // Floating Checkout Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            Checkbox(
              value: items.isEmpty ? false : items.every((i) => i.selected),
              onChanged: items.isEmpty ? null : (v) => selectAll(v ?? false),
            ),
            const Text("Pilih Semua",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Total Belanja",
                    style: TextStyle(color: Colors.grey)),
                Text(rupiah.format(totalHarga),
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: totalItemTerpilih > 0
                  ? () {
                      final selectedProducts = items
                          .where((i) => i.selected)
                          .map((i) => i.product)
                          .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CheckoutPage(products: selectedProducts),
                          settings: RouteSettings(arguments: selectedProducts),
                        ),
                      );
                    }
                  : null,
              child: Text("Checkout ($totalItemTerpilih)",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// Model Cart Item
class CartItem {
  final Product product;
  bool selected;
  int quantity;

  CartItem({required this.product, this.selected = true, this.quantity = 1});
}
