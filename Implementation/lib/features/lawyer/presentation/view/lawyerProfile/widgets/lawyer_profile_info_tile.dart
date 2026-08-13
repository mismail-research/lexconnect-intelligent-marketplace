import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class LawyerInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isLocked;
  final String? errorText;
  final VoidCallback? onTap;

  const LawyerInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.errorText,
    this.isLocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isLocked
              ? AppColors.lightGrey.withAlpha(102)
              : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.liteGery.withValues(
                alpha: isLocked ? 0.04 : 0.08,
              ),
              blurRadius: 4.r,
              offset: Offset(0, 1.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: AppStyle.style12w400(
                          color: isLocked
                              ? AppColors.lightGrey.withAlpha(102)
                              : AppColors.lightGrey,
                        ),
                      ),
                      if (isLocked) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'LOCKED',
                            style: AppStyle.style10w500(
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    value,
                    style: AppStyle.style14w400(
                      color: isLocked
                          ? AppColors.lightGrey.withAlpha(102)
                          : AppColors.textPrimary,
                    ),
                  ),

                  // 🔥 ERROR TEXT
                  if (errorText != null && errorText!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      errorText!,
                      style: AppStyle.style12w600(
                        color: AppColors.redColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isLocked ? Icons.lock_outline : Icons.edit_outlined,
              color: isLocked
                  ? AppColors.lightGrey.withAlpha(102)
                  : AppColors.lightGrey,
              size: 17.sp,
            ),
          ],
        ),
      ),
    );
  }
}