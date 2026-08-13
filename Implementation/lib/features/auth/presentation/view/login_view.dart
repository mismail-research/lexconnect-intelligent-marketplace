import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/common/widgets/app_flushbar.dart';
import 'package:lexbid/core/common/widgets/custom_botton.dart';
import 'package:lexbid/core/common/widgets/custom_textfield.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_strings.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/core/services/notification_service.dart';
import 'package:lexbid/core/utils/app_padding.dart';
import 'package:lexbid/features/auth/bloc/auth_bloc.dart';
import 'package:lexbid/features/auth/bloc/auth_event.dart';
import 'package:lexbid/features/auth/bloc/auth_state.dart';
import 'package:lexbid/routes.dart';
import 'package:lexbid/widgets/ui_loader.dart';

class LoginView extends StatefulWidget {
  final String userType;
  const LoginView({super.key, required this.userType});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _checkedMessage = false;
  bool _isLoading = false; // ✅ Local loading flag

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checkedMessage) {
      _checkedMessage = true;
      final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['showSuccessMessage'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          AppFlushBar.showSuccess(
            context,
            message:
            "Account created! Please check your email and verify your account before logging in.",
          );
        });
      }
    }
  }

  void _showForgotPasswordDialog(BuildContext context, AuthBloc bloc) {
    final resetEmailController = TextEditingController(
      text: bloc.emailController.text.trim(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (listenerContext, state) {
            if (state is PasswordResetEmailSent) {
              Navigator.pop(dialogContext);
              AppFlushBar.showSuccess(context, message: state.message);
            }
            if (state is AuthFailure) {
              Navigator.pop(dialogContext);
              AppFlushBar.showError(context, message: state.failure.message);
            }
          },
          child: AlertDialog(
            backgroundColor: AppColors.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text("Reset Password", style: AppStyle.style18w600()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter your email and we'll send you a link to reset your password.",
                  style: AppStyle.style14w400(color: AppColors.liteGery),
                ),
                SizedBox(height: 15.h),
                CustomTextField(
                  width: double.infinity,
                  height: 55.h,
                  hintText: AppStrings.email,
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  AppStrings.cancel,
                  style: AppStyle.style14w400(color: AppColors.liteGery),
                ),
              ),
              TextButton(
                onPressed: () {
                  dialogContext.read<AuthBloc>().add(
                    ForgotPasswordEvent(resetEmailController.text.trim()),
                  );
                },
                child: Text(
                  "Send Link",
                  style: AppStyle.style14w400(color: AppColors.liteBlue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthBloc>();

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
      current is AuthLoading ||
          current is AuthSuccess ||
          current is AuthFailure ||
          current is PasswordResetEmailSent,
      listener: (context, state) async {
        if (state is AuthLoading) {
          // ✅ Only show overlay for login, not forgot password
          //    (forgot password has its own dialog)
          if (!_isForgotPasswordDialogOpen(context)) {
            setState(() => _isLoading = true);
          }
        }

        if (state is AuthSuccess) {
          setState(() => _isLoading = false);

          AppFlushBar.showSuccess(context, message: state.message);
          await NotificationService().saveDeviceToken();

          if (!context.mounted) return;

          if (state.user.userType.toLowerCase() == 'lawyer') {
            Navigator.pushReplacementNamed(
              context,
              RouteGenerator.approvalGate,
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              RouteGenerator.clientBottomNavRoute,
            );
          }
        }

        if (state is AuthFailure) {
          setState(() => _isLoading = false);
          AppFlushBar.showError(context, message: state.failure.message);
        }

        if (state is PasswordResetEmailSent) {
          setState(() => _isLoading = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            /// MAIN UI
            Padding(
              padding: AppPadding.all,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 50.h),
                      Image.asset(AppAssets.authImage),
                      SizedBox(height: 30.h),
                      Text(AppStrings.login, style: AppStyle.style26w700()),
                      SizedBox(height: 27.h),

                      /// EMAIL
                      CustomTextField(
                        width: double.infinity,
                        height: 60.h,
                        labelText: AppStrings.email,
                        controller: bloc.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      /// PASSWORD
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (prev, curr) => curr is AuthFormState,
                        builder: (context, state) {
                          final isVisible = state is AuthFormState
                              ? state.isPasswordVisible
                              : false;

                          return CustomTextField(
                            width: double.infinity,
                            height: 60.h,
                            labelText: AppStrings.password,
                            controller: bloc.passwordController,
                            obscureText: !isVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.liteGery,
                              ),
                              onPressed: () {
                                context
                                    .read<AuthBloc>()
                                    .add(TogglePasswordVisibility());
                              },
                            ),
                          );
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              _showForgotPasswordDialog(context, bloc),
                          child: Text(
                            "Forget Password?",
                            style: AppStyle.style16w400(),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      /// LOGIN BUTTON
                      CustomButton(
                        text: AppStrings.login,
                        width: double.infinity,
                        height: 50.h,
                        gradientColors: AppColors.buttonGradient,
                        textStyle: AppStyle.style16w400(
                          color: AppColors.whiteColor,
                        ),
                        onTap: () async {
                          String token = "";

                          try {
                            final fcmToken =
                            await FirebaseMessaging.instance.getToken();
                            if (fcmToken != null) token = fcmToken;
                          } catch (e) {
                            debugPrint(
                                "❌ FirebaseMessaging getToken failed: $e");
                          }

                          if (!context.mounted) return;

                          context.read<AuthBloc>().add(
                            LoginEvent(
                              bloc.emailController.text.trim(),
                              bloc.passwordController.text.trim(),
                              widget.userType,
                              token,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 15.h),

                      /// SIGNUP LINK
                      RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style:
                          AppStyle.style12w400(color: AppColors.liteGery),
                          children: [
                            TextSpan(
                              text: AppStrings.signUp,
                              style: AppStyle.style12w600(),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(
                                    context,
                                    RouteGenerator.signUpRoute,
                                    arguments: {'userType': widget.userType},
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ Full-screen overlay — only for login loading
            if (_isLoading)
              Container(
                color: Colors.black.withAlpha(40),
                child: const Center(
                  child: UiLoader(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper: checks if the forgot password dialog is currently open
  bool _isForgotPasswordDialogOpen(BuildContext context) {
    return ModalRoute.of(context)?.isCurrent == false;
  }
}