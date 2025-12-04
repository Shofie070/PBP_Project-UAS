import 'package:equatable/equatable.dart';
import '../../../../model/model.dart';

enum CartStatus { initial, loading, success, failure }

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final bool isSelected;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = false,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    bool? isSelected,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [product, quantity, isSelected];
}

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItem> items;
  final Set<String> favoriteIds;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.favoriteIds = const {},
    this.errorMessage,
  });

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    Set<String>? favoriteIds,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double get totalAmount {
    return items
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  List<Product> get selectedProducts {
    return items
        .where((item) => item.isSelected)
        .map((item) => item.product)
        .toList();
  }

  @override
  List<Object?> get props => [status, items, favoriteIds, errorMessage];
}
