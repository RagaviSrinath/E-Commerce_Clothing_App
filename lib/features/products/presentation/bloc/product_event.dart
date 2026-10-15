import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class RefreshProducts extends ProductEvent {
  const RefreshProducts();
}

class FilterCategory extends ProductEvent {
  final String category;
  const FilterCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchProducts extends ProductEvent {
  final String query;
  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}
