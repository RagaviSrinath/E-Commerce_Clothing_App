import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ProductFailure extends Failure {
  const ProductFailure(super.message);
}

class CartFailure extends Failure {
  const CartFailure(super.message);
}

class WatchlistFailure extends Failure {
  const WatchlistFailure(super.message);
}

class PaymentFailure extends Failure {
  const PaymentFailure(super.message);
}
