import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';

class AIChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onInfoTap;

  const AIChatAppBar({super.key, required this.onInfoTap});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: AppColors.whiteColor,
              size: 20.r,
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LexBid AI',
                style: TextStyle(
                  color: AppColors.darkContrast,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 6.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.liteGreen,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: AppColors.borderColor.withValues(alpha: 0.8),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 14.w),
          child: _CircleBtn(
            onTap: onInfoTap,
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.darkContrast,
              size: 17.r,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _CircleBtn({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.whiteColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkContrast.withValues(alpha: 0.08),
              blurRadius: 6.r,
              offset: Offset(0, 1.h),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}