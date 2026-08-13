import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_strings.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class LawyerStatsRow extends StatelessWidget {
  final int cases;
  final String experience;
  final double rating;

  const LawyerStatsRow({
    super.key,
    required this.cases,
    required this.experience,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Even spacing
      children: [
        _buildStatCircle("$cases", AppStrings.caseWon),
        _buildStatCircle(experience.replaceAll(" Years", "+"), AppStrings.experience),
        _buildStatCircle(rating.toString(), "Ratings"),
      ],
    );
  }

  Widget _buildStatCircle(String value, String label) {
    return Column(
      children: [
        Container(
          width: 60.w, height: 60.h,
          alignment: Alignment.center,
          decoration:  BoxDecoration(
            shape: BoxShape.circle,
            // Using your dark gradient
            gradient: LinearGradient(
              colors: AppColors.buttonGradient1,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(
                color: AppColors.blackColor,
                blurRadius: 8.r, offset: Offset(0, 4))],
          ),
          child: Text(
            value,
            style:  AppStyle.style16w400(color: AppColors.whiteColor),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: AppStyle.style12w600(),
        )
      ],
    );
  }
}