import 'package:equatable/equatable.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchlist extends WatchlistEvent {
  const LoadWatchlist();
}

class ToggleWatchlist extends WatchlistEvent {
  final ProductEntity product;
  const ToggleWatchlist(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveFromWatchlistEvent extends WatchlistEvent {
  final String productId;
  const RemoveFromWatchlistEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearWatchlistFeedback extends WatchlistEvent {
  const ClearWatchlistFeedback();
}
