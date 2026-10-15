import 'package:nextgen/features/payment/domain/entities/order_entity.dart';
import 'package:nextgen/features/payment/domain/repositories/payment_repository.dart';

class GetPaymentHistoryUseCase {
  final PaymentRepository repository;

  const GetPaymentHistoryUseCase(this.repository);

  Future<List<OrderEntity>> call() => repository.getPaymentHistory();
}
