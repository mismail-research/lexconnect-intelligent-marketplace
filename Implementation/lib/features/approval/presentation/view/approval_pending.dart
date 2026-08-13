import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/features/approval/domain/entities/approval_entity.dart';
import 'package:lexbid/features/approval/presentation/bloc/approval_bloc.dart';
import 'package:lexbid/features/approval/presentation/bloc/approval_state.dart';
import 'package:lexbid/routes.dart';
import 'package:lexbid/widgets/sand_timer.dart';

class ApprovalPendingPage extends StatefulWidget {
  const ApprovalPendingPage({super.key});

  @override
  State<ApprovalPendingPage> createState() => _ApprovalPendingPageState();
}

class _ApprovalPendingPageState extends State<ApprovalPendingPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Duration _calculateRemaining(DateTime submittedAt) {
    final endTime = submittedAt.add(const Duration(hours: 24));
    final diff = endTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApprovalBloc, ApprovalState>(
      listener: (context, state) {
        if (state.status == ApprovalStatus.approved) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteGenerator.lawyerBottomNavRoute,
                (_) => false,
          );
        } else if (state.status == ApprovalStatus.rejected) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteGenerator.approvalRejected,
                (_) => false,
          );
        }
      },
      child: BlocBuilder<ApprovalBloc, ApprovalState>(
        builder: (context, state) {
          // 🔥 Safety check
          if (state.submittedAt == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final remaining = _calculateRemaining(state.submittedAt!);

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔥 Replaced Icon(Icons.hourglass_top) with SandTimer from secondary file
                    SandTimer(size: 150.r),

                    SizedBox(height: 20.h),
                    Text(
                      "Verification in Progress",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkContrast,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Please wait while we review your details",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.darkContrast.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkContrast.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _format(remaining),
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkContrast,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}