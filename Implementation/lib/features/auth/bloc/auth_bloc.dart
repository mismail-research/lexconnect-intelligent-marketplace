import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lexbid/core/constants/error/exceptions.dart';
import 'package:lexbid/core/constants/error/failures.dart';
import 'package:lexbid/core/storage/auth_local_storage.dart';
import 'package:lexbid/features/auth/domain/entities/user_entity.dart';
import 'package:lexbid/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:lexbid/features/auth/domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:lexbid/features/auth/domain/usecases/login_usecase.dart';
import 'package:lexbid/features/auth/domain/usecases/signup_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final LogoutUseCase logoutUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.logoutUseCase,
    required this.forgotPasswordUseCase,
  }) : super(AuthFormState.initial()) {
    on<TogglePasswordVisibility>(_togglePassword);
    on<ToggleConfirmPasswordVisibility>(_toggleConfirmPassword);
    on<ValidateConfirmPasswordEvent>(_validateConfirmPassword);
    on<ForgotPasswordEvent>(_onForgotPassword);

    on<LoginEvent>(_onLogin);
    on<SignUpEvent>(_onSignUp);
    on<LogoutEvent>(_onLogout);

    on<RestoreSessionEvent>(_onRestoreSession);
    on<CheckAuthStatus>((event, emit) => add(RestoreSessionEvent()));
  }

  // --------------------------------------------------
  // RESTORE SESSION
  // --------------------------------------------------
  Future<void> _onRestoreSession(
      RestoreSessionEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthSessionRestoring());


    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      emit(AuthUnauthenticated());
      return;
    }

    await firebaseUser.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser == null || !refreshedUser.emailVerified) {
      await FirebaseAuth.instance.signOut(); // clean up unverified session
      emit(AuthUnauthenticated());
      return;
    }

    final storage = AuthLocalStorage();
    final name = await storage.getName();
    final role = await storage.getRole();

    if (role == null) {
      emit(AuthUnauthenticated());
      return;
    }

    emit(
      AuthSuccess(
        UserEntity(
          uid: firebaseUser.uid,
          name: name ?? '',
          email: firebaseUser.email ?? '',
          userType: role,
          deviceTokens: const [],
          emailVerified: firebaseUser.emailVerified, // ✅ NEW
        ),
        message: "Session Restored",
      ),
    );
  }

  // --------------------------------------------------
  // UI HELPERS
  // --------------------------------------------------
  void _togglePassword(
      TogglePasswordVisibility event,
      Emitter<AuthState> emit,
      ) {
    final current = state is AuthFormState
        ? state as AuthFormState
        : AuthFormState.initial();

    emit(current.copyWith(isPasswordVisible: !current.isPasswordVisible));
  }

  void _toggleConfirmPassword(
      ToggleConfirmPasswordVisibility event,
      Emitter<AuthState> emit,
      ) {
    final current = state is AuthFormState
        ? state as AuthFormState
        : AuthFormState.initial();

    emit(
      current.copyWith(
        isConfirmPasswordVisible: !current.isConfirmPasswordVisible,
      ),
    );
  }

  void _validateConfirmPassword(
      ValidateConfirmPasswordEvent event,
      Emitter<AuthState> emit,
      ) {
    final current = state is AuthFormState
        ? state as AuthFormState
        : AuthFormState.initial();

    final isValid = passwordController.text.trim() ==
        confirmPasswordController.text.trim();

    emit(current.copyWith(isConfirmPasswordValid: isValid));
  }

  // --------------------------------------------------
  // LOGIN
  // --------------------------------------------------

  Future<void> _onLogin(
      LoginEvent event,
      Emitter<AuthState> emit,
      ) async {
    // 1. Client-Side Validation: Ensure fields aren't empty before showing loader
    if (event.email.trim().isEmpty && event.password.trim().isEmpty) {
      emit(AuthFailure(
        const ServerFailure("Please enter your email and password to log in."),
        previousState: state,
      ));
      return;
    }

    if (event.email.trim().isEmpty) {
      emit(AuthFailure(
        const ServerFailure("Please enter your email address."),
        previousState: state,
      ));
      return;
    }

    if (event.password.trim().isEmpty) {
      emit(AuthFailure(
        const ServerFailure("Please enter your password."),
        previousState: state,
      ));
      return;
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(event.email.trim())) {
      emit(AuthFailure(
        const ServerFailure("Please enter a valid email address."),
        previousState: state,
      ));
      return;
    }

    emit(AuthLoading());

    try {
      final user = await loginUseCase(
        event.email,
        event.password,
        event.selectedRole,
        event.deviceToken,
      );

      await AuthLocalStorage().saveSession(
        user.userType.toLowerCase(),
        user.name,
      );
      emit(AuthSuccess(user, message: "Login Successful!"));
    } catch (e) {
      // 2. Fall back cleanly to the non-loading state on error
      emit(AuthFailure(
        _mapExceptionToFailure(e),
        previousState: state is AuthFormState ? state : AuthFormState.initial(),
      ));
    }
  }

  Future<void> _onForgotPassword(
      ForgotPasswordEvent event,
      Emitter<AuthState> emit,
      ) async {
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');

    if (event.email.trim().isEmpty) {
      emit(AuthFailure(
        const ServerFailure("Please enter your email address."),
        previousState: state,
      ));
      return;
    }

    if (!emailRegex.hasMatch(event.email.trim())) {
      emit(AuthFailure(
        const ServerFailure("Please enter a valid email address."),
        previousState: state,
      ));
      return;
    }

    emit(AuthLoading());

    try {
      await forgotPasswordUseCase(event.email.trim());
      emit(const PasswordResetEmailSent(
        message: "A password reset link has been sent to your email.",
      ));
    } catch (e) {
      emit(AuthFailure(
        _mapExceptionToFailure(e),
        previousState: state is AuthFormState ? state : AuthFormState.initial(),
      ));
    }
  }

  // --------------------------------------------------
  // SIGN UP
  // --------------------------------------------------
  Future<void> _onSignUp(
      SignUpEvent event,
      Emitter<AuthState> emit,
      ) async {
    // 1. Check for completely empty fields first
    if (event.name.trim().isEmpty ||
        event.email.trim().isEmpty ||
        event.password.trim().isEmpty) {
      emit(AuthFailure(
        const ServerFailure("Please fill out all fields to create your account."),
        previousState: state is AuthFormState ? state : AuthFormState.initial(),
      ));
      return;
    }

    // 2. Validate password match before touching the network server
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      emit(AuthFailure(
        const ServerFailure("Your passwords do not match. Please check them and try again."),
        previousState: state is AuthFormState ? state : AuthFormState.initial(),
      ));
      return;
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(event.email.trim())) {
      emit(AuthFailure(
        const ServerFailure("Please enter a valid email address."),
        previousState: state is AuthFormState ? state : AuthFormState.initial(),
      ));
      return;
    }

    emit(AuthLoading());

    try {
      final user = await signUpUseCase(
        event.name,
        event.email,
        event.password,
        event.userType,
        event.deviceToken,
      );

      // await AuthLocalStorage().saveSession(
      //   user.userType.toLowerCase(),
      //   user.name,
      // );
      await FirebaseAuth.instance.signOut();

      emit(SignUpSuccess(message: "Account created successfully!"));
    } catch (e) {
      // 3. Fallback to our user-friendly mapper if Firebase throws an error (e.g. email-already-in-use)
      emit(AuthFailure(
        _mapExceptionToFailure(e),
        previousState: state is AuthFormState ? state : AuthFormState.initial(),
      ));
    }
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------
  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      await logoutUseCase(event.uid, event.deviceToken);
      await AuthLocalStorage().clearSession();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(ServerFailure(e.toString()),
          previousState: state));
    }
  }

  // --------------------------------------------------
  // ERROR MAPPER
  // --------------------------------------------------

   Failure _mapExceptionToFailure(dynamic error) {
    if (error is NetworkException) {
      return const NetworkFailure();
    }

    if (error is AuthException) {
      if (error.message.contains("not registered as")) {
        return const ServerFailure(
          "This account isn't registered for the role you selected. Please check your role and try again.",
        );
      }
      return ServerFailure(error.message);
    }

    if (error is ServerException) {
      return const ServerFailure("We're having trouble connecting to our servers right now. Please try again in a moment.");
    }

    if (error is FirebaseAuthException) {
      if (error.code == 'network-request-failed') {
        return const NetworkFailure();
      }

      // Translate confusing Firebase codes into friendly text
      switch (error.code) {
        case 'invalid-email':
          return const ServerFailure("The email address you entered doesn't look valid. Please check for typos.");
        case 'user-disabled':
          return const ServerFailure("This account has been deactivated. Please contact support for help.");
        case 'user-not-found':
          return const ServerFailure("We couldn't find an account with that email address. Would you like to sign up instead?");
        case 'wrong-password':
        case 'invalid-credential': // Modern Firebase uses this for wrong pass/email combinations
          return const ServerFailure("The email or password you entered is incorrect. Please try again.");
        case 'email-already-in-use':
          return const ServerFailure("An account is already registered with this email. Try logging in instead.");
        case 'weak-password':
          return const ServerFailure("Your password is too weak. Please choose a password with at least 6 characters.");
        case 'too-many-requests':
          return const ServerFailure("Too many failed attempts. We've temporarily blocked requests to protect your account. Please try again later.");
        default:
          return ServerFailure(error.message ?? "Something went wrong while logging you in. Please try again.");
      }
    }

    return ServerFailure(error.toString());
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
