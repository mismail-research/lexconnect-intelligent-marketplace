import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lexbid/core/common/widgets/custom_botton.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_strings.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/core/utils/app_padding.dart';
import 'package:lexbid/core/utils/text_utils.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_bloc.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_event.dart';
import 'package:lexbid/features/client/presentation/view/lawyerDetail/widget/lawyer_profile_image_card.dart';
import 'package:lexbid/features/client/presentation/view/lawyerDetail/widget/lawyer_stats_row.dart';
import 'package:lexbid/routes.dart';

class LawyerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> lawyerData;

  const LawyerDetailScreen({super.key, required this.lawyerData});

  @override
  Widget build(BuildContext context) {
    /// Extract firestore data safely
    final imageUrl = lawyerData["avatarUrl"];
    final bool isAvailable = lawyerData["isAvailable"] ?? false;
    final name = lawyerData["businessName"] ?? "Lawyer";
    final specialization = lawyerData["lawyerType"] ?? "Lawyer";
    final casesSolved = lawyerData["caseWon"] ?? 0;
    final experience = lawyerData["experience"] ?? "0";
    final qualification = lawyerData["qualification"] ?? "";
    final barCouncilNo = lawyerData["barCouncilNo"] ?? "";
    final officeLocation = lawyerData["officeLocation"];
    final double rating = (lawyerData["rating"] ?? 0).toDouble();

    final String availabilityText = isAvailable
        ? "is currently available"
        : "is currently not available with ongoing cases";
    final String displayName = name.length > 12
        ? "${TextUtils.limitText(name, maxLength: 12)}.."
        : name;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppPadding.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.darkContrast,
                          radius: 20.r, // Scaled radius for uniformity
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.whiteColor,
                              size: 18.sp,
                            ),
                            onPressed: () {
                              context.read<BottomNavBarBloc>().add(
                                ChangeClientTab(0),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 4.w), // Fixed layout component type error
                              child: Text(
                                displayName,
                                style: AppStyle.style16w400(),
                              ),
                            ),
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
                                  (officeLocation != null &&
                                      officeLocation
                                          .toString()
                                          .trim()
                                          .isNotEmpty)
                                      ? officeLocation
                                      : "Pakistan",
                                  style: AppStyle.style12w400(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                Gap(20.h),
                LawyerProfileImageCard(
                  imageUrl: imageUrl,
                  isAvailable: isAvailable,
                  specialization: specialization,
                ),

                Gap(30.h),
                Row(
                  children: [
                    Container(
                      height: 22.h,
                      width: 22.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.liteBlue,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 14.r,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "Lawyer is available",
                      style: AppStyle.style14w400(
                        color: isAvailable
                            ? AppColors.liteBlue
                            : AppColors.liteGery,
                      ),
                    ),
                  ],
                ),

                Gap(12.h),

                // Not Available Row
                Row(
                  children: [
                    Container(
                      height: 22.h,
                      width: 22.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.redColor,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14.r,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "Lawyer is currently busy",
                      style: AppStyle.style14w400(
                        color: !isAvailable
                            ? AppColors.redColor
                            : AppColors.liteGery,
                      ),
                    ),
                  ],
                ),
                Gap(20.h),

                /// Stats Row
                LawyerStatsRow(
                  cases: casesSolved,
                  experience: experience,
                  rating: rating,
                ),
                Gap(20.h),

                Text("About Lawyer", style: AppStyle.style17w900()),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10.h), // Fixed layout component type error
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.backgroundColor.withAlpha(30),
                    ),
                  ),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: AppStyle.style14w400(
                        color: AppColors.blackColor,
                      ).copyWith(height: 1.5),
                      children: [
                        TextSpan(
                          text:
                          "$displayName is a qualified $specialization lawyer with a $qualification degree. "
                              "With over $experience years of professional experience and a proven track record of "
                              "$casesSolved+ successfully solved cases, they have established a reputation for legal excellence. "
                              "Registered under Bar Council No. $barCouncilNo, $name ",
                        ),
                        TextSpan(
                          text: availabilityText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: isAvailable
                                ? AppColors.liteBlue
                                : AppColors.redColor,
                          ),
                        ),
                        const TextSpan(text: "."),
                      ],
                    ),
                  ),
                ),
                Gap(20.h),
                Center(
                  child: CustomButton(
                    text: AppStrings.bookAppointment,
                    width: 0.8.sw,
                    height: 55.h,
                    gradientColors: AppColors.buttonGradient1,
                    textStyle: AppStyle.style16w400(
                      color: AppColors.whiteColor,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteGenerator.bookAppointment,
                        arguments: {
                          'uid': lawyerData['uid'],
                          'name': displayName,
                          'avatarUrl': imageUrl ?? AppAssets.defaultLawyerImage,
                          'type': specialization,
                          'officeLocation': officeLocation,
                        },
                      );
                    },
                  ),
                ),
                Gap(40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}