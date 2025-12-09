import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import 'package:urban_wear_app/features/shared/services/pdf_service.dart';
import 'package:urban_wear_app/features/shared/routes/app_router.dart';

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
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 900;

      // PERBAIKAN: Menggunakan 'num' agar aman menerima int maupun double
      double responsiveSize(num mobileSp, num desktopPx) =>
          isDesktop ? desktopPx.toDouble() : mobileSp.toDouble().sp;

      return Scaffold(
        appBar: AppBar(
          title: Text('Riwayat Pembelian',
              style: TextStyle(fontSize: responsiveSize(16, 20))),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).iconTheme.color,
                size: responsiveSize(18, 24)),
            onPressed: () {
              context.go(AppRoutes.dashboard);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_forever,
                  color: Theme.of(context).iconTheme.color,
                  size: responsiveSize(18, 24)),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Riwayat'),
                    content: const Text('Hapus semua riwayat pembelian?'),
                    actions: [
                      TextButton(
                          onPressed: () => ctx.pop(false),
                          child: const Text('Batal')),
                      TextButton(
                          onPressed: () => ctx.pop(true),
                          child: const Text('Hapus')),
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
                    Icon(Icons.shopping_bag_outlined,
                        size: responsiveSize(40, 60), color: Colors.grey[400]),
                    SizedBox(height: isDesktop ? 16 : 2.h),
                    Text(
                      'Belum ada riwayat pembelian',
                      style: TextStyle(
                          color: Colors.grey, fontSize: responsiveSize(12, 16)),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(isDesktop ? 16 : 4.w),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final record = _history[index];
                  final timestamp = record['timestamp'] ?? '';
                  final items = (record['items'] as List<dynamic>?) ?? [];
                  final receiptId =
                      record['id'] as String? ?? 'RCPT-${index + 1}';
                  final paymentMethod =
                      record['paymentMethod'] as String? ?? 'N/A';

                  double subtotal = 0.0;
                  double shipping =
                      (record['shipping'] as num?)?.toDouble() ?? 10000.0;
                  double tax = (record['tax'] as num?)?.toDouble() ?? 0.0;
                  double total = (record['total'] as num?)?.toDouble() ?? 0.0;

                  final itemWidgets = <Widget>[];
                  for (final it in items) {
                    if (it is Map<String, dynamic>) {
                      final name =
                          (it['name'] ?? it['title'] ?? 'Produk').toString();
                      final priceRaw = it['price'];
                      double price = 0.0;
                      if (priceRaw is num) {
                        price = priceRaw.toDouble();
                      } else if (priceRaw is String) {
                        price = double.tryParse(priceRaw) ?? 0.0;
                      }
                      subtotal += price;
                      itemWidgets.add(
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 4 : 0.5.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: responsiveSize(10, 12)),
                                ),
                              ),
                              SizedBox(width: isDesktop ? 8 : 2.w),
                              Text(
                                'Rp ${price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: responsiveSize(10, 12),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  String formattedDate = timestamp;
                  try {
                    final dt = DateTime.parse(timestamp);
                    const months = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'Mei',
                      'Jun',
                      'Jul',
                      'Agu',
                      'Sep',
                      'Okt',
                      'Nov',
                      'Des'
                    ];
                    final day = dt.day.toString().padLeft(2, '0');
                    final month = months[dt.month - 1];
                    final year = dt.year;
                    final hour = dt.hour.toString().padLeft(2, '0');
                    final minute = dt.minute.toString().padLeft(2, '0');
                    formattedDate = '$day $month $year, $hour:$minute';
                  } catch (_) {}

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: isDesktop ? 16 : 2.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.all(isDesktop ? 16 : 4.w),
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsiveSize(11, 14),
                                    ),
                                  ),
                                  SizedBox(height: isDesktop ? 4 : 0.5.h),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: responsiveSize(10, 12),
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 12 : 3.w,
                                    vertical: isDesktop ? 6 : 0.8.h),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Berhasil',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsiveSize(10, 12),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Items
                        Padding(
                          padding: EdgeInsets.all(isDesktop ? 16 : 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item Pembelian',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsiveSize(11, 13),
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              SizedBox(height: isDesktop ? 8 : 1.h),
                              ...itemWidgets,
                              SizedBox(height: isDesktop ? 12 : 1.5.h),
                              const Divider(height: 1),
                              SizedBox(height: isDesktop ? 12 : 1.5.h),
                              // Summary
                              _buildSummaryRow(
                                  'Subtotal', subtotal, responsiveSize),
                              SizedBox(height: isDesktop ? 6 : 0.8.h),
                              _buildSummaryRow(
                                  'Ongkos Kirim', shipping, responsiveSize),
                              SizedBox(height: isDesktop ? 6 : 0.8.h),
                              _buildSummaryRow('Pajak', tax, responsiveSize),
                              SizedBox(height: isDesktop ? 12 : 1.5.h),
                              const Divider(height: 1, thickness: 2),
                              SizedBox(height: isDesktop ? 12 : 1.5.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsiveSize(11, 14),
                                    ),
                                  ),
                                  Text(
                                    'Rp ${total.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsiveSize(12, 16),
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isDesktop ? 12 : 1.5.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Metode: $paymentMethod',
                                    style: TextStyle(
                                      fontSize: responsiveSize(10, 12),
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Actions (DIPERBAIKI DISINI)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              isDesktop ? 16 : 4.w,
                              0,
                              isDesktop ? 16 : 4.w,
                              isDesktop ? 16 : 2.h), // Padding bawah saja
                          child: Row(
                            children: [
                              // Tombol Download
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: Icon(Icons.download,
                                      size:
                                          responsiveSize(14, 16)), // Icon kecil
                                  // PERBAIKAN: Jika desktop pakai teks panjang, jika HP pakai "PDF" saja
                                  label: Text(
                                      isDesktop ? 'Download PDF' : 'PDF',
                                      style: TextStyle(
                                          fontSize: responsiveSize(9, 11))),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4), // Padding tipis
                                    minimumSize:
                                        const Size(0, 36), // Tinggi button
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () async {
                                    await PdfService.generateAndPrintInvoice(
                                        record);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Tombol Cetak
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.print,
                                      size: responsiveSize(14, 16)),
                                  label: Text('Cetak',
                                      style: TextStyle(
                                          fontSize: responsiveSize(9, 11))),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    minimumSize: const Size(0, 36),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () async {
                                    await PdfService.generateAndPrintInvoice(
                                        record);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Tombol Hapus
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.delete,
                                      size: responsiveSize(14, 16)),
                                  label: Text('Hapus',
                                      style: TextStyle(
                                          fontSize: responsiveSize(9, 11))),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    minimumSize: const Size(0, 36),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Hapus Pesanan'),
                                        content: const Text(
                                            'Hapus pesanan ini dari riwayat?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => ctx.pop(false),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () => ctx.pop(true),
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
    });
  }

  Widget _buildSummaryRow(
      String label, double amount, Function responsiveSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsiveSize(10, 12),
            color: Colors.grey[600],
          ),
        ),
        Text(
          'Rp ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: responsiveSize(10, 12),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
