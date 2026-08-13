import 'package:equatable/equatable.dart';
import 'package:lexbid/core/constants/error/failures.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthSessionRestoring extends AuthState {}

class SignUpSuccess extends AuthState {
  final String message;
  const SignUpSuccess({required this.message});
}


class AuthFormState extends AuthState {
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isConfirmPasswordValid;

  const AuthFormState({
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.isConfirmPasswordValid,
  });

  factory AuthFormState.initial() => const AuthFormState(
    isPasswordVisible: false,
    isConfirmPasswordVisible: false,
    isConfirmPasswordValid: true,
  );

  AuthFormState copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isConfirmPasswordValid,
  }) {
    return AuthFormState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
      isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isConfirmPasswordValid:
      isConfirmPasswordValid ?? this.isConfirmPasswordValid,
    );
  }

  @override
  List<Object?> get props => [
    isPasswordVisible,
    isConfirmPasswordVisible,
    isConfirmPasswordValid,
  ];
}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final dynamic user;
  final String message;

  const AuthSuccess(this.user, {required this.message});

  @override
  List<Object?> get props => [user, message];
}

class AuthFailure extends AuthState {
  final Failure failure;
  final AuthState previousState;

  const AuthFailure(this.failure, {required this.previousState});

  @override
  List<Object?> get props => [failure, previousState];
}

class PasswordResetEmailSent extends AuthState {
  final String message;

  const PasswordResetEmailSent({required this.message});

  @override
  List<Object?> get props => [message];
}

