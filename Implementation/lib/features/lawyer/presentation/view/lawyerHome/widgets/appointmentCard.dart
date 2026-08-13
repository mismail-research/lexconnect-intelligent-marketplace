
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class AppointmentCard extends StatelessWidget {
  final String name;
  final String consultancyType;
  final String date;
  final String day;
  final String? imageUrl;

  const AppointmentCard({
    super.key,
    required this.name,
    required this.consultancyType,
    required this.date,
    required this.day,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 63.h,
      width: 361.w,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [

          /// PROFILE IMAGE
          ClipOval(
            child: SizedBox(
              height: 50.sp,
              width: 50.sp,
              child: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) =>
                const Icon(Icons.person),
              )
                  : Image.asset(
                AppAssets.defaultLawyerImage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 10.w),

          /// NAME + TYPE
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppStyle.style12w400(
                  color: AppColors.liteGreen,
                ),
              ),
              Text(
                consultancyType,
                style: AppStyle.style12w400(
                ),
              ),
            ],
          ),

          const Spacer(),

          /// DATE + DAY
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: AppStyle.style12w400(
                  color: AppColors.liteGreen,
                ),
              ),
              Text(
                day,
                style: AppStyle.style12w400(
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}