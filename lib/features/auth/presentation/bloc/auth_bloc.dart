import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final GetCurrentUserUseCase? getCurrentUserUseCase;
  final LogoutUseCase? logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    this.getCurrentUserUseCase,
    this.logoutUseCase,
  }) : super(const AuthState()) {
    on<AuthEmailChanged>(_onEmailChanged);
    on<AuthPasswordChanged>(_onPasswordChanged);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthErrorDismissed>(_onErrorDismissed);
  }

  void _onEmailChanged(AuthEmailChanged event, Emitter<AuthState> emit) {
    final isValid = Validators.isValidEmail(event.email);
    emit(
      state.copyWith(
        email: event.email,
        isEmailValid: isValid,
        clearError: true,
      ),
    );
  }

  void _onPasswordChanged(AuthPasswordChanged event, Emitter<AuthState> emit) {
    final isValid = Validators.isValidPassword(event.password);
    emit(
      state.copyWith(
        password: event.password,
        isPasswordValid: isValid,
        clearError: true,
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (!state.isFormValid) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Please enter a valid email and a password of at least 4 characters.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.submitting, clearError: true));

    try {
      final user = await loginUseCase(
        email: state.email,
        password: state.password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'An unexpected authentication error occurred.',
        ),
      );
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (getCurrentUserUseCase != null) {
      try {
        final user = await getCurrentUserUseCase!();
        if (user != null) {
          emit(state.copyWith(status: AuthStatus.authenticated, user: user));
          return;
        }
      } catch (_) {}
    }
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (logoutUseCase != null) {
      try {
        await logoutUseCase!();
      } catch (_) {}
    }
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onErrorDismissed(AuthErrorDismissed event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearError: true));
  }
}
