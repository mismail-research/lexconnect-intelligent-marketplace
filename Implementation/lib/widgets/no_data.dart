import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import screenutil
import 'package:lottie/lottie.dart';
import 'package:lexbid/core/constants/app_color.dart';

class EmptyAppointments extends StatelessWidget {
  final double size;

  const EmptyAppointments({
    super.key,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic scaling applied to the size parameter
    final double scaledSize = size.r;

    return SizedBox(
      width: scaledSize,
      height: scaledSize,
      child: Lottie.asset(
        'assets/animations/no_data.json',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to circular indicator if the JSON fails to load
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.liteBlue,
              strokeWidth: 2.w, // Apply scaling to strokeWidth
            ),
          );
        },
      ),
    );
  }
}