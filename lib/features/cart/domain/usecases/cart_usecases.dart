import 'package:nextgen/features/products/domain/entities/product_entity.dart';

import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;
  const GetCartUseCase(this.repository);

  Future<List<CartItemEntity>> call() {
    return repository.getCart();
  }
}

class AddToCartUseCase {
  final CartRepository repository;
  const AddToCartUseCase(this.repository);

  Future<void> call(
    ProductEntity product, {
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
  }) {
    return repository.addToCart(
      product,
      quantity: quantity,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
    );
  }
}

class RemoveFromCartUseCase {
  final CartRepository repository;
  const RemoveFromCartUseCase(this.repository);

  Future<void> call(String itemKey) {
    return repository.removeFromCart(itemKey);
  }
}

class UpdateCartQuantityUseCase {
  final CartRepository repository;
  const UpdateCartQuantityUseCase(this.repository);

  Future<void> call(String itemKey, int quantity) {
    return repository.updateCartQuantity(itemKey, quantity);
  }
}

class ClearCartUseCase {
  final CartRepository repository;
  const ClearCartUseCase(this.repository);

  Future<void> call() {
    return repository.clearCart();
  }
}
