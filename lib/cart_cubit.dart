// Lokasi: lib/model/cart_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:flutter_application_1/cart_state.dart';
// import 'cart_state.dart'; // Jika dipisah

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.initial());

  // Menggantikan setState((){ _items.add(newItem); })
  void addItemToCart(Map<String, dynamic> newItem) {
    // Simulasi penambahan item
    final currentItems = List<Map<String, dynamic>>.from(state.items);
    currentItems.add(newItem);
    emit(state.copyWith(items: currentItems, isLoading: null));
  }

  // Menggantikan setState((){ _items.removeAt(index); })
  void removeItem(int index) {
    if (index >= 0 && index < state.items.length) {
      final currentItems = List<Map<String, dynamic>>.from(state.items);
      currentItems.removeAt(index);
      emit(state.copyWith(items: currentItems, isLoading: null));
    }
  }

  // Menggantikan setState((){ _isLoading = true; })
  Future<void> loadCartItems() async {
    emit(state.copyWith(isLoading: true, items: []));

    // Logika API call/Database call di sini...
    await Future.delayed(const Duration(seconds: 1));

    final loadedItems = [
      {'name': 'Kaos Putih', 'price': 50000, 'qty': 2},
      {'name': 'Hoodie Biru', 'price': 150000, 'qty': 1},
    ];

    emit(state.copyWith(items: loadedItems, isLoading: false));
  }
}
