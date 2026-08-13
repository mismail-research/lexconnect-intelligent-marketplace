import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final double width;
  final double height;
  final List<Color> gradientColors;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final Widget? child;

  const CustomButton({
    super.key,
    this.text,
    required this.width,
    required this.height,
    required this.gradientColors,
    this.textStyle,
    this.onTap,
    this.child,
  }) : assert(
  text != null || child != null,
  'Either text or child must be provided.',
  );

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    // 🔥 Fixed: Used withValues(alpha: ...) to resolve deprecation warning
    final List<Color> effectiveColors = isDisabled
        ? gradientColors.map((color) => color.withValues(alpha: 0.6)).toList()
        : gradientColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: effectiveColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child:
        child ??
            Text(
              text!,
              // 🔥 Added responsive fallback configurations via .sp formatters
              style:
              textStyle ??
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
            ),
      ),
    );
  }
}