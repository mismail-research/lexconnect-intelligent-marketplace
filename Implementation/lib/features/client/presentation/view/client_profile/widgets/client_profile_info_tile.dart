import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const ProfileInfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGrey.withValues(alpha: 0.2),
              blurRadius: 4,
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
                  Text(
                    label.toUpperCase(),
                    style: AppStyle.style12w600(color: AppColors.lightGrey).copyWith(
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    value,
                    style: AppStyle.style15w500(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              color: AppColors.lightGrey,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}