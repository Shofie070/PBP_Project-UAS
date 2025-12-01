import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/model.dart';
import '../service/localization_service.dart';

class PaymentPage extends StatefulWidget {
  final List<Product> products;
  final double totalAmount;
  final String? language;
  
  const PaymentPage({
    super.key,
    required this.products,
    required this.totalAmount,
    this.language = 'id',
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'credit_card';
  bool _isProcessing = false;
  String _email = '';
  final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email') ?? 
                  prefs.getString('user_email') ?? '';
    if (mounted) {
      setState(() => _email = email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language ?? 'id';
    final shippingFee = 10000.0;
    final tax = (widget.totalAmount * 0.1).toDouble();
    final finalTotal = widget.totalAmount + shippingFee + tax;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(LocalizationService.get(lang, 'payment')),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 6.w : 4.w,
                vertical: 2.h,
              ),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildOrderSummaryPanel(
                            lang,
                            widget.totalAmount,
                            shippingFee,
                            tax,
                            finalTotal,
                            isDesktop,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          flex: 1,
                          child: _buildPaymentForm(lang, isDesktop),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildOrderSummaryPanel(
                          lang,
                          widget.totalAmount,
                          shippingFee,
                          tax,
                          finalTotal,
                          isDesktop,
                        ),
                        SizedBox(height: 3.h),
                        _buildPaymentForm(lang, isDesktop),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentForm(String lang, bool isDesktop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CONTACT INFORMATION ---
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[50],
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              SizedBox(height: 1.2.h),
              TextField(
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  hintStyle: TextStyle(
                    fontSize: isDesktop ? 15 : 14,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0.8.h),
                ),
                onChanged: (value) => setState(() => _email = value),
                controller: TextEditingController.fromValue(
                  TextEditingValue(text: _email),
                ),
                style: TextStyle(
                  fontSize: isDesktop ? 15 : 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 3.h),

        // --- PAYMENT METHOD ---
        Text(
          'Payment method',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 1.5.h),
        
        // Card option
        _buildPaymentMethodCard(
          'Card',
          Icons.credit_card,
          'card',
          isDesktop,
          isDark,
        ),
        SizedBox(height: 1.h),
        
        // PayPal option
        _buildPaymentMethodCard(
          'PayPal',
          Icons.payment,
          'paypal',
          isDesktop,
          isDark,
        ),
        SizedBox(height: 1.h),

        // E-Wallet options
        Text(
          'E-Wallet',
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: 1.h),
        _buildEWalletOptions(isDesktop, isDark),
        SizedBox(height: 2.5.h),

        // Bank Transfer options
        Text(
          'Transfer Bank',
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: 1.h),
        _buildBankTransferOptions(isDesktop, isDark),
        SizedBox(height: 3.h),

        // Pay button
        SizedBox(
          width: double.infinity,
          height: 5.5.h,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () => _processPayment(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isProcessing
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : Text(
                    'Pay now',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    String label,
    IconData icon,
    String value,
    bool isDesktop,
    bool isDark,
  ) {
    final isSelected = _selectedPaymentMethod == value;
    return Container(
      padding: EdgeInsets.all(isDesktop ? 14 : 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.blue[900] : Colors.blue[50])
            : (isDark ? Colors.grey[850] : Colors.grey[50]),
        border: Border.all(
          color: isSelected
              ? Colors.blue
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedPaymentMethod,
            onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
            fillColor: MaterialStateProperty.all(Colors.blue),
          ),
          SizedBox(width: 1.5.w),
          Icon(icon, color: Colors.blue, size: isDesktop ? 20 : 18),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 13 : 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEWalletOptions(bool isDesktop, bool isDark) {
    return Column(
      children: [
        _buildEWalletOption('GCash', 'gcash', isDesktop, isDark),
        SizedBox(height: 0.8.h),
        _buildEWalletOption('OVO', 'ovo', isDesktop, isDark),
        SizedBox(height: 0.8.h),
        _buildEWalletOption('DANA', 'dana', isDesktop, isDark),
      ],
    );
  }

  Widget _buildEWalletOption(
    String name,
    String value,
    bool isDesktop,
    bool isDark,
  ) {
    final isSelected = _selectedPaymentMethod == value;
    return Container(
      padding: EdgeInsets.all(isDesktop ? 12 : 10),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.blue[900] : Colors.blue[50])
            : (isDark ? Colors.grey[850] : Colors.grey[50]),
        border: Border.all(
          color: isSelected
              ? Colors.blue
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedPaymentMethod,
            onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
            fillColor: MaterialStateProperty.all(Colors.blue),
          ),
          SizedBox(width: 1.5.w),
          Text(
            name,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferOptions(bool isDesktop, bool isDark) {
    return Column(
      children: [
        _buildBankOption('BRI', 'bank_bri', isDesktop, isDark),
        SizedBox(height: 0.8.h),
        _buildBankOption('BCA', 'bank_bca', isDesktop, isDark),
        SizedBox(height: 0.8.h),
        _buildBankOption('Mandiri', 'bank_mandiri', isDesktop, isDark),
      ],
    );
  }

  Widget _buildBankOption(
    String name,
    String value,
    bool isDesktop,
    bool isDark,
  ) {
    final isSelected = _selectedPaymentMethod == value;
    return Container(
      padding: EdgeInsets.all(isDesktop ? 12 : 10),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.blue[900] : Colors.blue[50])
            : (isDark ? Colors.grey[850] : Colors.grey[50]),
        border: Border.all(
          color: isSelected
              ? Colors.blue
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedPaymentMethod,
            onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
            fillColor: MaterialStateProperty.all(Colors.blue),
          ),
          SizedBox(width: 1.5.w),
          Icon(Icons.account_balance, color: Colors.blue, size: isDesktop ? 18 : 16),
          SizedBox(width: 1.5.w),
          Text(
            name,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryPanel(
    String lang,
    double subtotal,
    double shipping,
    double tax,
    double total,
    bool isDesktop,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 18 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: isDesktop ? 15 : 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 2.h),
            
            // Items list with resizer
            if (widget.products.isNotEmpty) ...[
              Container(
                constraints: BoxConstraints(maxHeight: 20.h),
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      widget.products.length,
                      (index) {
                        final p = widget.products[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isDesktop ? 12 : 11,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 0.4.h),
                                    // Resizer quantity
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Icon(
                                              Icons.remove,
                                              size: 14,
                                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(width: 0.5.w),
                                          Text(
                                            '1',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: isDark ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 0.5.w),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Icon(
                                              Icons.add,
                                              size: 14,
                                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                formatRupiah.format(p.price),
                                style: TextStyle(
                                  fontSize: isDesktop ? 12 : 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
              SizedBox(height: 1.5.h),
            ],

            // Pricing breakdown
            _buildPricingRow('Plan', subtotal, isDesktop),
            SizedBox(height: 1.h),
            _buildPricingRow('Shipping', shipping, isDesktop),
            SizedBox(height: 1.h),
            _buildPricingRow('Tax', tax, isDesktop),
            
            SizedBox(height: 1.2.h),
            Divider(height: 1, thickness: 1.5, color: isDark ? Colors.grey[700] : Colors.grey[300]),
            SizedBox(height: 1.2.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total due today',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  formatRupiah.format(total),
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingRow(String label, double amount, bool isDesktop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 12 : 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          formatRupiah.format(amount),
          style: TextStyle(
            fontSize: isDesktop ? 12 : 11,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _processPayment(BuildContext context) async {
    setState(() => _isProcessing = true);
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isProcessing = false);
      
      // Generate receipt data
      final receiptData = {
        'id': 'RCPT-${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
        'email': _email,
        'items': widget.products.map((p) => p.toJson()).toList(),
        'subtotal': widget.totalAmount,
        'shipping': 10000.0,
        'tax': widget.totalAmount * 0.1,
        'total': widget.totalAmount + 10000.0 + (widget.totalAmount * 0.1),
        'paymentMethod': _selectedPaymentMethod,
      };
      
      // Save receipt to SharedPreferences (as part of purchase history)
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('purchase_history') ?? [];
      history.add(jsonEncode(receiptData));
      await prefs.setStringList('purchase_history', history);
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 1.5.h),
              const Text('Pembayaran Berhasil'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                _email,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 1.5.h),
              Text(
                'Nomor Transaksi:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                receiptData['id'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 1.5.h),
              Text(
                'Total Pembayaran:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                formatRupiah.format(receiptData['total']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(); // Close dialog
                  context.go('/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali ke Dashboard'),
              ),
            ),
          ],
        ),
      );
    }
  }
}
