import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import '../../../../data/ai_chat/models/lawyer_match.dart';
import '../../lawyerDetail/lawyer_detail_screen.dart';

class LawyerCardBubble extends StatelessWidget {
  final List<LawyerMatch> lawyers;

  const LawyerCardBubble({super.key, required this.lawyers});

  @override
  Widget build(BuildContext context) {
    final medals = ['Best Match', '2nd Match', '3rd Match'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lawyers.length, (index) {
        final lawyer = lawyers[index];
        final initials = lawyer.name
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join();
        final medal = index < medals.length ? medals[index] : 'Match';

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI avatar
              Container(
                width: 30.w,
                height: 30.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 14.r,
                ),
              ),
              SizedBox(width: 8.w),

              // Card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkContrast.withValues(alpha: 0.08),
                        blurRadius: 4.r,
                        offset: Offset(0, 1.h),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(14.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medal label
                      Text(
                        medal,
                        style: AppStyle.style10w500(color: AppColors.borderColor).copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Lawyer info row
                      Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                            ),
                            child: lawyer.avatarUrl.isNotEmpty
                                ? ClipOval(
                              child: Image.network(
                                lawyer.avatarUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Center(
                              child: Text(
                                initials,
                                style: AppStyle.style12w600(color: Colors.white).copyWith(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lawyer.name,
                                  style: AppStyle.style14w400(color: AppColors.darkContrast).copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  lawyer.location,
                                  style: AppStyle.style12w400(color: AppColors.borderColor),
                                ),
                              ],
                            ),
                          ),
                          // Availability dot
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: lawyer.isAvailable
                                  ? AppColors.liteGreen
                                  : AppColors.lightGrey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6.h, horizontal: 8.w),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${lawyer.experienceYears} yrs',
                                    style: AppStyle.style12w600(color: AppColors.darkContrast).copyWith(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Experience',
                                    style: AppStyle.style10w500(color: AppColors.borderColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6.h, horizontal: 8.w),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${lawyer.casesWon}',
                                    style: AppStyle.style12w600(color: AppColors.darkContrast).copyWith(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Cases Won',
                                    style: AppStyle.style10w500(color: AppColors.borderColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // View Profile button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LawyerDetailScreen(
                                lawyerData: lawyer.rawData, // 👈 full data
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Text(
                              'View Profile',
                              style: AppStyle.style12w600(color: AppColors.whiteColor).copyWith(
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}