import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class RoleBox extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const RoleBox({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150.w,
        height: 140.h,
        margin: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: AppStyle.style26w600(),
          ),
        ),
      ),
    );
  }
}