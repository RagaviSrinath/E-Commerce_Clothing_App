import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';
import 'package:nextgen/features/payment/data/datasources/payment_local_data_source.dart';
import 'package:nextgen/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:nextgen/features/payment/domain/entities/order_entity.dart';
import 'package:nextgen/features/payment/domain/usecases/get_payment_history_usecase.dart';
import 'package:nextgen/features/payment/presentation/bloc/payment_history_bloc.dart';
import 'package:nextgen/features/payment/presentation/bloc/payment_history_event.dart';
import 'package:nextgen/features/payment/presentation/bloc/payment_history_state.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';

void main() {
  group('PaymentHistoryBloc Unit Tests', () {
    late PaymentLocalDataSource localDataSource;
    late PaymentRepositoryImpl repository;
    late GetPaymentHistoryUseCase getPaymentHistoryUseCase;
    late PaymentHistoryBloc paymentHistoryBloc;

    const sampleProduct = ProductEntity(
      id: 'prod_999',
      name: 'Cashmere Knit Sweater',
      description: 'Luxury knit sweater',
      price: 180.0,
      category: 'Knitwear',
      imageUrl: 'https://images.example.com/sweater.jpg',
      rating: 4.9,
      reviewCount: 88,
      sizes: ['M'],
      colors: ['Cream'],
    );

    final testOrder = OrderEntity(
      orderId: 'NXG-2026-99999',
      items: const [
        CartItemEntity(
          product: sampleProduct,
          quantity: 2,
          selectedSize: 'M',
          selectedColor: 'Cream',
        ),
      ],
      subtotal: 360.0,
      shippingFee: 0.0,
      estimatedTax: 18.0,
      totalPaid: 378.0,
      paymentDate: DateTime(2026, 10, 15, 10, 0),
      paymentMethod: 'Demo Card (•••• 4242)',
    );

    setUp(() {
      localDataSource = PaymentLocalDataSourceImpl();
      repository = PaymentRepositoryImpl(localDataSource);
      getPaymentHistoryUseCase = GetPaymentHistoryUseCase(repository);
      paymentHistoryBloc = PaymentHistoryBloc(
        getPaymentHistoryUseCase: getPaymentHistoryUseCase,
      );
    });

    tearDown(() {
      paymentHistoryBloc.close();
    });

    test('Initial state is PaymentHistoryState with initial status', () {
      expect(paymentHistoryBloc.state, const PaymentHistoryState());
      expect(paymentHistoryBloc.state.status, PaymentHistoryStatus.initial);
      expect(paymentHistoryBloc.state.isEmpty, true);
    });

    blocTest<PaymentHistoryBloc, PaymentHistoryState>(
      'Emits [loading, loaded] with empty list when LoadPaymentHistory is dispatched with no prior orders',
      build: () => paymentHistoryBloc,
      wait: const Duration(milliseconds: 350),
      act: (bloc) => bloc.add(const LoadPaymentHistory()),
      expect: () => [
        const PaymentHistoryState(status: PaymentHistoryStatus.loading),
        isA<PaymentHistoryState>()
            .having((s) => s.status, 'status', PaymentHistoryStatus.loaded)
            .having((s) => s.orders.isEmpty, 'initially empty', true),
      ],
    );

    blocTest<PaymentHistoryBloc, PaymentHistoryState>(
      'Emits updated state with new order prepended when RecordNewOrder is dispatched',
      build: () => paymentHistoryBloc,
      act: (bloc) => bloc.add(RecordNewOrder(testOrder)),
      expect: () => [
        PaymentHistoryState(
          status: PaymentHistoryStatus.loaded,
          orders: [testOrder],
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.orderCount, 1);
        expect(bloc.state.totalSpent, 378.0);
        expect(bloc.state.orders.first.orderId, 'NXG-2026-99999');
      },
    );
  });
}
