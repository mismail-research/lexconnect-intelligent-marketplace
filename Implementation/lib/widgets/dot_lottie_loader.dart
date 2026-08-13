import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
// Don't forget to import your app colors for the fallback indicator
import 'package:lexbid/core/constants/app_color.dart';

class DotLottieLoader extends StatelessWidget {
  final double size;

  const DotLottieLoader({
    super.key,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic scaling applied to the size parameter
    final double scaledSize = size.r;

    return SizedBox(
      width: scaledSize,
      height: scaledSize,
      child: Lottie.asset(
        'assets/animations/loading_animation_3_dots.json', // The updated .json path
        fit: BoxFit.contain,
        // The errorBuilder prevents the red screen of death
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.liteBlue, // Fits your existing design system
              strokeWidth: 2.w,
            ),
          );
        },
      ),
    );
  }
}