import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../service/localization_service.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final String? language;
  
  const PaymentPage({
    super.key,
    required this.totalAmount,
    this.language = 'id',
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'credit_card';
  bool _isProcessing = false;
  final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final lang = widget.language ?? 'id';
    
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
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 5.w,
                vertical: 2.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ORDER SUMMARY ---
                  _buildOrderSummary(isDesktop, lang),
                  SizedBox(height: 3.h),

                  // --- PAYMENT METHOD SELECTION ---
                  Text(
                    LocalizationService.get(lang, 'paymentMethod'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildPaymentMethodOption(
                    'credit_card',
                    LocalizationService.get(lang, 'creditCard'),
                    Icons.credit_card,
                    isDesktop,
                  ),
                  SizedBox(height: 1.5.h),
                  _buildPaymentMethodOption(
                    'bank_transfer',
                    LocalizationService.get(lang, 'bankTransfer'),
                    Icons.account_balance,
                    isDesktop,
                  ),
                  SizedBox(height: 1.5.h),
                  _buildPaymentMethodOption(
                    'ewallet',
                    LocalizationService.get(lang, 'eWallet'),
                    Icons.wallet_membership,
                    isDesktop,
                  ),
                  SizedBox(height: 3.h),

                  // --- PAYMENT DETAILS ---
                  _buildPaymentDetails(lang, isDesktop),
                  SizedBox(height: 3.h),

                  // --- CONFIRM BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 5.5.h,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              LocalizationService.get(lang, 'confirm'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(bool isDesktop, String lang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LocalizationService.get(lang, 'total')),
              Text(
                formatRupiah.format(widget.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping Fee'),
              Text(formatRupiah.format(10000)),
            ],
          ),
          SizedBox(height: 1.5.h),
          const Divider(height: 1),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Final Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                formatRupiah.format(widget.totalAmount + 10000),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    String value,
    String label,
    IconData icon,
    bool isDesktop,
  ) {
    return Material(
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedPaymentMethod == value
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: _selectedPaymentMethod == value ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _selectedPaymentMethod == value
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: _selectedPaymentMethod,
                onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                _selectedPaymentMethod == value
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: _selectedPaymentMethod == value
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(String lang, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 2.h),
        if (_selectedPaymentMethod == 'credit_card') ...[
          TextField(
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'MM/YY',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
              ),
            ],
          ),
        ] else if (_selectedPaymentMethod == 'bank_transfer') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transfer ke rekening berikut:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 1.h),
                _buildBankInfo('Bank BCA', '1234 5678 9012', 'PT E-Commerce'),
                SizedBox(height: 1.h),
                _buildBankInfo('Bank Mandiri', '1234 5678 9012', 'PT E-Commerce'),
              ],
            ),
          ),
        ] else if (_selectedPaymentMethod == 'ewallet') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih E-Wallet:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 1.h),
                _buildEWalletOption('GCash', '0.5% cashback'),
                SizedBox(height: 1.h),
                _buildEWalletOption('OVO', '1% cashback'),
                SizedBox(height: 1.h),
                _buildEWalletOption('DANA', '2% cashback'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBankInfo(String bankName, String accountNo, String accountName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bankName, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(accountNo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(accountName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account number copied!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEWalletOption(String walletName, String benefit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(walletName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(benefit, style: const TextStyle(fontSize: 12, color: Colors.green)),
            ],
          ),
          const Icon(Icons.arrow_forward),
        ],
      ),
    );
  }

  void _processPayment() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isProcessing = false);
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Successful'),
            content: const Text('Your order has been confirmed!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/dashboard');
                },
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        );
      }
    });
  }
}
