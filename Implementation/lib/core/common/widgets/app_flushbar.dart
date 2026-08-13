import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class AppFlushBar {
  static void showError(BuildContext context, {required String message}) {
    Flushbar(
      messageText: Text(
        message,
        style: AppStyle.style14w400(color: AppColors.redColor),
      ),
      backgroundColor: AppColors.backgroundColor,
      icon: Icon(Icons.error_outline, color: AppColors.redColor, size: 24.r),
      duration: const Duration(seconds: 3),
      margin: EdgeInsets.all(16.r),
      borderRadius: BorderRadius.circular(12.r),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  static void showSuccess(BuildContext context, {required String message}) {
    Flushbar(
      messageText: Text(
        message,
        style: AppStyle.style14w400(color: AppColors.darkGreen),
      ),
      backgroundColor: AppColors.successBackground,
      icon: Icon(
        Icons.check_circle_outline,
        color: AppColors.liteGreen,
        size: 24.r,
      ),
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.r),
      borderRadius: BorderRadius.circular(12.r),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }
}