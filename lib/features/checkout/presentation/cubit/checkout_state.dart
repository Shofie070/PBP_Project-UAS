import 'package:equatable/equatable.dart';

abstract class CheckoutState extends Equatable {
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final int selectedShippingIndex;
  final String? paymentMethod;

  const CheckoutState({
    this.items = const [],
    this.subtotal = 0,
    this.selectedShippingIndex = 0,
    this.paymentMethod,
  });

  @override
  List<Object?> get props =>
      [items, subtotal, selectedShippingIndex, paymentMethod];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoaded extends CheckoutState {
  const CheckoutLoaded({
    super.items,
    super.subtotal,
    super.selectedShippingIndex,
    super.paymentMethod,
  });

  CheckoutLoaded copyWith({
    List<Map<String, dynamic>>? items,
    double? subtotal,
    int? selectedShippingIndex,
    String? paymentMethod,
  }) {
    return CheckoutLoaded(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      selectedShippingIndex:
          selectedShippingIndex ?? this.selectedShippingIndex,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
