import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextgen/core/errors/failures.dart';

import '../../domain/usecases/cart_usecases.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.clearCartUseCase,
  }) : super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<ClearCartFeedback>(_onClearCartFeedback);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final items = await getCartUseCase();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: CartStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CartStatus.failure,
          errorMessage: 'Failed to load shopping bag.',
        ),
      );
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    if (event.quantity <= 0) return;

    try {
      await addToCartUseCase(
        event.product,
        quantity: event.quantity,
        selectedSize: event.size,
        selectedColor: event.color,
      );
      final items = await getCartUseCase();
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          items: items,
          feedbackMessage: 'Added "${event.product.name}" to shopping bag.',
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not add item to shopping bag.'));
    }
  }

  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      await updateCartQuantityUseCase(event.itemKey, event.quantity);
      final items = await getCartUseCase();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } on Failure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not update quantity.'));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      await removeFromCartUseCase(event.itemKey);
      final items = await getCartUseCase();
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          items: items,
          feedbackMessage: 'Item removed from shopping bag.',
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not remove item from bag.'));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      await clearCartUseCase();
      emit(state.copyWith(status: CartStatus.loaded, items: const []));
    } on Failure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not clear shopping bag.'));
    }
  }

  void _onClearCartFeedback(ClearCartFeedback event, Emitter<CartState> emit) {
    emit(state.copyWith(clearFeedback: true));
  }
}
