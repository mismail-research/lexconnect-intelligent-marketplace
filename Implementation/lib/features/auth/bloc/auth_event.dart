import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String selectedRole;
  final String deviceToken;

  LoginEvent(this.email, this.password, this.selectedRole,this.deviceToken,);

}

class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String userType;
  final String deviceToken;

  SignUpEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    required this.deviceToken,
  });
}


class LogoutEvent extends AuthEvent {
  final String uid;
  final String deviceToken;

  LogoutEvent({
    required this.uid,
    required this.deviceToken,
  });

  @override
  List<Object?> get props => [uid, deviceToken];
}

class RestoreSessionEvent extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class TogglePasswordVisibility extends AuthEvent {}

class ToggleConfirmPasswordVisibility extends AuthEvent {}

/// NEW EVENT
class ValidateConfirmPasswordEvent extends AuthEvent {}
class ForgotPasswordEvent extends AuthEvent {
  final String email;

  ForgotPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}


