import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndPrintInvoice(
      Map<String, dynamic> record) async {
    final pdf = pw.Document();
    final formatRupiah =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final timestamp = record['timestamp'] ?? '';
    final items = (record['items'] as List<dynamic>?) ?? [];
    final receiptId = record['id'] as String? ?? 'RCPT-000';
    final paymentMethod = record['paymentMethod'] as String? ?? 'N/A';
    final shipping = (record['shipping'] as num?)?.toDouble() ?? 0.0;
    final tax = (record['tax'] as num?)?.toDouble() ?? 0.0;
    final total = (record['total'] as num?)?.toDouble() ?? 0.0;
    double subtotal = 0.0;

    // Calculate subtotal
    for (final it in items) {
      if (it is Map<String, dynamic>) {
        final priceRaw = it['price'];
        double price = 0.0;
        if (priceRaw is num) {
          price = priceRaw.toDouble();
        } else if (priceRaw is String) {
          price = double.tryParse(priceRaw) ?? 0.0;
        }
        subtotal += price;
      }
    }

    String formattedDate = timestamp;
    try {
      final dt = DateTime.parse(timestamp);
      formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('UrbanWear',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('INVOICE',
                        style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Receipt ID: $receiptId'),
                      pw.Text('Date: $formattedDate'),
                      pw.Text('Payment Method: $paymentMethod'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Item',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Price',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  // Items
                  ...items.map((it) {
                    final name =
                        (it['name'] ?? it['title'] ?? 'Product').toString();
                    final priceRaw = it['price'];
                    double price = 0.0;
                    if (priceRaw is num) {
                      price = priceRaw.toDouble();
                    } else if (priceRaw is String) {
                      price = double.tryParse(priceRaw) ?? 0.0;
                    }
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(formatRupiah.format(price),
                              textAlign: pw.TextAlign.right),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Subtotal: ${formatRupiah.format(subtotal)}'),
                      pw.Text('Shipping: ${formatRupiah.format(shipping)}'),
                      pw.Text('Tax: ${formatRupiah.format(tax)}'),
                      pw.Divider(),
                      pw.Text('Total: ${formatRupiah.format(total)}',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Center(
                child: pw.Text('Thank you for shopping with UrbanWear!',
                    style: const pw.TextStyle(color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice-$receiptId',
    );
  }
}
