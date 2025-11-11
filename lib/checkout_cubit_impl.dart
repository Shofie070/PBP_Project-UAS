import 'package:bloc/bloc.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutState.initial());

  final List<Map<String, dynamic>> _shippingOptions = [
    {
      'name': 'Reguler',
      'detail': 'Pengiriman reguler (2-3 hari)',
      'cost': 10000,
    },
    {
      'name': 'Express',
      'detail': 'Pengiriman cepat (1 hari)',
      'cost': 25000,
    },
    {
      'name': 'Pickup',
      'detail': 'Ambil di toko (gratis)',
      'cost': 0,
    },
  ];

  List<Map<String, dynamic>> get getShippingOptions => _shippingOptions;

  int get shippingCost =>
      (_shippingOptions[state.selectedShippingIndex]['cost'] as int?) ?? 0;

  int get grandTotal => state.subtotal + shippingCost;

  /// Load initial data from [args]. If [args] contains an `items` list or is a
  /// list itself, it will be used to populate the state's items.
  void loadInitialData(dynamic args) {
    List<Map<String, dynamic>> items = [];

    if (args is List) {
      try {
        items = List<Map<String, dynamic>>.from(args);
      } catch (_) {
        items = [];
      }
    } else if (args is Map && args['items'] is List) {
      try {
        items = List<Map<String, dynamic>>.from(args['items']);
      } catch (_) {
        items = [];
      }
    }

    if (items.isNotEmpty) emit(state.copyWith(items: items));
  }

  void selectShipping(int index) {
    final i = index.clamp(0, _shippingOptions.length - 1);
    emit(state.copyWith(selectedShippingIndex: i));
  }

  void selectPaymentMethod(String? method) {
    if (method == null) return;
    emit(state.copyWith(paymentMethod: method));
  }
}
