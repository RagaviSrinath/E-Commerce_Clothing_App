import 'package:equatable/equatable.dart';
import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class ProcessPaymentSubmitted extends PaymentEvent {
  final List<CartItemEntity> items;
  final double subtotal;
  final double shippingFee;
  final double estimatedTax;
  final double totalAmount;
  final String paymentMethod;

  const ProcessPaymentSubmitted({
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.estimatedTax,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    items,
    subtotal,
    shippingFee,
    estimatedTax,
    totalAmount,
    paymentMethod,
  ];
}

class ResetPayment extends PaymentEvent {
  const ResetPayment();
}
