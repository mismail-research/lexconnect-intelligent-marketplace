import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class CustomTextField extends StatelessWidget {
  final double width;
  final double height;
  final IconData? icon;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool hasError;
  final Color? borderColor;

  /// ✅ OPTIONAL
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.width,
    required this.height,
    this.icon,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.hasError = false,
    this.borderColor,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 7.h),
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          controller: controller,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          obscureText: obscureText,
          style: AppStyle.style16w400(),

          /// ✅ HERE
          inputFormatters: inputFormatters,

          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.whiteColor,

            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.liteGery, size: 22.r)
                : null,

            suffixIcon: suffixIcon,

            labelText: labelText,
            labelStyle: AppStyle.style16w400(color: AppColors.liteGery),
            hintText: hintText,
            hintStyle: AppStyle.style16w400(color: AppColors.liteGery),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor ?? Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.liteBlue,
                width: 1.5.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}