import 'package:equatable/equatable.dart';
import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';

class OrderEntity extends Equatable {
  final String orderId;
  final List<CartItemEntity> items;
  final double subtotal;
  final double shippingFee;
  final double estimatedTax;
  final double totalPaid;
  final DateTime paymentDate;
  final String paymentMethod;

  const OrderEntity({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.estimatedTax,
    required this.totalPaid,
    required this.paymentDate,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    orderId,
    items,
    subtotal,
    shippingFee,
    estimatedTax,
    totalPaid,
    paymentDate,
    paymentMethod,
  ];
}
