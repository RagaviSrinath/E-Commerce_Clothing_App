import 'package:nextgen/features/products/domain/entities/product_entity.dart';

import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_data_source.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource localDataSource;

  const WatchlistRepositoryImpl(this.localDataSource);

  @override
  Future<List<ProductEntity>> getWatchlist() {
    return localDataSource.getWatchlist();
  }

  @override
  Future<void> addToWatchlist(ProductEntity product) {
    return localDataSource.addToWatchlist(product);
  }

  @override
  Future<void> removeFromWatchlist(String productId) {
    return localDataSource.removeFromWatchlist(productId);
  }

  @override
  Future<bool> isFavorite(String productId) {
    return localDataSource.isFavorite(productId);
  }
}
