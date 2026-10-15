import 'package:nextgen/features/products/domain/entities/product_entity.dart';

abstract class WatchlistRepository {
  Future<List<ProductEntity>> getWatchlist();
  Future<void> addToWatchlist(ProductEntity product);
  Future<void> removeFromWatchlist(String productId);
  Future<bool> isFavorite(String productId);
}
