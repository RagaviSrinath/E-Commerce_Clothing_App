import 'package:nextgen/features/products/domain/entities/product_entity.dart';

abstract class WatchlistLocalDataSource {
  Future<List<ProductEntity>> getWatchlist();
  Future<void> addToWatchlist(ProductEntity product);
  Future<void> removeFromWatchlist(String productId);
  Future<bool> isFavorite(String productId);
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  final Map<String, ProductEntity> _items = {};

  @override
  Future<List<ProductEntity>> getWatchlist() async {
    return _items.values.toList();
  }

  @override
  Future<void> addToWatchlist(ProductEntity product) async {
    _items[product.id] = product;
  }

  @override
  Future<void> removeFromWatchlist(String productId) async {
    _items.remove(productId);
  }

  @override
  Future<bool> isFavorite(String productId) async {
    return _items.containsKey(productId);
  }
}
