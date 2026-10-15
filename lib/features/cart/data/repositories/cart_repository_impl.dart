import 'package:nextgen/features/products/domain/entities/product_entity.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  const CartRepositoryImpl(this.localDataSource);

  @override
  Future<List<CartItemEntity>> getCart() {
    return localDataSource.getCart();
  }

  @override
  Future<void> addToCart(
    ProductEntity product, {
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
  }) {
    return localDataSource.addToCart(
      product,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
    );
  }

  @override
  Future<void> removeFromCart(String itemKey) {
    return localDataSource.removeFromCart(itemKey);
  }

  @override
  Future<void> updateCartQuantity(String itemKey, int quantity) {
    return localDataSource.updateCartQuantity(itemKey, quantity);
  }

  @override
  Future<void> clearCart() {
    return localDataSource.clearCart();
  }
}
