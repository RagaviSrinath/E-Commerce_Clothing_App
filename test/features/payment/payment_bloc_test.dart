import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';
import 'package:nextgen/features/payment/data/datasources/payment_local_data_source.dart';
import 'package:nextgen/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:nextgen/features/payment/domain/usecases/process_dummy_payment_usecase.dart';
import 'package:nextgen/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:nextgen/features/payment/presentation/bloc/payment_event.dart';
import 'package:nextgen/features/payment/presentation/bloc/payment_state.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';

void main() {
  group('PaymentBloc Unit Tests', () {
    late PaymentLocalDataSource localDataSource;
    late PaymentRepositoryImpl repository;
    late ProcessDummyPaymentUseCase processPaymentUseCase;
    late PaymentBloc paymentBloc;

    const sampleProduct = ProductEntity(
      id: 'prod_001',
      name: 'Wool Blazer',
      description: 'Refined blazer',
      price: 240.0,
      category: 'Outerwear',
      imageUrl: 'https://images.example.com/blazer.jpg',
      rating: 4.9,
      reviewCount: 142,
      sizes: ['M'],
      colors: ['Charcoal'],
    );

    const sampleCartItem = CartItemEntity(
      product: sampleProduct,
      quantity: 1,
      selectedSize: 'M',
      selectedColor: 'Charcoal',
    );

    setUp(() {
      localDataSource = PaymentLocalDataSourceImpl();
      repository = PaymentRepositoryImpl(localDataSource);
      processPaymentUseCase = ProcessDummyPaymentUseCase(repository);
      paymentBloc = PaymentBloc(
        processDummyPaymentUseCase: processPaymentUseCase,
      );
    });

    tearDown(() {
      paymentBloc.close();
    });

    test('Initial state is PaymentInitial', () {
      expect(paymentBloc.state, const PaymentInitial());
    });

    blocTest<PaymentBloc, PaymentState>(
      'Fails when attempting to checkout with empty items',
      build: () => paymentBloc,
      act: (bloc) => bloc.add(
        const ProcessPaymentSubmitted(
          items: [],
          subtotal: 0.0,
          shippingFee: 0.0,
          estimatedTax: 0.0,
          totalAmount: 0.0,
          paymentMethod: 'Demo Card',
        ),
      ),
      expect: () => [
        const PaymentFailureState(
          'Cannot checkout with an empty shopping bag.',
        ),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'Emits [PaymentProcessing, PaymentSuccessState] on valid submission',
      build: () => paymentBloc,
      wait: const Duration(milliseconds: 1800),
      act: (bloc) => bloc.add(
        const ProcessPaymentSubmitted(
          items: [sampleCartItem],
          subtotal: 240.0,
          shippingFee: 0.0,
          estimatedTax: 12.0,
          totalAmount: 252.0,
          paymentMethod: 'Demo Card (•••• 4242)',
        ),
      ),
      expect: () => [
        const PaymentProcessing(),
        isA<PaymentSuccessState>()
            .having((s) => s.order.totalPaid, 'totalPaid', 252.0)
            .having(
              (s) => s.order.orderId,
              'orderId format',
              startsWith('NXG-2026-'),
            )
            .having((s) => s.order.items.length, 'items.length', 1),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'Resets state back to PaymentInitial when ResetPayment is added',
      build: () => paymentBloc,
      act: (bloc) => bloc.add(const ResetPayment()),
      expect: () => [const PaymentInitial()],
    );
  });
}
