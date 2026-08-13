import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import '../../../../bloc/ai_chat/ai_chat_bloc.dart';
import '../../../../bloc/ai_chat/ai_chat_event.dart';

class AIChatInfoSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: AppColors.whiteColor,
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'LexBid AI Chat',
                  style: TextStyle(
                    color: AppColors.darkContrast,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.borderColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16.r,
                    color: AppColors.borderColor.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Your conversation is stored for 24 hours from your first message. After that it is permanently deleted and a fresh session begins automatically.',
                      style: TextStyle(
                        color: AppColors.liteGery,
                        fontSize: 13.sp,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(context);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.redColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.redColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.redColor,
                      size: 18.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Delete conversation',
                      style: TextStyle(
                        color: AppColors.redColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Text(
          'Delete conversation?',
          style: TextStyle(
            color: AppColors.darkContrast,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will permanently delete your current chat session. This action cannot be undone.',
          style: TextStyle(
            color: AppColors.liteGery,
            fontSize: 13.sp,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.liteGery,
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AIChatBloc>().add(DeleteConversation());
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.redColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}