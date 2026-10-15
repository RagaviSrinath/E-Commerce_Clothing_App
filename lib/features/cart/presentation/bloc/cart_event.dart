import 'package:equatable/equatable.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {
  const LoadCart();
}

class AddToCart extends CartEvent {
  final ProductEntity product;
  final int quantity;
  final String? size;
  final String? color;

  const AddToCart({
    required this.product,
    this.quantity = 1,
    this.size,
    this.color,
  });

  @override
  List<Object?> get props => [product, quantity, size, color];
}

class UpdateCartQuantity extends CartEvent {
  final String itemKey;
  final int quantity;

  const UpdateCartQuantity({required this.itemKey, required this.quantity});

  @override
  List<Object?> get props => [itemKey, quantity];
}

class RemoveFromCart extends CartEvent {
  final String itemKey;
  const RemoveFromCart(this.itemKey);

  @override
  List<Object?> get props => [itemKey];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

class ClearCartFeedback extends CartEvent {
  const ClearCartFeedback();
}
