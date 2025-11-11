import 'package:bloc/bloc.dart';

import 'cart_state.dart';

class CartBloc extends Cubit<CartState> {
  // Inisiasi Cubit dengan state awal
  CartBloc() : super(CartState.initial());

  /// Menghilangkan item dari keranjang berdasarkan indeks.
  /// Ini menggantikan fungsi onRemove(index) di widget.
  void removeItem(int index) {
    if (index >= 0 && index < state.cartItems.length) {
      // 1. Dapatkan list item saat ini
      final currentCart = List<Map<String, dynamic>>.from(state.cartItems);

      // 2. Lakukan perubahan (Hapus item)
      currentCart.removeAt(index);

      // 3. Emit state baru untuk merefresh UI
      emit(state.copyWith(cartItems: currentCart));
    }
  }

  /// Menambah item ke keranjang.
  void addItem(Map<String, dynamic> item) {
    final newCart = List<Map<String, dynamic>>.from(state.cartItems);
    newCart.add(item);
    emit(state.copyWith(cartItems: newCart));
  }
}
