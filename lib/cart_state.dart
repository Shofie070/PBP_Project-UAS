// File: lib/model/cart_state.dart

import 'package:meta/meta.dart';

@immutable
class CartState {
  // Primary storage for the cart items. Some older code refers to `cartItems`,
  // newer code expects `items`. We expose both to remain compatible.
  final List<Map<String, dynamic>> cartItems;
  final bool isLoading;

  const CartState({required this.cartItems, this.isLoading = false});

  // Backwards/forwards compatibility getter
  List<Map<String, dynamic>> get items => cartItems;

  // State awal dengan beberapa item dummy
  factory CartState.initial() => const CartState(cartItems: [
        {"name": "Kaos A (Dummy)", "price": 125000, "image": "assets/images/placeholder.png"},
        {"name": "Hoodie B (Dummy)", "price": 250000, "image": "assets/images/placeholder.png"},
      ], isLoading: false);

  // Helper untuk membuat salinan State baru dengan perubahan. Accepts both
  // `cartItems` and `items` named arguments for compatibility.
  CartState copyWith({
    List<Map<String, dynamic>>? cartItems,
    List<Map<String, dynamic>>? items,
    bool? isLoading,
  }) {
    return CartState(
      cartItems: cartItems ?? items ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}