import 'package:flutter/material.dart';
import '../model/model.dart';

class KeranjangPage extends StatefulWidget {
  final DashboardModel cartModel;
  const KeranjangPage({super.key, required this.cartModel});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final List<bool> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _selectedProducts
        .addAll(List.generate(widget.cartModel.products.length, (_) => false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CART')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartModel.products.length,
              itemBuilder: (context, index) {
                final product = widget.cartModel.products[index];
                return ListTile(
                  leading: Checkbox(
                    value: _selectedProducts[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedProducts[index] = value ?? false;
                      });
                    },
                  ),
                  title: Text(product.name),
                  subtitle: Text('Rp ${product.price.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                final selectedProducts = widget.cartModel.products
                    .asMap()
                    .entries
                    .where((entry) => _selectedProducts[entry.key])
                    .map((entry) => entry.value)
                    .toList();

                if (selectedProducts.isNotEmpty) {
                  // Navigate to checkout page with selected products
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CheckoutPage(products: selectedProducts),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Pilih produk terlebih dahulu!')),
                  );
                }
              },
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutPage extends StatelessWidget {
  final List<Product> products;
  const CheckoutPage({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('Rp ${product.price.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: KeranjangPage(cartModel: DashboardModel()),
  ));
}
