import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_payment_history_usecase.dart';
import 'payment_history_event.dart';
import 'payment_history_state.dart';

class PaymentHistoryBloc
    extends Bloc<PaymentHistoryEvent, PaymentHistoryState> {
  final GetPaymentHistoryUseCase getPaymentHistoryUseCase;

  PaymentHistoryBloc({required this.getPaymentHistoryUseCase})
    : super(const PaymentHistoryState()) {
    on<LoadPaymentHistory>(_onLoadPaymentHistory);
    on<RecordNewOrder>(_onRecordNewOrder);
  }

  Future<void> _onLoadPaymentHistory(
    LoadPaymentHistory event,
    Emitter<PaymentHistoryState> emit,
  ) async {
    emit(state.copyWith(status: PaymentHistoryStatus.loading));
    try {
      final orders = await getPaymentHistoryUseCase();
      emit(state.copyWith(status: PaymentHistoryStatus.loaded, orders: orders));
    } catch (e) {
      emit(
        state.copyWith(
          status: PaymentHistoryStatus.failure,
          errorMessage: 'Unable to load payment history.',
        ),
      );
    }
  }

  void _onRecordNewOrder(
    RecordNewOrder event,
    Emitter<PaymentHistoryState> emit,
  ) {
    // Insert new order at top of history
    final updated = [
      event.order,
      ...state.orders.where((o) => o.orderId != event.order.orderId),
    ];
    emit(state.copyWith(status: PaymentHistoryStatus.loaded, orders: updated));
  }
}
