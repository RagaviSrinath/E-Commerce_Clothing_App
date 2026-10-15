import 'package:nextgen/features/products/domain/entities/product_entity.dart';

import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCart();
  Future<void> addToCart(
    ProductEntity product, {
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
  });
  Future<void> removeFromCart(String itemKey);
  Future<void> updateCartQuantity(String itemKey, int quantity);
  Future<void> clearCart();
}
