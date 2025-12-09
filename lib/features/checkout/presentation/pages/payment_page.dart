import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../../../model/model.dart';
import '../../../../features/shared/services/localization_service.dart';
import '../../../../features/shared/routes/app_router.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

class PaymentPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentCubit()..loadInitialData(),
      child: PaymentView(
        products: products,
        totalAmount: totalAmount,
        language: language,
      ),
    );
  }
}

class PaymentView extends StatefulWidget {
  final List<Product> products;
  final double totalAmount;
  final String? language;

  const PaymentView({
    super.key,
    required this.products,
    required this.totalAmount,
    this.language,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final formatRupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language ?? 'id';
    const shippingFee = 25000.0;
    final tax = (widget.totalAmount * 0.1).toDouble();
    final finalTotal = widget.totalAmount + shippingFee + tax;

    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state.status == PaymentStatus.success &&
            state.receiptData != null) {
          _showSuccessDialog(context, state.receiptData!);
        }
        if (state.status == PaymentStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error')),
          );
        }
        if (_emailController.text != state.email &&
            state.email.isNotEmpty &&
            _emailController.text.isEmpty) {
          _emailController.text = state.email;
        }
      },
      builder: (context, state) {
        // Sync controller if needed
        if (_emailController.text != state.email &&
            state.email.isNotEmpty &&
            _emailController.text.isEmpty) {
          _emailController.text = state.email;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(AppRoutes.dashboard),
                ),
                title: Text(LocalizationService.get(lang, 'payment')),
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
                              child: _buildPaymentForm(
                                  context, state, lang, isDesktop),
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
                            _buildPaymentForm(context, state, lang, isDesktop),
                          ],
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentForm(
      BuildContext context, PaymentState state, String lang, bool isDesktop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<PaymentCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CONTACT INFORMATION ---
        Text(
          LocalizationService.get(lang, 'contactInfo'),
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
                LocalizationService.get(lang, 'email'),
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              SizedBox(height: 1.2.h),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: LocalizationService.get(lang, 'emailHint'),
                  hintStyle: TextStyle(
                    fontSize: isDesktop ? 15 : 14,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0.8.h),
                ),
                onChanged: (value) => cubit.updateEmail(value),
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
          LocalizationService.get(lang, 'paymentMethod'),
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 1.5.h),

        // Card option
        _buildPaymentMethodCard(
          context,
          state,
          LocalizationService.get(lang, 'creditCard'),
          Icons.credit_card,
          'card',
          isDesktop,
          isDark,
        ),
        SizedBox(height: 1.h),

        // PayPal option
        _buildPaymentMethodCard(
          context,
          state,
          'PayPal',
          Icons.payment,
          'paypal',
          isDesktop,
          isDark,
        ),
        SizedBox(height: 1.h),

        // E-Wallet options
        Text(
          LocalizationService.get(lang, 'eWallet'),
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: 1.h),
        _buildEWalletOptions(context, state, isDesktop, isDark),
        SizedBox(height: 2.5.h),

        // Bank Transfer options
        Text(
          LocalizationService.get(lang, 'bankTransfer'),
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: 1.h),
        _buildBankTransferOptions(context, state, isDesktop, isDark),
        SizedBox(height: 3.h),

        // Pay button
        SizedBox(
          width: double.infinity,
          height: 5.5.h,
          child: ElevatedButton(
            onPressed: state.status == PaymentStatus.loading
                ? null
                : () =>
                    cubit.processPayment(widget.products, widget.totalAmount),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: state.status == PaymentStatus.loading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : Text(
                    LocalizationService.get(lang, 'payNow'),
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
    BuildContext context,
    PaymentState state,
    String label,
    IconData icon,
    String value,
    bool isDesktop,
    bool isDark,
  ) {
    final isSelected = state.selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => context.read<PaymentCubit>().selectPaymentMethod(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isDesktop ? 16 : 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.05))
              : (isDark ? Colors.grey[850] : Colors.white),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            _buildLogo(value),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 20)
            else
              Icon(Icons.circle_outlined,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEWalletOptions(
      BuildContext context, PaymentState state, bool isDesktop, bool isDark) {
    return Column(
      children: [
        _buildEWalletOption(
            context, state, 'GoPay', 'gopay', isDesktop, isDark),
        SizedBox(height: 1.h),
        _buildEWalletOption(context, state, 'OVO', 'ovo', isDesktop, isDark),
        SizedBox(height: 1.h),
        _buildEWalletOption(context, state, 'DANA', 'dana', isDesktop, isDark),
      ],
    );
  }

  Widget _buildEWalletOption(
    BuildContext context,
    PaymentState state,
    String name,
    String value,
    bool isDesktop,
    bool isDark,
  ) {
    final isSelected = state.selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => context.read<PaymentCubit>().selectPaymentMethod(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isDesktop ? 14 : 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.05))
              : (isDark ? Colors.grey[850] : Colors.white),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildLogo(value),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: isDesktop ? 13 : 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 18)
            else
              Icon(Icons.circle_outlined,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBankTransferOptions(
      BuildContext context, PaymentState state, bool isDesktop, bool isDark) {
    return Column(
      children: [
        _buildBankOption(context, state, 'BRI', 'bank_bri', isDesktop, isDark),
        SizedBox(height: 1.h),
        _buildBankOption(context, state, 'BCA', 'bank_bca', isDesktop, isDark),
        SizedBox(height: 1.h),
        _buildBankOption(
            context, state, 'Mandiri', 'bank_mandiri', isDesktop, isDark),
      ],
    );
  }

  Widget _buildBankOption(
    BuildContext context,
    PaymentState state,
    String name,
    String value,
    bool isDesktop,
    bool isDark,
  ) {
    final isSelected = state.selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => context.read<PaymentCubit>().selectPaymentMethod(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isDesktop ? 14 : 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.05))
              : (isDark ? Colors.grey[850] : Colors.white),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildLogo(value),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: isDesktop ? 13 : 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 18)
            else
              Icon(Icons.circle_outlined,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(String type) {
    Color color;
    IconData? icon;
    String text = '';

    switch (type) {
      case 'card':
        color = Colors.blue[800]!;
        icon = Icons.credit_card;
        break;
      case 'paypal':
        color = Colors.blue[600]!;
        text = 'Pay';
        break;
      case 'gopay':
        color = const Color(0xFF007AFF);
        text = 'Gopay';
        break;
      case 'ovo':
        color = const Color(0xFF4C2A86);
        text = 'OVO';
        break;
      case 'dana':
        color = const Color(0xFF118EEA);
        text = 'DANA';
        break;
      case 'bank_bri':
        color = const Color(0xFF00529C);
        text = 'BRI';
        break;
      case 'bank_bca':
        color = const Color(0xFF0060AF);
        text = 'BCA';
        break;
      case 'bank_mandiri':
        color = const Color(0xFFFFB700);
        text = 'M';
        break;
      default:
        color = Colors.grey;
        icon = Icons.payment;
    }

    return Container(
      width: 42,
      height: 28,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ]),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: 16)
          : Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10)),
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
              LocalizationService.get(lang, 'orderSummary'),
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
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 0.4.h),
                                    // Resizer quantity
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.grey[700]!
                                              : Colors.grey[300]!,
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
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(width: 0.5.w),
                                          Text(
                                            '1',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 0.5.w),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Icon(
                                              Icons.add,
                                              size: 14,
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
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
              Divider(
                  height: 1,
                  color: isDark ? Colors.grey[700] : Colors.grey[300]),
              SizedBox(height: 1.5.h),
            ],

            // Pricing breakdown
            _buildPricingRow(
                LocalizationService.get(lang, 'subtotal'), subtotal, isDesktop),
            SizedBox(height: 1.h),
            _buildPricingRow(
                LocalizationService.get(lang, 'shipping'), shipping, isDesktop),
            SizedBox(height: 1.h),
            _buildPricingRow(
                LocalizationService.get(lang, 'tax'), tax, isDesktop),

            SizedBox(height: 1.2.h),
            Divider(
                height: 1,
                thickness: 1.5,
                color: isDark ? Colors.grey[700] : Colors.grey[300]),
            SizedBox(height: 1.2.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.get(lang, 'totalDue'),
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

  void _showSuccessDialog(
      BuildContext context, Map<String, dynamic> receiptData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const Icon(
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
            const Text(
              'Email:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              receiptData['email'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.5.h),
            const Text(
              'Nomor Transaksi:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              receiptData['id'].toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.5.h),
            const Text(
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
                context.go(AppRoutes.dashboard);
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
