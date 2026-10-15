import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';

import '../entities/order_entity.dart';

abstract class PaymentRepository {
  Future<OrderEntity> processDummyPayment({
    required List<CartItemEntity> items,
    required double subtotal,
    required double shippingFee,
    required double estimatedTax,
    required double totalAmount,
    required String paymentMethod,
  });

  Future<List<OrderEntity>> getPaymentHistory();
}
