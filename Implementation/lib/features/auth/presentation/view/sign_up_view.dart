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
import 'package:lexbid/core/utils/app_padding.dart';
import 'package:lexbid/features/auth/bloc/auth_bloc.dart';
import 'package:lexbid/features/auth/bloc/auth_event.dart';
import 'package:lexbid/features/auth/bloc/auth_state.dart';
import 'package:lexbid/routes.dart';
import 'package:lexbid/widgets/ui_loader.dart';

class SignUpView extends StatefulWidget {
  final String userType;

  const SignUpView({super.key, required this.userType});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthBloc>();

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        /// SUCCESS (Retained Main File Verification Flow & Routing)
        if (state is SignUpSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteGenerator.loginRoute,
                (_) => false,
            arguments: {
              'userType': widget.userType,
              'showSuccessMessage': true,
            },
          );
        }

        /// FAILURE
        if (state is AuthFailure) {
          AppFlushBar.showError(
            context,
            message: state.failure.message,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Stack(
            children: [
              /// MAIN UI CONTENT
              Padding(
                padding: AppPadding.all,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 30.h),
                        Image.asset(AppAssets.authImage),
                        SizedBox(height: 30.h),
                        Text(AppStrings.signUp, style: AppStyle.style26w700()),
                        SizedBox(height: 30.h),

                        /// Name
                        CustomTextField(
                          width: double.infinity,
                          height: 60.h,
                          labelText: AppStrings.name,
                          controller: bloc.nameController,
                          keyboardType: TextInputType.name,
                        ),

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
                            final formState = state is AuthFormState
                                ? state
                                : AuthFormState.initial();

                            return CustomTextField(
                              width: double.infinity,
                              height: 60.h,
                              labelText: AppStrings.password,
                              controller: bloc.passwordController,
                              obscureText: !formState.isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  formState.isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.liteGery,
                                  size: 22.r,
                                ),
                                onPressed: () => context
                                    .read<AuthBloc>()
                                    .add(TogglePasswordVisibility()),
                              ),
                            );
                          },
                        ),

                        /// CONFIRM PASSWORD + ERROR
                        BlocBuilder<AuthBloc, AuthState>(
                          buildWhen: (prev, curr) => curr is AuthFormState,
                          builder: (context, state) {
                            final formState = state is AuthFormState
                                ? state
                                : AuthFormState.initial();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  width: double.infinity,
                                  height: 60.h,
                                  labelText: "Confirm Password",
                                  controller: bloc.confirmPasswordController,
                                  obscureText: !formState.isConfirmPasswordVisible,
                                  borderColor: formState.isConfirmPasswordValid
                                      ? AppColors.whiteColor
                                      : AppColors.redColor,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      formState.isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.liteGery,
                                      size: 22.r,
                                    ),
                                    onPressed: () => context
                                        .read<AuthBloc>()
                                        .add(ToggleConfirmPasswordVisibility()),
                                  ),
                                ),
                                if (!formState.isConfirmPasswordValid)
                                  Padding(
                                    padding: EdgeInsets.only(top: 5.h, left: 6.w),
                                    child: Text(
                                      "Password and Confirm Password must be same",
                                      style: AppStyle.style12w400(color: AppColors.redColor),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 20.h),

                        /// SIGN UP BUTTON
                        CustomButton(
                          text: AppStrings.signUp,
                          width: double.infinity,
                          height: 50.h,
                          gradientColors: AppColors.buttonGradient,
                          textStyle: AppStyle.style16w400(color: AppColors.whiteColor),
                          onTap: () async {
                            final authBloc = context.read<AuthBloc>();
                            authBloc.add(ValidateConfirmPasswordEvent());
                            await Future.delayed(Duration.zero);

                            // Quick check validation to match your error mapper update
                            if (authBloc.nameController.text.trim().isEmpty ||
                                authBloc.emailController.text.trim().isEmpty ||
                                authBloc.passwordController.text.trim().isEmpty) {
                              authBloc.add(SignUpEvent(
                                name: authBloc.nameController.text.trim(),
                                email: authBloc.emailController.text.trim(),
                                password: authBloc.passwordController.text.trim(),
                                userType: widget.userType,
                                deviceToken: "",
                              ));
                              return;
                            }

                            String token = "";
                            try {
                              token = await FirebaseMessaging.instance.getToken() ?? "";
                            } catch (e) {
                              debugPrint("FCM Fetch Error: $e");
                            }

                            // Async gap handling guard check
                            if (!context.mounted) return;

                            authBloc.add(
                              SignUpEvent(
                                name: authBloc.nameController.text.trim(),
                                email: authBloc.emailController.text.trim(),
                                password: authBloc.passwordController.text.trim(),
                                userType: widget.userType,
                                deviceToken: token,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 15.h),

                        /// LOGIN LINK
                        RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: AppStyle.style12w400(color: AppColors.liteGery),
                            children: [
                              TextSpan(
                                text: AppStrings.login,
                                style: AppStyle.style12w600(),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// 🔥 IN-VIEW LOADER (Updated with UiLoader)
              if (state is AuthLoading)
                Container(
                  color: Colors.black.withAlpha(40),
                  child: const Center(
                    child: UiLoader(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}