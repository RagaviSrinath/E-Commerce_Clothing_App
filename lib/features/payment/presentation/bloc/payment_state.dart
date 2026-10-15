import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

class PaymentSuccessState extends PaymentState {
  final OrderEntity order;

  const PaymentSuccessState(this.order);

  @override
  List<Object?> get props => [order];
}

class PaymentFailureState extends PaymentState {
  final String errorMessage;

  const PaymentFailureState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
