import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';

abstract class CartLocalDataSource {
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

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final Map<String, CartItemEntity> _items = {};

  @override
  Future<List<CartItemEntity>> getCart() async {
    return _items.values.toList();
  }

  @override
  Future<void> addToCart(
    ProductEntity product, {
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
  }) async {
    final size =
        selectedSize ?? (product.sizes.isNotEmpty ? product.sizes.first : 'M');
    final color =
        selectedColor ??
        (product.colors.isNotEmpty ? product.colors.first : 'Default');
    final key = '${product.id}_${size}_$color';

    if (_items.containsKey(key)) {
      final existing = _items[key]!;
      _items[key] = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      _items[key] = CartItemEntity(
        product: product,
        quantity: quantity,
        selectedSize: size,
        selectedColor: color,
      );
    }
  }

  @override
  Future<void> removeFromCart(String itemKey) async {
    _items.remove(itemKey);
  }

  @override
  Future<void> updateCartQuantity(String itemKey, int quantity) async {
    if (quantity <= 0) {
      _items.remove(itemKey);
    } else if (_items.containsKey(itemKey)) {
      _items[itemKey] = _items[itemKey]!.copyWith(quantity: quantity);
    }
  }

  @override
  Future<void> clearCart() async {
    _items.clear();
  }
}
