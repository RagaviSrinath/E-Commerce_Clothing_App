import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';

import '../entities/order_entity.dart';
import '../repositories/payment_repository.dart';

class ProcessDummyPaymentUseCase {
  final PaymentRepository repository;

  const ProcessDummyPaymentUseCase(this.repository);

  Future<OrderEntity> call({
    required List<CartItemEntity> items,
    required double subtotal,
    required double shippingFee,
    required double estimatedTax,
    required double totalAmount,
    required String paymentMethod,
  }) {
    return repository.processDummyPayment(
      items: items,
      subtotal: subtotal,
      shippingFee: shippingFee,
      estimatedTax: estimatedTax,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
    );
  }
}
