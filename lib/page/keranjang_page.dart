import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/model.dart';
import '../service/app_router.dart';

class KeranjangPage extends StatefulWidget {
  final DashboardModel cartModel;
  const KeranjangPage({super.key, required this.cartModel});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final List<bool> _selectedProducts = [];
  final List<Product> _cartItems = [];
  final List<int> _quantities = [];
  final List<bool> _isFavorite = [];

  @override
  void initState() {
    super.initState();
    // Load persisted cart items from SharedPreferences so items added from
    // DetailProduk (which writes to 'cart_items') are visible here.
    _loadCartFromPrefs();
  }

  Future<void> _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('cart_items') ?? [];
    _cartItems.clear();
    for (final s in list) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) {
          _cartItems.add(Product.fromJson(decoded));
        } else if (decoded is Map) {
          _cartItems.add(Product.fromJson(Map<String, dynamic>.from(decoded)));
        }
      } catch (_) {
        // ignore malformed entries
      }
    }
    _selectedProducts.clear();
    _selectedProducts.addAll(List.generate(_cartItems.length, (_) => false));
    _quantities.clear();
    _quantities.addAll(List.generate(_cartItems.length, (_) => 1));
    _isFavorite.clear();
    // Load favorite status from favorites_list
    final favList = prefs.getStringList('favorites_list') ?? [];
    for (final product in _cartItems) {
      bool isFav = false;
      for (final favStr in favList) {
        try {
          final favDecoded = jsonDecode(favStr);
          if (favDecoded is Map) {
            final favId = favDecoded['id'];
            final favName = favDecoded['name'] ?? favDecoded['title'];
            if ((favId != null && favId == product.id) || (favName != null && favName == product.name)) {
              isFav = true;
              break;
            }
          }
        } catch (_) {}
      }
      _isFavorite.add(isFav);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your cart', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${_cartItems.length} Products in Your cart', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        Widget listColumn = _cartItems.isEmpty
            ? const Center(child: Text('Your cart is empty'))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = _cartItems[index];
                  final name = product.name;
                  final price = product.price;
                  final image = product.image;

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _selectedProducts[index],
                            onChanged: (v) => setState(() => _selectedProducts[index] = v ?? false),
                          ),
                          Container(
                            width: isWide ? 96 : 64,
                            height: isWide ? 96 : 64,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[100]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                child: image.toString().isNotEmpty
                  ? (image.toString().startsWith('http') ? Image.network(image.toString(), fit: BoxFit.cover) : Image.asset(image.toString(), fit: BoxFit.cover))
                  : const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('Category: ${product.category}', style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('Qty:'),
                                    const SizedBox(width: 8),
                                    DropdownButton<int>(
                                      value: _quantities.length > index ? _quantities[index] : 1,
                                      items: List.generate(10, (i) => i + 1).map((q) => DropdownMenuItem(value: q, child: Text(q.toString()))).toList(),
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() {
                                          if (_quantities.length > index) _quantities[index] = v;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Rp ${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(_isFavorite.length > index && _isFavorite[index] ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                                    onPressed: () async {
                                      if (_isFavorite.length > index) {
                                        _isFavorite[index] = !_isFavorite[index];
                                        await _toggleFavorite(product, _isFavorite[index]);
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.grey),
                                    onPressed: () async { await _removeFromCartByIndex(index); },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

        Widget summaryPanel() {
          double subtotal = 0.0;
          for (var i = 0; i < _cartItems.length; i++) {
            final p = _cartItems[i];
            final qty = _quantities.length > i ? _quantities[i] : 1;
            subtotal += p.price * qty;
          }

          final delivery = 25000.0; // sample fixed delivery
          final tax = subtotal * 0.02;
          final discount = 0.0;
          final total = subtotal + delivery + tax - discount;

          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Promocode', style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Promocode'))),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: () {}, child: const Text('Apply'))
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Items:'), Text('${_cartItems.length}')]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Delivery cost:'), Text('Rp ${delivery.toStringAsFixed(0)}')]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tax:'), Text('Rp ${tax.toStringAsFixed(0)}')]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Discount:'), Text('- Rp ${discount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green))]),
                  const Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)), Text('Rp ${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () {
                    final selectedProducts = _cartItems
                        .asMap()
                        .entries
                        .where((entry) => _selectedProducts[entry.key])
                        .map((entry) => entry.value)
                        .toList();
                    if (selectedProducts.isNotEmpty) {
                      _checkoutSelected(selectedProducts);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih produk terlebih dahulu!')));
                    }
                  }, child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Checkout'))),
                ],
              ),
            ),
          );
        }

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: listColumn),
              SizedBox(width: media.size.width * 0.32, child: summaryPanel()),
            ],
          );
        }

        // Mobile layout: list then fixed summary
        return Column(
          children: [
            Expanded(child: listColumn),
            summaryPanel(),
          ],
        );
      }),
    );
  }

  Future<void> _removeFromCartByIndex(int index) async {
    final p = _cartItems[index];
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('cart_items') ?? [];
    // Remove first matching entry by id or name
    for (var i = 0; i < list.length; i++) {
      try {
        final decoded = jsonDecode(list[i]);
        if (decoded is Map) {
          final id = decoded['id'];
          final name = decoded['name'] ?? decoded['title'];
          if ((id != null && id == p.id) || (name != null && name == p.name)) {
            list.removeAt(i);
            break;
          }
        }
      } catch (_) {}
    }
    await prefs.setStringList('cart_items', list);
    await _loadCartFromPrefs();
  }

  Future<void> _toggleFavorite(Product p, bool isFavorite) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites_list') ?? [];
    
    if (isFavorite) {
      // Add to favorites
      final encoded = jsonEncode(p.toJson());
      if (!list.contains(encoded)) list.add(encoded);
    } else {
      // Remove from favorites
      for (var i = 0; i < list.length; i++) {
        try {
          final decoded = jsonDecode(list[i]);
          if (decoded is Map) {
            final id = decoded['id'];
            final name = decoded['name'] ?? decoded['title'];
            if ((id != null && id == p.id) || (name != null && name == p.name)) {
              list.removeAt(i);
              break;
            }
          }
        } catch (_) {}
      }
    }
    await prefs.setStringList('favorites_list', list);
  }

  Future<void> _checkoutSelected(List<Product> selected) async {
    // Hitung total
    double total = 0;
    for (final p in selected) {
      total += p.price;
    }

    // Navigate to payment page dengan go_router
    if (mounted) {
      context.push(
        AppRoutes.payment,
        extra: {
          'products': selected,
          'totalAmount': total,
        },
      );
    }
  }
}
