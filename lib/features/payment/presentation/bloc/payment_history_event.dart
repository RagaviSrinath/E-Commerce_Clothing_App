import 'package:equatable/equatable.dart';
import 'package:nextgen/features/payment/domain/entities/order_entity.dart';

abstract class PaymentHistoryEvent extends Equatable {
  const PaymentHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentHistory extends PaymentHistoryEvent {
  const LoadPaymentHistory();
}

class RecordNewOrder extends PaymentHistoryEvent {
  final OrderEntity order;

  const RecordNewOrder(this.order);

  @override
  List<Object?> get props => [order];
}
