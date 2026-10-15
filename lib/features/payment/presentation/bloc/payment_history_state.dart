import 'package:equatable/equatable.dart';
import 'package:nextgen/features/payment/domain/entities/order_entity.dart';

enum PaymentHistoryStatus { initial, loading, loaded, failure }

class PaymentHistoryState extends Equatable {
  final PaymentHistoryStatus status;
  final List<OrderEntity> orders;
  final String? errorMessage;

  const PaymentHistoryState({
    this.status = PaymentHistoryStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });

  bool get isEmpty => orders.isEmpty;
  int get orderCount => orders.length;
  double get totalSpent => orders.fold(0.0, (sum, o) => sum + o.totalPaid);

  PaymentHistoryState copyWith({
    PaymentHistoryStatus? status,
    List<OrderEntity>? orders,
    String? errorMessage,
  }) {
    return PaymentHistoryState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage];
}
