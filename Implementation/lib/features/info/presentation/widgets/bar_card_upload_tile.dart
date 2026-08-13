import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class BarCardUploadTile extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const BarCardUploadTile({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8,),
      child: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.whiteColor
        ),
        child: Row(
          children: [
            const Icon(Icons.upload_file),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                imagePath == null
                    ? "Upload Bar Card (PNG / JPG)"
                    : "Bar Card Selected",
                style: AppStyle.style14w400(),
              ),
            ),
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(imagePath!),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
