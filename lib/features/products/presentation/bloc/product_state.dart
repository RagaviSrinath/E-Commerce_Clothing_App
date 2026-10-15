import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductEntity> allProducts;
  final List<ProductEntity> filteredProducts;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.categories = const ['All'],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.errorMessage,
  });

  bool get isLoading => status == ProductStatus.loading;
  bool get isSuccess => status == ProductStatus.success;
  bool get isFailure => status == ProductStatus.failure;
  bool get isEmpty => isSuccess && filteredProducts.isEmpty;

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? allProducts,
    List<ProductEntity>? filteredProducts,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allProducts,
    filteredProducts,
    categories,
    selectedCategory,
    searchQuery,
    errorMessage,
  ];
}
