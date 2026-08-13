import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';

class DetailAppointmentCardSkeleton extends StatefulWidget {
  const DetailAppointmentCardSkeleton({super.key});

  @override
  State<DetailAppointmentCardSkeleton> createState() =>
      _DetailAppointmentCardSkeletonState();
}

class _DetailAppointmentCardSkeletonState
    extends State<DetailAppointmentCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 8,
    bool isCircle = false,
  }) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_anim.value - 0.4).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.4).clamp(0.0, 1.0),
            ],
            colors: [
              AppColors.backgroundColor,
              AppColors.whiteColor.withValues(alpha: 0.8),
              AppColors.backgroundColor,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.02)),
      ),
      child: Row(
        children: [
          // Avatar
          _box(width: 50.sp, height: 50.sp, isCircle: true),
          SizedBox(width: 12.w),

          // Name + type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 120.w, height: 14.h, radius: 5),
                SizedBox(height: 8.h),
                _box(width: 80.w, height: 11.h, radius: 5),
              ],
            ),
          ),

          // Status icon + text
          Column(
            children: [
              _box(width: 24.sp, height: 24.sp, isCircle: true),
              SizedBox(height: 6.h),
              _box(width: 50.w, height: 10.h, radius: 4),
            ],
          ),
        ],
      ),
    );
  }
}