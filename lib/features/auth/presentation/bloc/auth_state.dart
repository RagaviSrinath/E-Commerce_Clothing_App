import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, submitting, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.email = '',
    this.password = '',
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.user,
    this.errorMessage,
  });

  bool get isFormValid => isEmailValid && isPasswordValid;
  bool get isLoading => status == AuthStatus.submitting;

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? password,
    bool? isEmailValid,
    bool? isPasswordValid,
    UserEntity? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    email,
    password,
    isEmailValid,
    isPasswordValid,
    user,
    errorMessage,
  ];
}
