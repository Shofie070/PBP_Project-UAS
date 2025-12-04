import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../model/model.dart';
import '../../../../service/api_service.dart';

import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final ApiService _apiService;
  final List<Color> _carouselAccentColors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  DashboardCubit(this._apiService) : super(const DashboardState());

  Future<void> loadDashboardData(UserModel user) async {
    emit(state.copyWith(
      status: DashboardStatus.loading,
      username: user.username,
      email: user.email,
    ));

    try {
      // Load Prefs (User Data & Favorites)
      await _loadPrefs();

      // Load Products
      final products = await _apiService
          .getDashboardProducts()
          .timeout(const Duration(seconds: 15), onTimeout: () => []);

      bool fallback = false;
      if (products.isNotEmpty && products.first.image.startsWith('assets/')) {
        fallback = true;
      }

      final categories = ["All", "Popular", "Pakaian", "Aksesoris", "Sepatu"];
      if (!categories.contains("Aksesoris") &&
          products.any((p) => p.category == "Aksesoris")) {
        categories.add("Aksesoris");
      }

      // Filter out laptops
      final visibleProducts =
          products.where((p) => !_isLaptopProduct(p)).toList();

      // Initial Filter (Popular)
      final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'};
      final popular = visibleProducts
          .where((p) => allowedShow.contains(p.category))
          .toList();
      popular.sort((a, b) => b.rating.compareTo(a.rating));
      final initialFiltered =
          _applySort(popular.take(6).toList(), state.sortMode);

      emit(state.copyWith(
        status: DashboardStatus.success,
        allProducts: visibleProducts,
        filteredProducts: initialFiltered,
        categories: categories,
        usingLocalFallback: fallback,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString(),
        usingLocalFallback: true,
        allProducts: [],
        filteredProducts: [],
      ));
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites_list') ?? [];
    final savedName = prefs.getString('user_name');
    final savedEmail = prefs.getString('user_email');

    final Set<String> favIds = {};
    for (final jsonStr in favs) {
      try {
        final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
        final product = Product.fromJson(jsonMap);
        if (product.id != null) {
          favIds.add(product.id!);
        }
      } catch (_) {}
    }

    emit(state.copyWith(
      username: (savedName != null && savedName.isNotEmpty)
          ? savedName
          : state.username,
      email: (savedEmail != null && savedEmail.isNotEmpty)
          ? savedEmail
          : state.email,
      favoriteIds: favIds,
    ));
  }

  Future<void> refreshUserData() async {
    await _loadPrefs();
  }

  void updateCarouselIndex(int index) {
    emit(state.copyWith(
      carouselIndex: index,
      currentAccentColor:
          _carouselAccentColors[index % _carouselAccentColors.length],
    ));
  }

  void filterProducts(String query) {
    final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'};
    List<Product> baseList;

    if (state.selectedCategory == 'Popular' ||
        (!state.showingAll && state.selectedCategory == 'All')) {
      final pop = state.allProducts
          .where((p) => allowedShow.contains(p.category))
          .toList();
      pop.sort((a, b) => b.rating.compareTo(a.rating));
      baseList = pop;
    } else if (state.selectedCategory != 'All') {
      baseList = state.allProducts
          .where((p) => p.category == state.selectedCategory)
          .toList();
    } else {
      baseList = state.allProducts
          .where((p) => allowedShow.contains(p.category))
          .toList();
    }

    List<Product> filtered;
    if (query.isEmpty) {
      filtered = List.from(baseList);
    } else {
      filtered = baseList.where((p) {
        return p.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    emit(state.copyWith(
      searchQuery: query,
      filteredProducts: _applySort(filtered, state.sortMode),
    ));
  }

  void selectCategory(String category) {
    List<Product> filtered;
    bool showingAll = state.showingAll;

    if (category == 'Popular') {
      showingAll = false;
      final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'};
      final pop = state.allProducts
          .where((p) => allowedShow.contains(p.category))
          .toList();
      pop.sort((a, b) => b.rating.compareTo(a.rating));
      filtered = pop.take(6).toList();
    } else if (category == 'All') {
      showingAll = true;
      final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'};
      filtered = state.allProducts
          .where((p) => allowedShow.contains(p.category))
          .toList();
    } else {
      showingAll = true;
      filtered =
          state.allProducts.where((p) => p.category == category).toList();
    }

    emit(state.copyWith(
      selectedCategory: category,
      showingAll: showingAll,
      filteredProducts: _applySort(filtered, state.sortMode),
    ));
  }

  void changeSortMode(SortMode mode) {
    // If sorting, we generally want to show all results unless we are in "Popular" restricted view
    // But logic in original code:
    // if (mode != none) _showingAll = true; (inside PopupMenuButton)

    bool showingAll = state.showingAll;
    List<Product> baseList = List.from(state.filteredProducts);

    // If we are in "Popular" (limited to 6) and user sorts, usually we want to sort the FULL list of popular items?
    // The original code:
    // _showingAll = true;
    // _filteredProducts = _applySort(_allProducts.where(...).toList());

    // Let's replicate the logic:
    // If sort is selected, we might want to expand to full list if we were limited?
    // Actually, the original code re-filters from _allProducts when sorting is selected in the "View All" logic,
    // but for the PopupMenuButton it just sorts _filteredProducts if filter is active.

    // Let's keep it simple: just sort the current filteredProducts.
    // Wait, original code line 772: _showingAll = true; and re-filters from _allProducts.

    if (mode != SortMode.none && state.selectedCategory == 'Popular') {
      // If popular was selected (limited), and we sort, we probably want to see more items?
      // Original code did: _showingAll = true;
      // And re-fetched popular items (full list).
      showingAll = true;
      final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'};
      baseList = state.allProducts
          .where((p) => allowedShow.contains(p.category))
          .toList();
    }

    emit(state.copyWith(
      sortMode: mode,
      showingAll: showingAll,
      filteredProducts: _applySort(baseList, mode),
    ));
  }

  void showAllProducts() {
    final allowedShow = {'Pakaian', 'Aksesoris', 'Sepatu'};
    final filtered = state.allProducts
        .where((p) => allowedShow.contains(p.category))
        .toList();

    emit(state.copyWith(
      showingAll: true,
      selectedCategory: 'All',
      filteredProducts: _applySort(filtered, state.sortMode),
    ));
  }

  Future<void> toggleFavorite(Product p) async {
    final prefs = await SharedPreferences.getInstance();
    final favsList = prefs.getStringList('favorites_list') ?? [];

    bool isFavorited = false;
    int favoriteIndex = -1;

    for (int i = 0; i < favsList.length; i++) {
      try {
        final jsonMap = jsonDecode(favsList[i]) as Map<String, dynamic>;
        final product = Product.fromJson(jsonMap);
        if (product.id == p.id) {
          isFavorited = true;
          favoriteIndex = i;
          break;
        }
      } catch (_) {}
    }

    final newFavIds = Set<String>.from(state.favoriteIds);

    if (isFavorited && favoriteIndex >= 0) {
      favsList.removeAt(favoriteIndex);
      if (p.id != null) newFavIds.remove(p.id!);
    } else {
      final encoded = jsonEncode(p.toJson());
      favsList.add(encoded);
      if (p.id != null) newFavIds.add(p.id!);
    }

    await prefs.setStringList('favorites_list', favsList);
    emit(state.copyWith(favoriteIds: newFavIds));
  }

  Future<void> addToCart(Product p) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('cart_items') ?? [];
    final encoded = jsonEncode(p.toJson());
    if (!list.contains(encoded)) list.add(encoded);
    await prefs.setStringList('cart_items', list);
    // No state change needed for cart in Dashboard, but we might want to emit a side effect or just let UI handle snackbar
  }

  List<Product> _applySort(List<Product> products, SortMode mode) {
    final sorted = List<Product>.from(products);
    switch (mode) {
      case SortMode.priceAsc:
        sorted.sort((a, b) => (a.price).compareTo(b.price));
        break;
      case SortMode.priceDesc:
        sorted.sort((a, b) => (b.price).compareTo(a.price));
        break;
      case SortMode.ratingDesc:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortMode.none:
        break;
    }
    return sorted;
  }

  bool _isLaptopProduct(Product p) {
    final n = p.name.toLowerCase();
    final keywords = [
      'laptop',
      'macbook',
      'notebook',
      'dell',
      'asus',
      'lenovo',
      'hp',
      'xps',
      'zenbook',
      'surface',
      'thinkpad',
      'ideapad',
      'acer',
      'predator',
      'alienware',
      'mac pro',
      'macbook pro',
      'chromebook'
    ];
    for (final k in keywords) {
      if (n.contains(k)) return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('current_user_email');
    // Additional cleanup if needed
  }
}
