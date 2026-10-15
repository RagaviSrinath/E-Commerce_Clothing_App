import 'package:equatable/equatable.dart';
import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';

enum CartStatus { initial, loading, loaded, failure }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItemEntity> items;
  final String? feedbackMessage;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.feedbackMessage,
    this.errorMessage,
  });

  bool get isLoading => status == CartStatus.loading;
  bool get isEmpty => items.isEmpty;

  int get totalQuantity {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return items.fold<double>(0.0, (sum, item) => sum + item.lineTotal);
  }

  // Free shipping on orders over $150, otherwise $15 flat rate ($0 when cart is empty)
  double get shippingFee {
    if (items.isEmpty || subtotal >= 150.0) {
      return 0.0;
    }
    return 15.0;
  }

  // 5% estimated tax
  double get estimatedTax {
    if (items.isEmpty) return 0.0;
    return subtotal * 0.05;
  }

  // Total payable amount
  double get totalPayable {
    if (items.isEmpty) return 0.0;
    return subtotal + shippingFee + estimatedTax;
  }

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    String? feedbackMessage,
    String? errorMessage,
    bool clearFeedback = false,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, feedbackMessage, errorMessage];
}
