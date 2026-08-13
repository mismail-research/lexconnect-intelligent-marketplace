import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerHome/lawyer_home_bloc.dart';
import 'skeletons/quick_stats_skeleton.dart';

class LawyerQuickStatsWidget extends StatelessWidget {
  const LawyerQuickStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LawyerHomeBloc, LawyerHomeState>(
      builder: (context, state) {

        /// Loading State → Skeleton
        if (state is LawyerHomeLoading) {
          return const QuickStatsSkeleton();
        }

        /// Original Logic
        if (state is! LawyerHomeLoaded) {
          return const SizedBox();
        }

        return Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.buttonGradient,
            ),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              /// PIE CHART
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 180.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 45.r,
                          sections: [
                            PieChartSectionData(
                              color: AppColors.liteGreen,
                              value: state.activeClientsPercentage,
                              title: '',
                              radius: 25.r,
                            ),
                            PieChartSectionData(
                              color: AppColors.liteBlue,
                              value: state.pendingCasePercentage,
                              title: '',
                              radius: 25.r,
                            ),
                            PieChartSectionData(
                              color: AppColors.redColor,
                              value: state.appointmentTodayPercentage,
                              title: '',
                              radius: 25.r,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Progress",
                        style: AppStyle.style16w400(
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// LEGEND
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legend(
                        AppColors.liteGreen,
                        "${state.activeClientsPercentage.toInt()}% Accepted",
                      ),
                      SizedBox(height: 8.h),
                      _legend(
                        AppColors.liteBlue,
                        "${state.pendingCasePercentage.toInt()}% Pending",
                      ),
                      SizedBox(height: 8.h),
                      _legend(
                        AppColors.redColor,
                        "${state.appointmentTodayPercentage.toInt()}% Rejected",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppStyle.style14w400(
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ],
    );
  }
}