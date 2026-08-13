import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';

class LawyerProfileSkeleton extends StatefulWidget {
  const LawyerProfileSkeleton({super.key});

  @override
  State<LawyerProfileSkeleton> createState() => _LawyerProfileSkeletonState();
}

class _LawyerProfileSkeletonState extends State<LawyerProfileSkeleton>
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
    double radius = 10,
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

  Widget _tile() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.liteGery.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 80.w, height: 10.h, radius: 5),
                SizedBox(height: 8.h),
                _box(width: 160.w, height: 13.h, radius: 5),
              ],
            ),
          ),
          _box(width: 17.w, height: 17.w, isCircle: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 16.h),

          // Avatar circle
          _box(width: 90.w, height: 90.w, isCircle: true),
          SizedBox(height: 10.h),

          // Lawyer type tag
          _box(width: 80.w, height: 12.h, radius: 6),
          SizedBox(height: 6.h),

          // Email
          _box(width: 160.w, height: 12.h, radius: 6),
          SizedBox(height: 20.h),

          // Info tiles
          _tile(),
          SizedBox(height: 12.h),

          // Availability card
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.liteGery.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(width: 90.w, height: 10.h, radius: 5),
                      SizedBox(height: 8.h),
                      _box(width: 140.w, height: 13.h, radius: 5),
                    ],
                  ),
                ),
                _box(width: 44.w, height: 26.h, radius: 13),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          _tile(),
          SizedBox(height: 12.h),
          _tile(),
          SizedBox(height: 12.h),
          _tile(),
          SizedBox(height: 12.h),
          _tile(),
          SizedBox(height: 22.h),

          // Save button
          _box(width: double.infinity, height: 54.h, radius: 12),
          SizedBox(height: 12.h),

          // Logout button
          _box(width: double.infinity, height: 54.h, radius: 12),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }
}