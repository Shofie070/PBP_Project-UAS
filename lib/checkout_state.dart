
class CheckoutState {
  final String paymentMethod;
  final List<Map<String, dynamic>> items;
  final int selectedShippingIndex;

  const CheckoutState({
    required this.paymentMethod,
    required this.items,
    required this.selectedShippingIndex,
  });

  factory CheckoutState.initial() => const CheckoutState(
        paymentMethod: 'Transfer Bank',
        items: [],
        selectedShippingIndex: 0,
      );

  CheckoutState copyWith({
    String? paymentMethod,
    List<Map<String, dynamic>>? items,
    int? selectedShippingIndex,
  }) {
    return CheckoutState(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      selectedShippingIndex:
          selectedShippingIndex ?? this.selectedShippingIndex,
    );
  }

  int get subtotal {
    int sum = 0;
    for (var p in items) {
      final price = (p['price'] is int)
          ? p['price'] as int
          : int.tryParse('${p['price']}') ?? 0;
      sum += price;
    }
    return sum;
  }
}
