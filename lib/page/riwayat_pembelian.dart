import 'dart:convert';

import 'package:flutter/material.dart';
// Removed package:intl to avoid LocaleDataException in environments where
// Intl locales are not initialized. Use manual formatting below.
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatPembelianPage extends StatefulWidget {
  const RiwayatPembelianPage({super.key});

  @override
  State<RiwayatPembelianPage> createState() => _RiwayatPembelianPageState();
}

class _RiwayatPembelianPageState extends State<RiwayatPembelianPage> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('purchase_history') ?? [];
    _history = [];
    for (final s in list) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) {
          _history.add(decoded);
        }
      } catch (_) {}
    }
    if (mounted) setState(() {});
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('purchase_history');
    await _loadHistory();
  }

  Future<void> _deleteHistoryItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('purchase_history') ?? [];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setStringList('purchase_history', list);
      await _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembelian'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Simple pop - akan kembali ke halaman sebelumnya
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Riwayat'),
                  content: const Text('Hapus semua riwayat pembelian?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
                  ],
                ),
              );
              if (ok == true) await _clearHistory();
            },
          )
        ],
      ),
      body: _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat pembelian',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final record = _history[index];
                final timestamp = record['timestamp'] ?? '';
                final items = (record['items'] as List<dynamic>?) ?? [];
                final receiptId = record['id'] as String? ?? 'RCPT-${index + 1}';
                final paymentMethod = record['paymentMethod'] as String? ?? 'N/A';
                
                double subtotal = 0.0;
                double shipping = (record['shipping'] as num?)?.toDouble() ?? 10000.0;
                double tax = (record['tax'] as num?)?.toDouble() ?? 0.0;
                double total = (record['total'] as num?)?.toDouble() ?? 0.0;

                final itemWidgets = <Widget>[];
                for (final it in items) {
                  if (it is Map<String, dynamic>) {
                    final name = (it['name'] ?? it['title'] ?? 'Produk').toString();
                    final priceRaw = it['price'];
                    double price = 0.0;
                    if (priceRaw is num) price = priceRaw.toDouble();
                    else if (priceRaw is String) price = double.tryParse(priceRaw) ?? 0.0;
                    subtotal += price;
                    itemWidgets.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Rp ${price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }

                // Format timestamp safely without intl
                String formattedDate = timestamp;
                try {
                  final dt = DateTime.parse(timestamp);
                  const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
                  final day = dt.day.toString().padLeft(2, '0');
                  final month = months[dt.month - 1];
                  final year = dt.year;
                  final hour = dt.hour.toString().padLeft(2, '0');
                  final minute = dt.minute.toString().padLeft(2, '0');
                  formattedDate = '$day $month $year, $hour:$minute';
                } catch (_) {
                  // leave original timestamp if parsing fails
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  receiptId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Berhasil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Items
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item Pembelian',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            ...itemWidgets,
                            SizedBox(height: 12),
                            const Divider(height: 1),
                            SizedBox(height: 12),
                            // Summary
                            _buildSummaryRow('Subtotal', subtotal),
                            SizedBox(height: 6),
                            _buildSummaryRow('Ongkos Kirim', shipping),
                            SizedBox(height: 6),
                            _buildSummaryRow('Pajak', tax),
                            SizedBox(height: 12),
                            const Divider(height: 1, thickness: 2),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Rp ${total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Metode: $paymentMethod',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Actions
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text('Download PDF'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Fitur download PDF akan datang segera'),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.print, size: 18),
                                label: const Text('Cetak'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Fitur cetak akan datang segera'),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Hapus'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Hapus Pesanan'),
                                      content: const Text('Hapus pesanan ini dari riwayat?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await _deleteHistoryItem(index);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          'Rp ${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
