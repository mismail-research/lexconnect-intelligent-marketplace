import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'shimmer_box.dart';

class AppointmentCardSkeleton extends StatelessWidget {
  const AppointmentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 63.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Avatar circle
          ShimmerBox(
            width: 44.sp,
            height: 44.sp,
            isCircle: true,
          ),

          SizedBox(width: 10.w),

          // Name + type lines
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 100.w, height: 11.h, radius: 5),
              SizedBox(height: 6.h),
              ShimmerBox(width: 70.w, height: 10.h, radius: 5),
            ],
          ),

          const Spacer(),

          // Date + day lines
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 55.w, height: 11.h, radius: 5),
              SizedBox(height: 6.h),
              ShimmerBox(width: 40.w, height: 10.h, radius: 5),
            ],
          ),
        ],
      ),
    );
  }
}