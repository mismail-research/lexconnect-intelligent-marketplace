import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/core/utils/text_utils.dart';
import 'package:lexbid/features/client/data/bookAppointment/models/appointment_models.dart';

class LawyerInfoCard extends StatelessWidget {
  final Lawyer lawyer;

  const LawyerInfoCard({super.key, required this.lawyer});

  @override
  Widget build(BuildContext context) {
    final String displayName = lawyer.name.length > 12
        ? "${TextUtils.limitText(lawyer.name, maxLength: 12)}.."
        : lawyer.name;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: 5.w),
          SizedBox(
            height: 75.h,
            width: 70.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: _buildImage(lawyer.imageUrl),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: AppStyle.style18w600(),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.liteGery,
                    size: 14.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    lawyer.location,
                    style: AppStyle.style12w400(),
                  ),
                ],
              ),
              Text(
                '${lawyer.specialization} Lawyer',
                style: AppStyle.style12w400(
                  color: AppColors.liteGreen,
                ),
              ),
            ],
          ),
          SizedBox(width: 20.w)
        ],
      ),
    );
  }

  Widget _buildImage(String? path) {
    /// NULL OR EMPTY
    if (path == null || path.trim().isEmpty) {
      return Image.asset(
        AppAssets.defaultLawyerImage,
        fit: BoxFit.cover,
      );
    }

    /// FIREBASE / NETWORK IMAGE
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            AppAssets.defaultLawyerImage,
            fit: BoxFit.cover,
          );
        },
      );
    }

    /// LOCAL ASSET IMAGE
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          AppAssets.defaultLawyerImage,
          fit: BoxFit.cover,
        );
      },
    );
  }
}