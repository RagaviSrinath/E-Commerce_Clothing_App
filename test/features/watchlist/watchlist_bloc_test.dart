import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';
import 'package:nextgen/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:nextgen/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:nextgen/features/watchlist/domain/usecases/watchlist_usecases.dart';
import 'package:nextgen/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:nextgen/features/watchlist/presentation/bloc/watchlist_event.dart';
import 'package:nextgen/features/watchlist/presentation/bloc/watchlist_state.dart';

void main() {
  group('WatchlistBloc Unit Tests', () {
    late WatchlistLocalDataSource localDataSource;
    late WatchlistRepositoryImpl repository;
    late GetWatchlistUseCase getWatchlistUseCase;
    late AddToWatchlistUseCase addToWatchlistUseCase;
    late RemoveFromWatchlistUseCase removeFromWatchlistUseCase;
    late WatchlistBloc watchlistBloc;

    const sampleProduct1 = ProductEntity(
      id: 'prod_001',
      name: 'Tailored Blazer',
      description: 'Italian wool blend',
      price: 240.0,
      category: 'Outerwear',
      imageUrl: 'https://images.example.com/blazer.jpg',
      rating: 4.9,
      reviewCount: 142,
      sizes: ['S', 'M', 'L'],
      colors: ['Charcoal'],
    );

    const sampleProduct2 = ProductEntity(
      id: 'prod_002',
      name: 'Merino Knit',
      description: 'Extrafine wool',
      price: 135.0,
      category: 'Tops',
      imageUrl: 'https://images.example.com/knit.jpg',
      rating: 4.8,
      reviewCount: 98,
      sizes: ['M', 'L'],
      colors: ['Ivory'],
    );

    setUp(() {
      localDataSource = WatchlistLocalDataSourceImpl();
      repository = WatchlistRepositoryImpl(localDataSource);
      getWatchlistUseCase = GetWatchlistUseCase(repository);
      addToWatchlistUseCase = AddToWatchlistUseCase(repository);
      removeFromWatchlistUseCase = RemoveFromWatchlistUseCase(repository);

      watchlistBloc = WatchlistBloc(
        getWatchlistUseCase: getWatchlistUseCase,
        addToWatchlistUseCase: addToWatchlistUseCase,
        removeFromWatchlistUseCase: removeFromWatchlistUseCase,
      );
    });

    tearDown(() {
      watchlistBloc.close();
    });

    test('Initial WatchlistState is empty', () {
      expect(watchlistBloc.state.items, isEmpty);
      expect(watchlistBloc.state.favoriteIds, isEmpty);
      expect(watchlistBloc.state.count, 0);
      expect(watchlistBloc.state.isFavorite('prod_001'), isFalse);
    });

    blocTest<WatchlistBloc, WatchlistState>(
      'ToggleWatchlist adds an un-favorited item to watchlist and updates IDs',
      build: () => watchlistBloc,
      act: (bloc) => bloc.add(const ToggleWatchlist(sampleProduct1)),
      expect: () => [
        isA<WatchlistState>()
            .having((s) => s.status, 'status', WatchlistStatus.loaded)
            .having((s) => s.items.length, 'items.length', 1)
            .having(
              (s) => s.favoriteIds.contains('prod_001'),
              'contains prod_001',
              isTrue,
            )
            .having((s) => s.isFavorite('prod_001'), 'isFavorite', isTrue)
            .having(
              (s) => s.feedbackMessage,
              'feedbackMessage',
              contains('Added "Tailored Blazer"'),
            ),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'ToggleWatchlist removes an already favorited item from watchlist',
      build: () => watchlistBloc,
      seed: () => const WatchlistState(
        status: WatchlistStatus.loaded,
        items: [sampleProduct1],
        favoriteIds: {'prod_001'},
      ),
      act: (bloc) => bloc.add(const ToggleWatchlist(sampleProduct1)),
      expect: () => [
        isA<WatchlistState>()
            .having((s) => s.status, 'status', WatchlistStatus.loaded)
            .having((s) => s.items, 'items', isEmpty)
            .having((s) => s.favoriteIds, 'favoriteIds', isEmpty)
            .having((s) => s.isFavorite('prod_001'), 'isFavorite', isFalse)
            .having(
              (s) => s.feedbackMessage,
              'feedbackMessage',
              contains('Removed "Tailored Blazer"'),
            ),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'RemoveFromWatchlistEvent removes item by ID properly',
      build: () => watchlistBloc,
      seed: () => const WatchlistState(
        status: WatchlistStatus.loaded,
        items: [sampleProduct1, sampleProduct2],
        favoriteIds: {'prod_001', 'prod_002'},
      ),
      act: (bloc) => bloc.add(const RemoveFromWatchlistEvent('prod_001')),
      expect: () => [
        isA<WatchlistState>()
            .having((s) => s.items.length, 'items.length', 1)
            .having((s) => s.items.first.id, 'remaining item id', 'prod_002')
            .having((s) => s.favoriteIds, 'favoriteIds', {'prod_002'})
            .having(
              (s) => s.isFavorite('prod_001'),
              'isFavorite(prod_001)',
              isFalse,
            )
            .having(
              (s) => s.isFavorite('prod_002'),
              'isFavorite(prod_002)',
              isTrue,
            ),
      ],
    );
  });
}
