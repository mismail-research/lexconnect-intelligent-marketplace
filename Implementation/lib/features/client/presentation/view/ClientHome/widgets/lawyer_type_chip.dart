import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class LawyerTypeChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final int animationIndex;

  const LawyerTypeChip({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (animationIndex * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(-20 * (1 - value), 0),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 130.w,
          height: 42.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? AppColors.buttonGradient1 // ✅ selected
                  : AppColors.buttonGradient,  // ✅ unselected
            ),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.borderColor.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppStyle.style14w400(
              color: AppColors.whiteColor,
            ).copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}