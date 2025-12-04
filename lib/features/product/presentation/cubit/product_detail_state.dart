import 'package:equatable/equatable.dart';
import '../../../../model/model.dart';

enum ProductDetailStatus { initial, loading, success, failure }

class ProductDetailState extends Equatable {
  final ProductDetailStatus status;
  final Product? product;
  final List<Map<String, dynamic>> reviews;
  final bool isFavorite;
  final int carouselIndex;
  final double userRating;
  final String? errorMessage;

  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.reviews = const [],
    this.isFavorite = false,
    this.carouselIndex = 0,
    this.userRating = 5.0,
    this.errorMessage,
  });

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    Product? product,
    List<Map<String, dynamic>>? reviews,
    bool? isFavorite,
    int? carouselIndex,
    double? userRating,
    String? errorMessage,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      reviews: reviews ?? this.reviews,
      isFavorite: isFavorite ?? this.isFavorite,
      carouselIndex: carouselIndex ?? this.carouselIndex,
      userRating: userRating ?? this.userRating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        product,
        reviews,
        isFavorite,
        carouselIndex,
        userRating,
        errorMessage,
      ];
}
