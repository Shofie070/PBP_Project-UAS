import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../model/model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  Future<void> loadCart() async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Cart Items
      final cartList = prefs.getStringList('cart_items') ?? [];
      final List<CartItem> items = [];

      for (final s in cartList) {
        try {
          final decoded = jsonDecode(s);
          Product? product;
          if (decoded is Map<String, dynamic>) {
            product = Product.fromJson(decoded);
          } else if (decoded is Map) {
            product = Product.fromJson(Map<String, dynamic>.from(decoded));
          }

          if (product != null) {
            items.add(CartItem(product: product));
          }
        } catch (_) {}
      }

      // Load Favorites
      final favList = prefs.getStringList('favorites_list') ?? [];
      final Set<String> favoriteIds = {};
      for (final favStr in favList) {
        try {
          final favDecoded = jsonDecode(favStr);
          if (favDecoded is Map) {
            final id = favDecoded['id'];
            if (id != null) {
              favoriteIds.add(id.toString());
            }
          }
        } catch (_) {}
      }

      emit(state.copyWith(
        status: CartStatus.success,
        items: items,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: CartStatus.failure, errorMessage: e.toString()));
    }
  }

  void toggleSelection(int index, bool? value) {
    if (index < 0 || index >= state.items.length) return;
    final newItems = List<CartItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(isSelected: value ?? false);
    emit(state.copyWith(items: newItems));
  }

  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= state.items.length) return;
    final newItems = List<CartItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(quantity: quantity);
    emit(state.copyWith(items: newItems));
  }

  Future<void> removeFromCart(int index) async {
    if (index < 0 || index >= state.items.length) return;

    final itemToRemove = state.items[index];
    final newItems = List<CartItem>.from(state.items)..removeAt(index);

    emit(state.copyWith(items: newItems)); // Optimistic update

    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('cart_items') ?? [];

      // Remove first matching entry
      for (var i = 0; i < list.length; i++) {
        try {
          final decoded = jsonDecode(list[i]);
          if (decoded is Map) {
            final id = decoded['id'];
            final name = decoded['name'] ?? decoded['title'];
            if ((id != null && id == itemToRemove.product.id) ||
                (name != null && name == itemToRemove.product.name)) {
              list.removeAt(i);
              break;
            }
          }
        } catch (_) {}
      }
      await prefs.setStringList('cart_items', list);
    } catch (e) {
      // Revert if failed (optional, but good practice)
      // For now, just re-load to sync
      loadCart();
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final isFav = state.favoriteIds.contains(product.id);
    final newFavIds = Set<String>.from(state.favoriteIds);

    if (isFav) {
      newFavIds.remove(product.id);
    } else {
      if (product.id != null) newFavIds.add(product.id!);
    }

    emit(state.copyWith(favoriteIds: newFavIds)); // Optimistic update

    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('favorites_list') ?? [];

      if (!isFav) {
        // Add
        final encoded = jsonEncode(product.toJson());
        if (!list.contains(encoded)) list.add(encoded);
      } else {
        // Remove
        for (var i = 0; i < list.length; i++) {
          try {
            final decoded = jsonDecode(list[i]);
            if (decoded is Map) {
              final id = decoded['id'];
              final name = decoded['name'] ?? decoded['title'];
              if ((id != null && id == product.id) ||
                  (name != null && name == product.name)) {
                list.removeAt(i);
                break;
              }
            }
          } catch (_) {}
        }
      }
      await prefs.setStringList('favorites_list', list);
    } catch (e) {
      loadCart();
    }
  }
}
