import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:nextgen/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:nextgen/features/cart/domain/entities/cart_item_entity.dart';
import 'package:nextgen/features/cart/domain/usecases/cart_usecases.dart';
import 'package:nextgen/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:nextgen/features/cart/presentation/bloc/cart_event.dart';
import 'package:nextgen/features/cart/presentation/bloc/cart_state.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';

void main() {
  group('CartBloc Unit Tests', () {
    late CartLocalDataSource localDataSource;
    late CartRepositoryImpl repository;
    late GetCartUseCase getCartUseCase;
    late AddToCartUseCase addToCartUseCase;
    late RemoveFromCartUseCase removeFromCartUseCase;
    late UpdateCartQuantityUseCase updateCartQuantityUseCase;
    late ClearCartUseCase clearCartUseCase;
    late CartBloc cartBloc;

    const testProduct1 = ProductEntity(
      id: 'prod_001',
      name: 'Wool Blazer',
      description: 'Elegant tailored blazer',
      price: 100.0,
      category: 'Outerwear',
      imageUrl: 'https://images.example.com/blazer.jpg',
      rating: 4.8,
      reviewCount: 50,
      sizes: ['M', 'L'],
      colors: ['Charcoal'],
    );

    const testProduct2 = ProductEntity(
      id: 'prod_002',
      name: 'Cotton Tee',
      description: 'Heavyweight tee',
      price: 50.0,
      category: 'Tops',
      imageUrl: 'https://images.example.com/tee.jpg',
      rating: 4.9,
      reviewCount: 30,
      sizes: ['S', 'M'],
      colors: ['White'],
    );

    setUp(() {
      localDataSource = CartLocalDataSourceImpl();
      repository = CartRepositoryImpl(localDataSource);
      getCartUseCase = GetCartUseCase(repository);
      addToCartUseCase = AddToCartUseCase(repository);
      removeFromCartUseCase = RemoveFromCartUseCase(repository);
      updateCartQuantityUseCase = UpdateCartQuantityUseCase(repository);
      clearCartUseCase = ClearCartUseCase(repository);

      cartBloc = CartBloc(
        getCartUseCase: getCartUseCase,
        addToCartUseCase: addToCartUseCase,
        removeFromCartUseCase: removeFromCartUseCase,
        updateCartQuantityUseCase: updateCartQuantityUseCase,
        clearCartUseCase: clearCartUseCase,
      );
    });

    tearDown(() {
      cartBloc.close();
    });

    test('Initial CartState is empty with 0.0 totals', () {
      expect(cartBloc.state.items, isEmpty);
      expect(cartBloc.state.totalQuantity, 0);
      expect(cartBloc.state.subtotal, 0.0);
      expect(cartBloc.state.shippingFee, 0.0);
      expect(cartBloc.state.estimatedTax, 0.0);
      expect(cartBloc.state.totalPayable, 0.0);
    });

    test('Financial calculations work properly on CartState', () {
      const item1 = CartItemEntity(
        product: testProduct1, // $100
        quantity: 1,
        selectedSize: 'M',
        selectedColor: 'Charcoal',
      );
      // Under $150 threshold: subtotal $100 + $15 shipping + $5 tax = $120
      const stateUnderThreshold = CartState(
        status: CartStatus.loaded,
        items: [item1],
      );
      expect(stateUnderThreshold.subtotal, 100.0);
      expect(stateUnderThreshold.shippingFee, 15.0);
      expect(stateUnderThreshold.estimatedTax, 5.0);
      expect(stateUnderThreshold.totalPayable, 120.0);

      // Over $150 threshold: subtotal $200 -> Free shipping! + $10 tax = $210
      const item2 = CartItemEntity(
        product: testProduct1, // $100
        quantity: 2,
        selectedSize: 'M',
        selectedColor: 'Charcoal',
      );
      const stateOverThreshold = CartState(
        status: CartStatus.loaded,
        items: [item2],
      );
      expect(stateOverThreshold.subtotal, 200.0);
      expect(stateOverThreshold.shippingFee, 0.0);
      expect(stateOverThreshold.estimatedTax, 10.0);
      expect(stateOverThreshold.totalPayable, 210.0);
    });

    blocTest<CartBloc, CartState>(
      'Adds item to cart and updates totals and total quantity',
      build: () => cartBloc,
      act: (bloc) => bloc.add(
        const AddToCart(
          product: testProduct1,
          quantity: 1,
          size: 'M',
          color: 'Charcoal',
        ),
      ),
      expect: () => [
        isA<CartState>()
            .having((s) => s.status, 'status', CartStatus.loaded)
            .having((s) => s.items.length, 'items.length', 1)
            .having((s) => s.totalQuantity, 'totalQuantity', 1)
            .having((s) => s.subtotal, 'subtotal', 100.0)
            .having((s) => s.shippingFee, 'shippingFee', 15.0)
            .having((s) => s.totalPayable, 'totalPayable', 120.0),
      ],
    );

    blocTest<CartBloc, CartState>(
      'Updates quantity and recalculates totals correctly',
      build: () => cartBloc,
      act: (bloc) async {
        bloc.add(
          const AddToCart(
            product: testProduct1,
            quantity: 1,
            size: 'M',
            color: 'Charcoal',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(
          const UpdateCartQuantity(itemKey: 'prod_001_M_Charcoal', quantity: 3),
        );
      },
      skip: 1, // skip initial add
      expect: () => [
        isA<CartState>()
            .having((s) => s.status, 'status', CartStatus.loaded)
            .having((s) => s.items.first.quantity, 'quantity', 3)
            .having((s) => s.totalQuantity, 'totalQuantity', 3)
            .having((s) => s.subtotal, 'subtotal', 300.0)
            .having(
              (s) => s.shippingFee,
              'shippingFee',
              0.0,
            ) // Free shipping >= $150
            .having((s) => s.totalPayable, 'totalPayable', 315.0),
      ],
    );

    blocTest<CartBloc, CartState>(
      'Removing item or updating quantity to 0 removes item from cart',
      build: () => cartBloc,
      act: (bloc) async {
        bloc.add(
          const AddToCart(
            product: testProduct2,
            quantity: 1,
            size: 'S',
            color: 'White',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const RemoveFromCart('prod_002_S_White'));
      },
      skip: 1,
      expect: () => [
        isA<CartState>()
            .having((s) => s.items, 'items', isEmpty)
            .having((s) => s.totalQuantity, 'totalQuantity', 0)
            .having((s) => s.subtotal, 'subtotal', 0.0)
            .having((s) => s.totalPayable, 'totalPayable', 0.0),
      ],
    );

    blocTest<CartBloc, CartState>(
      'ClearCart empties all items and resets totals',
      build: () => cartBloc,
      act: (bloc) async {
        bloc.add(
          const AddToCart(
            product: testProduct1,
            quantity: 1,
            size: 'M',
            color: 'Charcoal',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearCart());
      },
      skip: 1,
      expect: () => [
        isA<CartState>()
            .having((s) => s.items, 'items', isEmpty)
            .having((s) => s.totalQuantity, 'totalQuantity', 0)
            .having((s) => s.totalPayable, 'totalPayable', 0.0),
      ],
    );
  });
}
