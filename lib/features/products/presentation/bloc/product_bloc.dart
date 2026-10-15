import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;

  ProductBloc({required this.getProductsUseCase})
    : super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<FilterCategory>(_onFilterCategory);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    await _fetchProducts(emit);
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    await _fetchProducts(emit);
  }

  Future<void> _fetchProducts(Emitter<ProductState> emit) async {
    try {
      final products = await getProductsUseCase();

      // Extract distinct categories
      final Set<String> categorySet = {'All'};
      for (final p in products) {
        if (p.category.isNotEmpty) {
          categorySet.add(p.category);
        }
      }

      final filtered = _applyFilter(
        products: products,
        category: state.selectedCategory,
        query: state.searchQuery,
      );

      emit(
        state.copyWith(
          status: ProductStatus.success,
          allProducts: products,
          filteredProducts: filtered,
          categories: categorySet.toList(),
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: 'An unexpected error occurred while loading products.',
        ),
      );
    }
  }

  void _onFilterCategory(FilterCategory event, Emitter<ProductState> emit) {
    final filtered = _applyFilter(
      products: state.allProducts,
      category: event.category,
      query: state.searchQuery,
    );
    emit(
      state.copyWith(
        selectedCategory: event.category,
        filteredProducts: filtered,
      ),
    );
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) {
    final filtered = _applyFilter(
      products: state.allProducts,
      category: state.selectedCategory,
      query: event.query,
    );
    emit(state.copyWith(searchQuery: event.query, filteredProducts: filtered));
  }

  List<ProductEntity> _applyFilter({
    required List<ProductEntity> products,
    required String category,
    required String query,
  }) {
    return products.where((product) {
      final matchesCategory =
          category == 'All' ||
          product.category.toLowerCase() == category.toLowerCase();

      final cleanQuery = query.trim().toLowerCase();
      final matchesQuery =
          cleanQuery.isEmpty ||
          product.name.toLowerCase().contains(cleanQuery) ||
          product.description.toLowerCase().contains(cleanQuery) ||
          product.category.toLowerCase().contains(cleanQuery);

      return matchesCategory && matchesQuery;
    }).toList();
  }
}
