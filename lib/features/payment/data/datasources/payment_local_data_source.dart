import 'dart:math';

import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';

import '../../domain/entities/order_entity.dart';

abstract class PaymentLocalDataSource {
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

class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  final Random _random = Random();
  final List<OrderEntity> _orders = [];

  @override
  Future<OrderEntity> processDummyPayment({
    required List<CartItemEntity> items,
    required double subtotal,
    required double shippingFee,
    required double estimatedTax,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    // Simulate real-world payment gateway latency
    await Future.delayed(const Duration(milliseconds: 1400));

    // Generate unique order ID: NXG-2026-XXXXX
    final randomSuffix = _random.nextInt(90000) + 10000;
    final orderId = 'NXG-2026-$randomSuffix';

    final order = OrderEntity(
      orderId: orderId,
      items: List.unmodifiable(items),
      subtotal: subtotal,
      shippingFee: shippingFee,
      estimatedTax: estimatedTax,
      totalPaid: totalAmount,
      paymentDate: DateTime.now(),
      paymentMethod: paymentMethod,
    );

    _orders.insert(0, order);
    return order;
  }

  @override
  Future<List<OrderEntity>> getPaymentHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_orders);
  }
}
