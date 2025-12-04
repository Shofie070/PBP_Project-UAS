import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../model/model.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(const ProductDetailState());

  void init(Product product) {
    emit(state.copyWith(product: product, status: ProductDetailStatus.loading));
    _loadReviews(product);
    _loadFavoriteStatus(product);
  }

  Future<void> _loadFavoriteStatus(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('favorites_list') ?? [];
      bool isFav = false;

      for (final favStr in favList) {
        try {
          final favDecoded = jsonDecode(favStr);
          if (favDecoded is Map) {
            final favId = favDecoded['id'];
            final favName = favDecoded['name'] ?? favDecoded['title'];
            if ((favId != null && favId == product.id) ||
                (favName != null && favName == product.name)) {
              isFav = true;
              break;
            }
          }
        } catch (_) {}
      }
      emit(state.copyWith(
          isFavorite: isFav, status: ProductDetailStatus.success));
    } catch (e) {
      // ignore
    }
  }

  Future<String> _reviewKey(Product product) async {
    final id = product.id;
    final name = product.name;
    return 'reviews_${id ?? name}';
  }

  Future<void> _loadReviews(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _reviewKey(product);
      final list = prefs.getStringList(key) ?? [];
      final List<Map<String, dynamic>> reviews = [];

      if (list.isNotEmpty) {
        for (final s in list) {
          try {
            final decoded = jsonDecode(s);
            if (decoded is Map<String, dynamic>) reviews.add(decoded);
          } catch (_) {}
        }
      }
      // Note: Legacy code checked product['reviews'] from JSON, but Product model might not have it populated if not from detailed API.
      // We'll assume local reviews for now or empty.

      emit(state.copyWith(reviews: reviews));
    } catch (e) {
      // ignore
    }
  }

  Future<void> submitReview(String comment) async {
    if (state.product == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _reviewKey(state.product!);
      final list = prefs.getStringList(key) ?? [];
      final entry = {
        'rating': state.userRating,
        'comment': comment.trim(),
        'date': DateTime.now().toIso8601String(),
      };
      list.add(jsonEncode(entry));
      await prefs.setStringList(key, list);

      _loadReviews(state.product!);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to submit review'));
    }
  }

  Future<void> toggleFavorite() async {
    if (state.product == null) return;
    final product = state.product!;
    final isFav = state.isFavorite;

    emit(state.copyWith(isFavorite: !isFav)); // Optimistic

    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('favorites_list') ?? [];

      if (isFav) {
        // Remove
        for (var i = 0; i < list.length; i++) {
          try {
            final decoded = jsonDecode(list[i]);
            if (decoded is Map) {
              final id = decoded['id'];
              final name = decoded['name'] ?? decoded['title'];
              if ((id != null && id == product.id) ||
                  (name != null && name == product.name)) {
                list.removeAt(i);
                break;
              }
            }
          } catch (_) {}
        }
      } else {
        // Add
        final encoded = jsonEncode(product.toJson());
        if (!list.contains(encoded)) list.add(encoded);
      }
      await prefs.setStringList('favorites_list', list);
    } catch (e) {
      emit(state.copyWith(isFavorite: isFav)); // Revert
    }
  }

  Future<void> addToCart() async {
    if (state.product == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('cart_items') ?? [];
      final encoded = jsonEncode(state.product!.toJson());
      list.add(encoded); // Allow duplicates so quantity increases
      await prefs.setStringList('cart_items', list);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add to cart'));
    }
  }

  void updateCarouselIndex(int index) {
    emit(state.copyWith(carouselIndex: index));
  }

  void updateUserRating(double rating) {
    emit(state.copyWith(userRating: rating));
  }
}
