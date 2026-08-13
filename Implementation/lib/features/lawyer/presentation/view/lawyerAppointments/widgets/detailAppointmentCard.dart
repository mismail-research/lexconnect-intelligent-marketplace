import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_bloc.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_event.dart';
import 'package:lexbid/routes.dart';

class DetailAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> fullData;
  final bool isHighlighted;

  const DetailAppointmentCard({
    super.key,
    required this.fullData,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final String name = fullData['clientName'] ?? "Unknown";
    final String consultancyType = fullData['consultationType'] ?? "N/A";
    final String status = fullData['status'] ?? "pending";
    final String? imageUrl = fullData['imageUrl'];

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'accepted':
        statusColor = AppColors.liteGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppColors.redColor;
        statusIcon = Icons.cancel;
        break;
      case 'completed':
        statusColor = AppColors.purpleColor;
        statusIcon = Icons.done_outline;
        break;
      case 'cancelled':
        statusColor = AppColors.amberColor;
        statusIcon = Icons.cancel_schedule_send_outlined;
        break;
      default:
        statusColor = AppColors.liteBlue;
        statusIcon = Icons.abc_rounded;
        break;
    }

    return GestureDetector(
      onTap: () {
        context.read<LawyerAppointmentsBloc>().add(
          MarkLawyerAppointmentSeenEvent(
            fullData['appointmentId'],
          ),
        );
        Navigator.pushNamed(
          context,
          RouteGenerator.appointmentDetail,
          arguments: fullData,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.liteBlue.withValues(alpha: 0.15)
              : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isHighlighted ? AppColors.liteBlue : AppColors.lightGrey.withValues(alpha: 0.02),
            width: isHighlighted ? 1.5 : 1.0,
          ),
          boxShadow: isHighlighted
              ? [
            BoxShadow(
              color: AppColors.liteBlue.withValues(alpha: 0.3),
              blurRadius: 8.r,
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            /// PROFILE IMAGE
            ClipOval(
              child: SizedBox(
                height: 50.sp,
                width: 50.sp,
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.person),
                )
                    : Image.asset(
                  AppAssets.defaultLawyerImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            /// TEXT INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppStyle.style18w600()),
                  Text(
                    consultancyType,
                    style: AppStyle.style14w400(color: AppColors.liteGery),
                  ),
                ],
              ),
            ),

            /// STATUS
            Column(
              children: [
                Icon(statusIcon, color: statusColor, size: 24.sp),
                SizedBox(height: 4.h),
                Text(
                  status.toUpperCase(),
                  style: AppStyle.style12w600(color: statusColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}