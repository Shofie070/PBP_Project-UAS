import 'package:bloc/bloc.dart';

import '../page/cart_state.dart'; 

class CartBloc extends Cubit<CartState> {
  CartBloc() : super(CartState.initial());
        
  void removeItem(int index) {
    if (index >= 0 && index < state.cartItems.length) {
      final currentCart = List<Map<String, dynamic>>.from(state.cartItems);
      
      currentCart.removeAt(index);
      
      emit(state.copyWith(cartItems: currentCart, items: [], isLoading: false));
    }
  }

  void addItem(Map<String, dynamic> item) {
    final newCart = List<Map<String, dynamic>>.from(state.cartItems);
    newCart.add(item);
    emit(state.copyWith(cartItems: newCart, items: [], isLoading: false));
  }
}