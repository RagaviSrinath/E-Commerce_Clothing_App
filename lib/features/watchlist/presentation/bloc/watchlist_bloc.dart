import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextgen/core/errors/failures.dart';
import 'package:nextgen/features/products/domain/entities/product_entity.dart';

import '../../domain/usecases/watchlist_usecases.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlistUseCase getWatchlistUseCase;
  final AddToWatchlistUseCase addToWatchlistUseCase;
  final RemoveFromWatchlistUseCase removeFromWatchlistUseCase;

  WatchlistBloc({
    required this.getWatchlistUseCase,
    required this.addToWatchlistUseCase,
    required this.removeFromWatchlistUseCase,
  }) : super(const WatchlistState()) {
    on<LoadWatchlist>(_onLoadWatchlist);
    on<ToggleWatchlist>(_onToggleWatchlist);
    on<RemoveFromWatchlistEvent>(_onRemoveFromWatchlist);
    on<ClearWatchlistFeedback>(_onClearWatchlistFeedback);
  }

  Future<void> _onLoadWatchlist(
    LoadWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    try {
      final items = await getWatchlistUseCase();
      final ids = items.map((p) => p.id).toSet();
      emit(
        state.copyWith(
          status: WatchlistStatus.loaded,
          items: items,
          favoriteIds: ids,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: WatchlistStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchlistStatus.failure,
          errorMessage: 'Failed to load watchlist items.',
        ),
      );
    }
  }

  Future<void> _onToggleWatchlist(
    ToggleWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final product = event.product;
    final isAlreadyFavorite = state.isFavorite(product.id);

    try {
      if (isAlreadyFavorite) {
        await removeFromWatchlistUseCase(product.id);
        final updatedItems = state.items
            .where((p) => p.id != product.id)
            .toList();
        final updatedIds = Set<String>.from(state.favoriteIds)
          ..remove(product.id);
        emit(
          state.copyWith(
            status: WatchlistStatus.loaded,
            items: updatedItems,
            favoriteIds: updatedIds,
            feedbackMessage: 'Removed "${product.name}" from wishlist.',
          ),
        );
      } else {
        await addToWatchlistUseCase(product);
        final updatedItems = [...state.items, product];
        final updatedIds = Set<String>.from(state.favoriteIds)..add(product.id);
        emit(
          state.copyWith(
            status: WatchlistStatus.loaded,
            items: updatedItems,
            favoriteIds: updatedIds,
            feedbackMessage: 'Added "${product.name}" to wishlist.',
          ),
        );
      }
    } on Failure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not update watchlist.'));
    }
  }

  Future<void> _onRemoveFromWatchlist(
    RemoveFromWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      await removeFromWatchlistUseCase(event.productId);
      ProductEntity? item;
      for (final p in state.items) {
        if (p.id == event.productId) {
          item = p;
          break;
        }
      }
      final updatedItems = state.items
          .where((p) => p.id != event.productId)
          .toList();
      final updatedIds = Set<String>.from(state.favoriteIds)
        ..remove(event.productId);
      emit(
        state.copyWith(
          status: WatchlistStatus.loaded,
          items: updatedItems,
          favoriteIds: updatedIds,
          feedbackMessage: item != null
              ? 'Removed "${item.name}" from wishlist.'
              : 'Item removed from wishlist.',
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Could not remove item from wishlist.'),
      );
    }
  }

  void _onClearWatchlistFeedback(
    ClearWatchlistFeedback event,
    Emitter<WatchlistState> emit,
  ) {
    emit(state.copyWith(clearFeedback: true));
  }
}
