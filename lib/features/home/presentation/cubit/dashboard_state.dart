import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../model/model.dart';

enum SortMode { none, priceAsc, priceDesc, ratingDesc }

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final List<String> categories;
  final Set<String> favoriteIds;
  final String username;
  final String email;
  final String searchQuery;
  final String selectedCategory;
  final bool showingAll;
  final SortMode sortMode;
  final int carouselIndex;
  final Color currentAccentColor;
  final bool usingLocalFallback;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.favoriteIds = const {},
    this.username = '',
    this.email = '',
    this.searchQuery = '',
    this.selectedCategory = 'Popular',
    this.showingAll = false,
    this.sortMode = SortMode.none,
    this.carouselIndex = 0,
    this.currentAccentColor = Colors.deepPurple,
    this.usingLocalFallback = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    List<String>? categories,
    Set<String>? favoriteIds,
    String? username,
    String? email,
    String? searchQuery,
    String? selectedCategory,
    bool? showingAll,
    SortMode? sortMode,
    int? carouselIndex,
    Color? currentAccentColor,
    bool? usingLocalFallback,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      username: username ?? this.username,
      email: email ?? this.email,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showingAll: showingAll ?? this.showingAll,
      sortMode: sortMode ?? this.sortMode,
      carouselIndex: carouselIndex ?? this.carouselIndex,
      currentAccentColor: currentAccentColor ?? this.currentAccentColor,
      usingLocalFallback: usingLocalFallback ?? this.usingLocalFallback,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allProducts,
        filteredProducts,
        categories,
        favoriteIds,
        username,
        email,
        searchQuery,
        selectedCategory,
        showingAll,
        sortMode,
        carouselIndex,
        currentAccentColor,
        usingLocalFallback,
        errorMessage,
      ];
}
