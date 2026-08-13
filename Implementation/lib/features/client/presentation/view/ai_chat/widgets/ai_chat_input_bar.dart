import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';

class AIChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;

  const AIChatInputBar({
    super.key,
    required this.controller,
    required this.hasText,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
      color: AppColors.backgroundColor,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 46.h,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: AppColors.liteBlue.withValues(alpha: 0.35),
                    width: 1.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.liteBlue.withValues(alpha: 0.06),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(width: 16.w),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.darkContrast,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: AppColors.borderColor.withValues(alpha: 0.5),
                            fontSize: 13.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                        ),
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: onSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46.w,
                height: 46.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasText ? AppColors.primaryGradient : null,
                  color: hasText
                      ? null
                      : AppColors.borderColor.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: hasText ? AppColors.whiteColor : AppColors.borderColor,
                  size: 20.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}