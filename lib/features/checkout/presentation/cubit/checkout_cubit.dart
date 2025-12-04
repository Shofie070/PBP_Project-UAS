import 'package:flutter_bloc/flutter_bloc.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

  final List<Map<String, dynamic>> _shippingOptions = [
    {'name': 'JNE', 'cost': 25000, 'detail': 'Estimasi 2-3 hari'},
    {'name': 'J&T', 'cost': 27000, 'detail': 'Estimasi 3-4 hari'},
    {'name': 'SiCepat', 'cost': 23000, 'detail': 'Estimasi 3-5 hari'},
  ];

  List<Map<String, dynamic>> get getShippingOptions => _shippingOptions;

  double get shippingCost =>
      _shippingOptions[state.selectedShippingIndex]['cost'].toDouble();

  double get grandTotal => state.subtotal + shippingCost;

  void loadInitialData(dynamic args) {
    List<Map<String, dynamic>> items = [];
    double subtotal = 0;

    if (args != null && args is Map<String, dynamic>) {
      if (args.containsKey('products')) {
        // From Cart (List<Product>)
        final products = args['products'] as List;
        items = products.map((p) {
          return {
            'name': p.name,
            'price': p.price,
            'image': p.image,
          };
        }).toList();
        subtotal = args['totalAmount'] ?? 0;
      } else {
        // Direct Buy (Single Product)
        items = [
          {
            'name': args['name'],
            'price': args['price'],
            'image': args['image'],
          }
        ];
        subtotal = (args['price'] is int)
            ? (args['price'] as int).toDouble()
            : (args['price'] as double);
      }
    }

    emit(CheckoutLoaded(items: items, subtotal: subtotal));
  }

  void selectShipping(int index) {
    if (state is CheckoutLoaded) {
      emit((state as CheckoutLoaded).copyWith(selectedShippingIndex: index));
    }
  }

  void selectPaymentMethod(String? method) {
    if (state is CheckoutLoaded) {
      emit((state as CheckoutLoaded).copyWith(paymentMethod: method));
    }
  }
}
