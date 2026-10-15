import 'package:equatable/equatable.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final String selectedSize;
  final String selectedColor;

  const CartItemEntity({
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
  });

  String get itemKey => '${product.id}_${selectedSize}_$selectedColor';

  double get lineTotal => product.price * quantity;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  @override
  List<Object?> get props => [product, quantity, selectedSize, selectedColor];
}
