import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';
import 'package:nextgen/features/payment/domain/entities/order_entity.dart';
import 'package:nextgen/features/payment/domain/repositories/payment_repository.dart';

import '../datasources/payment_local_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource localDataSource;

  const PaymentRepositoryImpl(this.localDataSource);

  @override
  Future<OrderEntity> processDummyPayment({
    required List<CartItemEntity> items,
    required double subtotal,
    required double shippingFee,
    required double estimatedTax,
    required double totalAmount,
    required String paymentMethod,
  }) {
    return localDataSource.processDummyPayment(
      items: items,
      subtotal: subtotal,
      shippingFee: shippingFee,
      estimatedTax: estimatedTax,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<List<OrderEntity>> getPaymentHistory() {
    return localDataSource.getPaymentHistory();
  }
}
