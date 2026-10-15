import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextgen/core/errors/failures.dart';

import '../../domain/usecases/process_dummy_payment_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final ProcessDummyPaymentUseCase processDummyPaymentUseCase;

  PaymentBloc({required this.processDummyPaymentUseCase})
    : super(const PaymentInitial()) {
    on<ProcessPaymentSubmitted>(_onProcessPaymentSubmitted);
    on<ResetPayment>(_onResetPayment);
  }

  Future<void> _onProcessPaymentSubmitted(
    ProcessPaymentSubmitted event,
    Emitter<PaymentState> emit,
  ) async {
    // Guard against accidental double submission
    if (state is PaymentProcessing) return;

    if (event.items.isEmpty) {
      emit(
        const PaymentFailureState(
          'Cannot checkout with an empty shopping bag.',
        ),
      );
      return;
    }

    emit(const PaymentProcessing());

    try {
      final order = await processDummyPaymentUseCase(
        items: event.items,
        subtotal: event.subtotal,
        shippingFee: event.shippingFee,
        estimatedTax: event.estimatedTax,
        totalAmount: event.totalAmount,
        paymentMethod: event.paymentMethod,
      );

      emit(PaymentSuccessState(order));
    } on Failure catch (failure) {
      emit(PaymentFailureState(failure.message));
    } catch (e) {
      emit(
        const PaymentFailureState(
          'Payment processing failed. Please try again.',
        ),
      );
    }
  }

  void _onResetPayment(ResetPayment event, Emitter<PaymentState> emit) {
    emit(const PaymentInitial());
  }
}
