import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/model.dart';
import '../service/app_router.dart';

class FavoritPage extends StatefulWidget {
  const FavoritPage({super.key});

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  final List<Product> _favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites_list') ?? [];
    _favoriteItems.clear();
    for (final s in list) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) {
          _favoriteItems.add(Product.fromJson(decoded));
        } else if (decoded is Map) {
          _favoriteItems.add(Product.fromJson(Map<String, dynamic>.from(decoded)));
        }
      } catch (_) {}
    }
    if (mounted) setState(() {});
  }

  Future<void> _removeFromFavorites(int index) async {
    final p = _favoriteItems[index];
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites_list') ?? [];
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
    await prefs.setStringList('favorites_list', list);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isWide = media.size.width > 900;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Favorit Saya', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${_favoriteItems.length} Items', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        centerTitle: true,
      ),
      body: _favoriteItems.isEmpty
          ? const Center(child: Text('Belum ada item favorit'))
          : LayoutBuilder(builder: (context, constraints) {
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _favoriteItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = _favoriteItems[index];
                  final name = product.name;
                  final price = product.price;
                  final image = product.image;

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.detailProduk, extra: product.toJson());
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                                  Text('Rp ${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.favorite, color: Colors.red),
                                  onPressed: () async {
                                    await _removeFromFavorites(index);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dihapus dari favorit')));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
    );
  }
}
