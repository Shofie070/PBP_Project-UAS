// lib/order_receipt_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderReceiptPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String orderId;
  final DateTime orderDate;

  const OrderReceiptPage({
    super.key,
    required this.items,
    required this.orderId,
    required this.orderDate,
  });

  // Fungsi hitung total AMAN meskipun ga ada qty atau price null
  double calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (double sum, item) {
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final qty = (item['qty'] as num?)?.toInt() ?? 1;
      return sum + (price * qty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    final double subtotal = calculateTotal(items);
    final double shipping = 15000;
    final double total = subtotal + shipping;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Struk Belanja"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Struk
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long,
                          size: 70, color: Colors.pinkAccent),
                      const SizedBox(height: 12),
                      Text(
                        "TERIMA KASIH SUDAH BERBELANJA!",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[700]),
                      ),
                      const SizedBox(height: 4),
                      const Text("Urban Wear",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent)),
                      const SizedBox(height: 8),
                      Text("Order ID: $orderId",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                      Text(DateFormat('dd MMMM yyyy • HH:mm').format(orderDate),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                const Divider(thickness: 2, color: Colors.pinkAccent),

                const Text("Detail Pesanan",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // List Item
                ...items.map((item) {
                  final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                  final qty = (item['qty'] as num?)?.toInt() ?? 1;
                  final itemTotal = price * qty;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            item['image'] ?? 'assets/images/placeholder.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 40)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Produk',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text("Qty: $qty",
                                  style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text(formatter.format(price),
                                  style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                        ),
                        Text(
                          formatter.format(itemTotal),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const Divider(thickness: 2, color: Colors.pinkAccent),

                // Ringkasan Pembayaran
                _buildSummaryRow("Subtotal", formatter.format(subtotal)),
                _buildSummaryRow("Ongkos Kirim", formatter.format(shipping)),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  "Total Pembayaran",
                  formatter.format(total),
                  isBold: true,
                  fontSize: 20,
                  color: Colors.pinkAccent,
                ),

                const SizedBox(height: 30),

                // Tombol Selesai
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle, size: 28),
                    label: const Text("Selesai",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Barang akan dikirim dalam 1-3 hari kerja\nTerima kasih atas kepercayaannya ♥",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, double fontSize = 16, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
