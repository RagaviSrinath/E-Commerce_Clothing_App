import 'package:nextgen/features/products/domain/entities/product_entity.dart';

import '../repositories/watchlist_repository.dart';

class GetWatchlistUseCase {
  final WatchlistRepository repository;
  const GetWatchlistUseCase(this.repository);

  Future<List<ProductEntity>> call() {
    return repository.getWatchlist();
  }
}

class AddToWatchlistUseCase {
  final WatchlistRepository repository;
  const AddToWatchlistUseCase(this.repository);

  Future<void> call(ProductEntity product) {
    return repository.addToWatchlist(product);
  }
}

class RemoveFromWatchlistUseCase {
  final WatchlistRepository repository;
  const RemoveFromWatchlistUseCase(this.repository);

  Future<void> call(String productId) {
    return repository.removeFromWatchlist(productId);
  }
}
