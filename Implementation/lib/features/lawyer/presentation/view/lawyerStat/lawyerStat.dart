import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/core/utils/app_padding.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerStat/lawyer_stat_bloc.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerStat/lawyer_stat_event.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerStat/lawyer_stat_state.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerHome/widgets/appointmentCard.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerHome/widgets/skeletons/apointment_card_skeleton.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerStat/widgets/chartStatsRow.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerStat/widgets/lawyerProgressChart.dart';

class LawyerStat extends StatefulWidget {
  const LawyerStat({super.key});

  @override
  State<LawyerStat> createState() => _LawyerStatState();
}

class _LawyerStatState extends State<LawyerStat> {
  @override
  void initState() {
    super.initState();
    context.read<LawyerStatBloc>().add(
      LoadAcceptedAppointments(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppPadding.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Quick Stats',
                    style: AppStyle.style24w900(),
                  ),
                ),

                Gap(20.h),

                Text(
                  'Booked Appointment',
                  style: AppStyle.style20w900(),
                ),

                Gap(10.h),

                SizedBox(
                  height: 150.h,
                  child: BlocBuilder<LawyerStatBloc, LawyerStatState>(
                    builder: (context, state) {
                      if (state is LawyerStatLoading) {
                        return ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          separatorBuilder: (_, child) => Gap(10.h),
                          itemBuilder: (_, child) => const AppointmentCardSkeleton(),
                        );
                      }

                      if (state is LawyerStatError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: AppColors.redColor,
                            ),
                          ),
                        );
                      }

                      if (state is LawyerStatLoaded) {
                        if (state.acceptedAppointments.isEmpty) {
                          return const Center(
                            child: Text("No appointments"),
                          );
                        }

                        return ListView.builder(
                          itemCount: state.acceptedAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = state.acceptedAppointments[index];

                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: AppointmentCard(
                                name: appointment.clientName,
                                consultancyType: appointment.consultancyType,
                                date: appointment.date,
                                day: appointment.day,
                                imageUrl: appointment.imageUrl,
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),

                Gap(20.h),

                Text(
                  'Metrics',
                  style: AppStyle.style20w900(),
                ),

                Gap(10.h),

                BlocBuilder<LawyerStatBloc, LawyerStatState>(
                  builder: (context, state) {
                    if (state is LawyerStatLoading) {
                      return _ChartSkeleton();
                    }

                    if (state is LawyerStatLoaded) {
                      return Column(
                        children: [
                          LawyerProgressChart(
                            monthlyStats: state.monthlyStats,
                          ),

                          Gap(20.h),

                          ChartStatsRow(
                            monthlyStats: state.monthlyStats,
                          ),
                        ],
                      );
                    }

                    if (state is LawyerStatError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: AppColors.redColor,
                          ),
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),

                Gap(20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CHART SKELETON
class _ChartSkeleton extends StatefulWidget {
  @override
  State<_ChartSkeleton> createState() => _ChartSkeletonState();
}

class _ChartSkeletonState extends State<_ChartSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();

    _anim = Tween<double>(
      begin: -1.5,
      end: 2.0,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _shimmer({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_anim.value - 0.4).clamp(0.0, 1.0),
                _anim.value.clamp(0.0, 1.0),
                (_anim.value + 0.4).clamp(0.0, 1.0),
              ],
              colors: [
                AppColors.backgroundColor,
                AppColors.whiteColor.withValues(alpha: 0.8),
                AppColors.backgroundColor,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _shimmer(
          width: double.infinity,
          height: 230.h,
          radius: 20.r,
        ),

        Gap(20.h),

        Row(
          children: List.generate(
            3,
                (index) => Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: _shimmer(
                  width: double.infinity,
                  height: 60.h,
                  radius: 12.r,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}