import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Import the Cubit implementation and its State
import 'checkout_cubit_impl.dart';
import '../page/checkout_state.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final NumberFormat _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadUserNameAndEmail();
  }

  Future<void> _loadUserNameAndEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final emailCurrent = prefs.getString('current_user_email');
    final emailRegistered = prefs.getString('user_email');
    final name = prefs.getString('user_name');

    // Mengisi controller dari SharedPreferences
    if (emailCurrent != null && emailCurrent.isNotEmpty) {
      _emailController.text = emailCurrent;
    } else if (emailRegistered != null && emailRegistered.isNotEmpty) {
      _emailController.text = emailRegistered;
    }
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
    }

    // Panggil loadInitialData di Cubit setelah argumen tersedia
    // Menggunakan Future.microtask untuk memastikan `context` dan `ModalRoute` tersedia
    // di saat initState (walaupun _loadUserNameAndEmail adalah async)
    Future.microtask(() {
      final args = ModalRoute.of(context)?.settings.arguments;
      context.read<CheckoutCubit>().loadInitialData(args);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Logika pemuatan arguments telah dipindahkan ke Cubit.
  }

  // Fungsi _submit sekarang menerima Cubit dan State untuk data yang dibutuhkan
  void _submit(BuildContext context, CheckoutCubit cubit, CheckoutState state) {
    if (state.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada produk untuk checkout')));
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Confirmation dialog showing products, subtotal, shipping, grand total
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Penerima: ${_nameController.text}'),
              Text('Email: ${_emailController.text}'),
              const SizedBox(height: 8),
              const Text('Produk:'),
              const SizedBox(height: 6),
              ...state.items.map((p) {
                final price = (p['price'] is int)
                    ? p['price'] as int
                    : int.tryParse('${p['price']}') ?? 0;
                return Text('- ${p['name']} (${_currency.format(price)})');
              }),
              const SizedBox(height: 8),
              Text('Subtotal: ${_currency.format(state.subtotal)}'),
              Text(
                  'Ongkos kirim (${cubit.getShippingOptions[state.selectedShippingIndex]['name']}): ${_currency.format(cubit.shippingCost)}'),
              const SizedBox(height: 6),
              Text('Total: ${_currency.format(cubit.grandTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Pembayaran sukses (simulasi)')));
              Navigator.pop(context); // back from checkout
            },
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    // Tidak perlu dispose Cubit di sini, karena BlocProvider yang mengelolanya
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap widget dengan BlocProvider untuk menyediakan Cubit
    return BlocProvider(
      create: (context) => CheckoutCubit(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Tidak berubah)
          Image.asset('assets/images/background.png', fit: BoxFit.cover),

          // BlocBuilder akan merebuild Scaffold ketika state Cubit berubah
          BlocBuilder<CheckoutCubit, CheckoutState>(
            builder: (context, state) {
              final cubit = context.read<CheckoutCubit>();

              return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text('Checkout'),
                  backgroundColor: Colors.pinkAccent,
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Detail Penerima Card (Statik) ---
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Detail Penerima',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                        labelText: 'Nama Penerima',
                                        border: OutlineInputBorder()),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Masukkan nama penerima'
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _emailController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        labelText: 'Email (tidak dapat diubah)',
                                        border: OutlineInputBorder()),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Masukkan email'
                                            : null,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ]),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // --- Daftar Produk Card (Menggunakan state.items) ---
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Daftar Produk',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  if (state.items.isEmpty)
                                    const Text(
                                        'Tidak ada produk untuk checkout'),
                                  if (state.items.isNotEmpty)
                                    ...state.items.map((p) {
                                      final price = (p['price'] is int)
                                          ? p['price'] as int
                                          : int.tryParse('${p['price']}') ?? 0;
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: p['image'] != null
                                            ? Image.asset(p['image'],
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.contain)
                                            : const Icon(Icons.image, size: 40),
                                        title: Text(p['name'] ?? ''),
                                        subtitle: Text(_currency.format(price)),
                                      );
                                    }),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Subtotal: ${_currency.format(state.subtotal)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ]),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // --- Pengiriman Card (Menggunakan state.selectedShippingIndex) ---
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pengiriman',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  ...List.generate(
                                      cubit.getShippingOptions.length, (i) {
                                    final opt = cubit.getShippingOptions[i];
                                    return RadioListTile<int>(
                                      value: i,
                                      groupValue: state.selectedShippingIndex,
                                      title: Text(opt['name']),
                                      subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(opt['detail']),
                                            Text(
                                                'Biaya: ${_currency.format(opt['cost'])}'),
                                          ]),
                                      // Ganti setState dengan memanggil Cubit
                                      onChanged: (v) =>
                                          cubit.selectShipping(v ?? 0),
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Ongkos kirim: ${_currency.format(cubit.shippingCost)}'),
                                  Text(
                                      'Total: ${_currency.format(cubit.grandTotal)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ]),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // --- Metode Pembayaran Card (Menggunakan state.paymentMethod) ---
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Metode Pembayaran',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: state
                                        .paymentMethod, // Ambil nilai dari State
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Transfer Bank',
                                          child: Text('Transfer Bank')),
                                      DropdownMenuItem(
                                          value: 'OVO', child: Text('OVO')),
                                      DropdownMenuItem(
                                          value: 'Dana', child: Text('Dana')),
                                      DropdownMenuItem(
                                          value: 'COD', child: Text('COD')),
                                    ],
                                    // Ganti setState dengan memanggil Cubit
                                    onChanged: cubit.selectPaymentMethod,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.pinkAccent,
                                          foregroundColor: Colors.white),
                                      // Panggil _submit dengan data Cubit dan State terbaru
                                      onPressed: () =>
                                          _submit(context, cubit, state),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14.0),
                                        child: Text('Bayar',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
