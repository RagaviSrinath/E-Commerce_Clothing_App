import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextgen/core/errors/failures.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';
import 'package:nextgen/features/products/domain/repositories/product_repository.dart';
import 'package:nextgen/features/products/domain/usecases/get_products_usecase.dart';
import 'package:nextgen/features/products/presentation/bloc/product_bloc.dart';
import 'package:nextgen/features/products/presentation/bloc/product_event.dart';
import 'package:nextgen/features/products/presentation/bloc/product_state.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  group('ProductBloc Unit Tests', () {
    late MockProductRepository mockRepository;
    late GetProductsUseCase getProductsUseCase;
    late ProductBloc productBloc;

    final mockProductsList = [
      const ProductEntity(
        id: 'prod_001',
        name: 'Wool Blazer',
        description: 'Tailored blazer',
        price: 240.0,
        category: 'Outerwear',
        imageUrl: 'https://example.com/blazer.jpg',
        rating: 4.9,
        reviewCount: 140,
        sizes: ['M', 'L'],
        colors: ['Charcoal'],
      ),
      const ProductEntity(
        id: 'prod_002',
        name: 'Silk Shirt',
        description: 'Silk camp collar shirt',
        price: 160.0,
        category: 'Tops',
        imageUrl: 'https://example.com/shirt.jpg',
        rating: 4.8,
        reviewCount: 90,
        sizes: ['S', 'M'],
        colors: ['Ivory'],
      ),
    ];

    setUp(() {
      mockRepository = MockProductRepository();
      getProductsUseCase = GetProductsUseCase(mockRepository);
      productBloc = ProductBloc(getProductsUseCase: getProductsUseCase);
    });

    tearDown(() {
      productBloc.close();
    });

    test('Initial state is ProductState with initial status', () {
      expect(productBloc.state.status, ProductStatus.initial);
      expect(productBloc.state.allProducts, isEmpty);
      expect(productBloc.state.filteredProducts, isEmpty);
      expect(productBloc.state.selectedCategory, 'All');
    });

    blocTest<ProductBloc, ProductState>(
      'Emits [loading, success] when LoadProducts succeeds',
      build: () {
        when(() => mockRepository.getProducts())
            .thenAnswer((_) async => mockProductsList);
        return productBloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        isA<ProductState>()
            .having((s) => s.status, 'status', ProductStatus.success)
            .having((s) => s.allProducts.length, 'allProducts.length', 2)
            .having(
              (s) => s.filteredProducts.length,
              'filteredProducts.length',
              2,
            )
            .having(
              (s) => s.categories,
              'categories',
              containsAll(['All', 'Outerwear', 'Tops']),
            ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'Emits [loading, failure] when LoadProducts fails',
      build: () {
        when(() => mockRepository.getProducts())
            .thenThrow(const ProductFailure('Unable to load products'));
        return productBloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        const ProductState(
          status: ProductStatus.failure,
          errorMessage: 'Unable to load products',
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'Filters products by category when FilterCategory is added',
      build: () => productBloc,
      seed: () => ProductState(
        status: ProductStatus.success,
        allProducts: mockProductsList,
        filteredProducts: mockProductsList,
        categories: const ['All', 'Outerwear', 'Tops'],
        selectedCategory: 'All',
      ),
      act: (bloc) => bloc.add(const FilterCategory('Outerwear')),
      expect: () => [
        isA<ProductState>()
            .having((s) => s.selectedCategory, 'category', 'Outerwear')
            .having((s) => s.filteredProducts.length, 'count', 1)
            .having(
              (s) => s.filteredProducts.first.name,
              'name',
              'Wool Blazer',
            ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'Filters products by search query when SearchProducts is added',
      build: () => productBloc,
      seed: () => ProductState(
        status: ProductStatus.success,
        allProducts: mockProductsList,
        filteredProducts: mockProductsList,
        categories: const ['All', 'Outerwear', 'Tops'],
      ),
      act: (bloc) => bloc.add(const SearchProducts('Silk')),
      expect: () => [
        isA<ProductState>()
            .having((s) => s.searchQuery, 'query', 'Silk')
            .having((s) => s.filteredProducts.length, 'count', 1)
            .having((s) => s.filteredProducts.first.name, 'name', 'Silk Shirt'),
      ],
    );
  });
}
