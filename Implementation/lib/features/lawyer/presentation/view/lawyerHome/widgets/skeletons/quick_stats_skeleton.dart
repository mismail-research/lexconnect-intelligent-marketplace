import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'shimmer_box.dart';

class QuickStatsSkeleton extends StatelessWidget {
  const QuickStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Pie chart placeholder — circle
          Expanded(
            flex: 3,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ShimmerBox(
                    width: 130.r,
                    height: 130.r,
                    isCircle: true,
                  ),
                  // Hole in the middle
                  Container(
                    width: 80.r,
                    height: 80.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Legend placeholders
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (i) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: i < 2 ? 14.h : 0),
                    child: Row(
                      children: [
                        ShimmerBox(
                          width: 14.w,
                          height: 14.w,
                          isCircle: true,
                        ),
                        SizedBox(width: 8.w),
                        ShimmerBox(
                          width: 90.w,
                          height: 12.h,
                          radius: 6,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}