import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/features/client/data/bookAppointment/models/appointment_models.dart';

class ConsultationTypeCard extends StatelessWidget {
  final ConsultationType type;
  final bool isSelected;
  final VoidCallback onTap;

  const ConsultationTypeCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F3FF) : AppColors.whiteColor,
          border: Border.all(
            color: isSelected ? AppColors.borderColor : Colors.transparent,
            width: 2.w,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.lightGrey.withAlpha(20),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _getIcon(type.iconPath),
                color: isSelected ? AppColors.whiteColor : AppColors.darkContrast,
                size: 22.r, // Scaled for design consistency
              ),
            ),

            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.title, style: AppStyle.style16w800()),
                  Text(
                    type.subtitle,
                    style: AppStyle.style12w600(color: AppColors.lightGrey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.black,
                size: 20.r,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String? path) {
    switch (path) {
      case 'video':
        return Icons.videocam_rounded;
      case 'office':
        return Icons.business_rounded;
      case 'location':
        return Icons.location_on_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}