import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class EmptyLawyerState extends StatefulWidget {
  final String category;

  const EmptyLawyerState({super.key, required this.category});

  @override
  State<EmptyLawyerState> createState() => _EmptyLawyerStateState();
}

class _EmptyLawyerStateState extends State<EmptyLawyerState>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _bounceCtrl;

  late Animation<double> _float;
  late Animation<double> _fade;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();

    // float up down
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // fade in on appear
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    // bounce on entry
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _float = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
    );

    _bounce = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.bounceOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _fadeCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // image with float + bounce
            ScaleTransition(
              scale: _bounce,
              child: AnimatedBuilder(
                animation: _float,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _float.value),
                  child: child,
                ),
                child: Image.asset(
                  'assets/images/nothing_found1.png',
                  width: 180.w,
                  height: 180.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // bounce on text too
            ScaleTransition(
              scale: _bounce,
              child: Column(
                children: [
                  Text(
                    'No ${widget.category} lawyers',
                    style: AppStyle.style16w400(
                        color: AppColors.darkContrast),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Check back later or try another category',
                    style: AppStyle.style12w600(
                        color: AppColors.liteGery),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}