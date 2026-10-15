import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:nextgen/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nextgen/features/auth/domain/entities/user_entity.dart';
import 'package:nextgen/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:nextgen/features/auth/domain/usecases/login_usecase.dart';
import 'package:nextgen/features/auth/domain/usecases/logout_usecase.dart';
import 'package:nextgen/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nextgen/features/auth/presentation/bloc/auth_event.dart';
import 'package:nextgen/features/auth/presentation/bloc/auth_state.dart';

void main() {
  group('AuthBloc Unit Tests', () {
    late AuthLocalDataSource localDataSource;
    late AuthRepositoryImpl repository;
    late LoginUseCase loginUseCase;
    late GetCurrentUserUseCase getCurrentUserUseCase;
    late LogoutUseCase logoutUseCase;
    late AuthBloc authBloc;

    setUp(() {
      localDataSource = AuthLocalDataSourceImpl();
      repository = AuthRepositoryImpl(localDataSource);
      loginUseCase = LoginUseCase(repository);
      getCurrentUserUseCase = GetCurrentUserUseCase(repository);
      logoutUseCase = LogoutUseCase(repository);
      authBloc = AuthBloc(
        loginUseCase: loginUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        logoutUseCase: logoutUseCase,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('Initial state is AuthState with initial status and empty fields', () {
      expect(authBloc.state, const AuthState());
      expect(authBloc.state.status, AuthStatus.initial);
      expect(authBloc.state.isFormValid, isFalse);
    });

    blocTest<AuthBloc, AuthState>(
      'Emits updated email and validation state when AuthEmailChanged is added',
      build: () => authBloc,
      act: (bloc) {
        bloc.add(const AuthEmailChanged('invalid-email'));
        bloc.add(const AuthEmailChanged('user@nextgen.com'));
      },
      expect: () => [
        const AuthState(email: 'invalid-email', isEmailValid: false),
        const AuthState(email: 'user@nextgen.com', isEmailValid: true),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Emits updated password and validation state when AuthPasswordChanged is added',
      build: () => authBloc,
      act: (bloc) {
        bloc.add(const AuthPasswordChanged(''));
        bloc.add(const AuthPasswordChanged('123'));
        bloc.add(const AuthPasswordChanged('Pass'));
      },
      expect: () => [
        const AuthState(password: '', isPasswordValid: false),
        const AuthState(password: '123', isPasswordValid: false),
        const AuthState(password: 'Pass', isPasswordValid: true),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Emits [submitting, failure] on invalid credentials',
      build: () => authBloc,
      seed: () => const AuthState(
        email: 'user@nextgen.com',
        password: 'WrongPassword',
        isEmailValid: true,
        isPasswordValid: true,
      ),
      wait: const Duration(milliseconds: 1000),
      act: (bloc) => bloc.add(const AuthLoginSubmitted()),
      expect: () => [
        const AuthState(
          email: 'user@nextgen.com',
          password: 'WrongPassword',
          isEmailValid: true,
          isPasswordValid: true,
          status: AuthStatus.submitting,
        ),
        const AuthState(
          email: 'user@nextgen.com',
          password: 'WrongPassword',
          isEmailValid: true,
          isPasswordValid: true,
          status: AuthStatus.failure,
          errorMessage:
              'Invalid email or password. Please check your credentials.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Emits [submitting, authenticated] on correct credentials',
      build: () => authBloc,
      wait: const Duration(milliseconds: 1000),
      seed: () => const AuthState(
        email: 'user@nextgen.com',
        password: 'Password123',
        isEmailValid: true,
        isPasswordValid: true,
      ),
      act: (bloc) => bloc.add(const AuthLoginSubmitted()),
      expect: () => [
        const AuthState(
          email: 'user@nextgen.com',
          password: 'Password123',
          isEmailValid: true,
          isPasswordValid: true,
          status: AuthStatus.submitting,
        ),
        const AuthState(
          email: 'user@nextgen.com',
          password: 'Password123',
          isEmailValid: true,
          isPasswordValid: true,
          status: AuthStatus.authenticated,
          user: UserEntity(
            id: 'usr_001',
            name: 'Aarav Sharma',
            email: 'user@nextgen.com',
          ),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Emits [submitting, authenticated] for any valid email address (e.g. test@gmail.com)',
      build: () => authBloc,
      wait: const Duration(milliseconds: 1000),
      seed: () => const AuthState(
        email: 'test@gmail.com',
        password: 'AnyPassword123',
        isEmailValid: true,
        isPasswordValid: true,
      ),
      act: (bloc) => bloc.add(const AuthLoginSubmitted()),
      expect: () => [
        const AuthState(
          email: 'test@gmail.com',
          password: 'AnyPassword123',
          isEmailValid: true,
          isPasswordValid: true,
          status: AuthStatus.submitting,
        ),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user?.email, 'email', 'test@gmail.com')
            .having((s) => s.user?.name, 'name', 'Test'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'Emits [unauthenticated] when AuthCheckRequested is called with no saved session',
      build: () => authBloc,
      wait: const Duration(milliseconds: 300),
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    );

    blocTest<AuthBloc, AuthState>(
      'Emits [unauthenticated] when AuthLogoutRequested is added',
      build: () => authBloc,
      wait: const Duration(milliseconds: 300),
      seed: () => const AuthState(
        status: AuthStatus.authenticated,
        user: UserEntity(
          id: 'usr_001',
          name: 'Aarav Sharma',
          email: 'user@nextgen.com',
        ),
      ),
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    );
  });
}
