import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';
import 'package:nextgen/features/products/data/models/product_model.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.product,
    required super.quantity,
    required super.selectedSize,
    required super.selectedColor,
  });

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      product: entity.product,
      quantity: entity.quantity,
      selectedSize: entity.selectedSize,
      selectedColor: entity.selectedColor,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      selectedSize: json['selectedSize'] as String? ?? 'Standard',
      selectedColor: json['selectedColor'] as String? ?? 'Standard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product is ProductModel
          ? (product as ProductModel).toJson()
          : {
              'id': product.id,
              'name': product.name,
              'description': product.description,
              'price': product.price,
              'category': product.category,
              'imageUrl': product.imageUrl,
              'rating': product.rating,
              'reviewCount': product.reviewCount,
              'sizes': product.sizes,
              'colors': product.colors,
            },
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }
}
