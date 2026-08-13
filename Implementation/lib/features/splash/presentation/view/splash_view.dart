import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late AnimationController _taglineController;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  late AnimationController _dot1Controller;
  late AnimationController _dot2Controller;
  late AnimationController _dot3Controller;

  late AnimationController _versionController;
  late Animation<double> _versionOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // logo spring
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: const ElasticOutCurve(0.8),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // tagline
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
        );

    // pulse ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseScale = Tween<double>(
      begin: 0.8,
      end: 1.6,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
    _pulseOpacity = Tween<double>(
      begin: 0.8,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    // dots
    _dot1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.3,
      upperBound: 1.0,
    );
    _dot2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.3,
      upperBound: 1.0,
    );
    _dot3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.3,
      upperBound: 1.0,
    );

    // version
    _versionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _versionOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _versionController, curve: Curves.easeOut),
    );
  }

  Future<void> _startAnimations() async {
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    _taglineController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _pulseController.repeat();

    _dot1Controller.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 200));
    _dot2Controller.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 200));
    _dot3Controller.repeat(reverse: true);

    _versionController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _pulseController.dispose();
    _dot1Controller.dispose();
    _dot2Controller.dispose();
    _dot3Controller.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashBloc()..add(StartSplash()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigate) {
            Navigator.pushReplacementNamed(
              context,
              state.route,
              arguments: {'name': state.name},
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // pulse ring
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseScale.value,
                      child: Opacity(
                        opacity: _pulseOpacity.value,
                        child: Container(
                          width: 280.w,
                          height: 280.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.borderColor.withValues(
                                alpha: 0.2,
                              ),
                              width: 2.w,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // logo
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Image.asset(
                              AppAssets.splashLogo1,
                              width: 260.w,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 20.h),

                    // tagline
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: SlideTransition(
                        position: _taglineSlide,
                        child: Text(
                          'Your Legal Partner in Pakistan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.borderColor,
                            letterSpacing: 0.5.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // loading dots
                Positioned(
                  bottom: 60.h,
                  child: FadeTransition(
                    opacity: _taglineOpacity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDot(_dot1Controller, AppColors.darkContrast),
                        SizedBox(width: 8.w),
                        _buildDot(_dot2Controller, AppColors.borderColor),
                        SizedBox(width: 8.w),
                        _buildDot(
                          _dot3Controller,
                          AppColors.borderColor.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),

                // version text
                Positioned(
                  bottom: 24.h,
                  child: FadeTransition(
                    opacity: _versionOpacity,
                    child: Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.darkContrast.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(AnimationController controller, Color color) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: controller.value,
          child: Container(
            width: 7.w,
            height: 7.h,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        );
      },
    );
  }
}
