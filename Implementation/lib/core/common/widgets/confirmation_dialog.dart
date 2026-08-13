import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class ConfirmationDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    Color confirmColor = AppColors.redColor,
    bool barrierDismissible = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          title: Text(title, style: AppStyle.style18w600()),
          content: Text(
            message,
            style: AppStyle.style14w400(color: AppColors.liteGery),
          ),
          actions: [
            /// ❌ CANCEL (DEFAULT + HIGHLIGHTED)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.liteBlue,
                foregroundColor: AppColors.whiteColor,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),

            /// ✅ CONFIRM
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: confirmColor,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }
}