import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lexbid/core/common/widgets/app_flushbar.dart';
import 'package:lexbid/core/common/widgets/confirmation_dialog.dart';
import 'package:lexbid/core/common/widgets/custom_botton.dart'; // Fixed typo if needed, or keeping your exact import
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_bloc.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_event.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_state.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyer_bottomNavBar.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const AppointmentDetailScreen({super.key, required this.appointmentData});

  @override
  Widget build(BuildContext context) {
    final status = appointmentData['status'] ?? 'pending';
    final appointmentId = appointmentData['appointmentId'];

    // 🔥 Capture a reference to the Bloc BEFORE async dialog pops clean out of context tree
    final appointmentsBloc = context.read<LawyerAppointmentsBloc>();

    // Helper to define dynamic status colors
    Color getStatusColor(String currentStatus) {
      switch (currentStatus) {
        case 'accepted':
          return AppColors.liteGreen;
        case 'completed':
          return AppColors.purpleColor; // Or any specific color you prefer for completed status
        case 'rejected':
          return AppColors.redColor;
        case 'cancelled':
          return AppColors.amberColor;

        default:
          return AppColors.liteBlue;
      }
    }

    return BlocListener<LawyerAppointmentsBloc, LawyerAppointmentsState>(
      listener: (context, state) {
        if (state is AppointmentStatusUpdated) {

          AppFlushBar.showSuccess(
            context,
            message: "Appointment ${state.status}",
          );

          // ✅ NEW: after any status action, go straight to Lawyer Home
          // (bottom nav, first tab) instead of just popping this screen.
          // pushAndRemoveUntil clears the whole stack above/including the
          // list screen so the back button won't return here.
          Future.delayed(const Duration(milliseconds: 1800), () {
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LawyerBottomNavView(),
                ),
                    (route) => false,
              );
            }
          });
        }

        if (state is LawyerAppointmentsError) {
          AppFlushBar.showError(
            context,
            message: state.message,
          );
        }

      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text("Appointment Detail", style: AppStyle.style18w600()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.blackColor,
        ),
        body: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailSection("Client Name", appointmentData['clientName']),
              _buildDetailSection("Consultancy Type", appointmentData['consultationType']),
              _buildDetailSection("Date", appointmentData['date']),
              _buildDetailSection("Time", appointmentData['time']),
              _buildDetailSection(
                "Current Status",
                status.toString().toUpperCase(),
                color: getStatusColor(status),
              ),

              const Spacer(),

              /// ⏳ PENDING STATUS BUTTONS
              if (status == 'pending') ...[
                CustomButton(
                  text: "Accept Appointment",
                  width: double.infinity,
                  height: 55.h,
                  gradientColors: [AppColors.liteGreen, AppColors.darkGreen],
                  onTap: () async {
                    final confirm = await ConfirmationDialog.show(
                      context: context,
                      title: "Accept Request",
                      message: "Your WhatsApp number will be shown to the client for more conversation.",
                      confirmText: "Accept",
                      confirmColor: AppColors.liteGreen,
                    );

                    if (confirm == true && context.mounted) {
                      appointmentsBloc.add(
                        UpdateAppointmentStatus(
                          appointmentId: appointmentId,
                          newStatus: 'accepted',
                        ),
                      );

                    }
                  },
                ),
                const Gap(15),
                CustomButton(
                  text: "Reject Appointment",
                  width: double.infinity,
                  height: 55.h,
                  gradientColors: [AppColors.redColor, AppColors.redColor.withValues(alpha: 0.09)],
                  onTap: () async {
                    final confirm = await ConfirmationDialog.show(
                      context: context,
                      title: "Reject Request",
                      message: "Are you sure you want to reject this appointment?",
                      confirmText: "Reject",
                    );

                    if (confirm == true && context.mounted) {
                      appointmentsBloc.add(
                        UpdateAppointmentStatus(
                          appointmentId: appointmentId,
                          newStatus: 'rejected',
                        ),
                      );
                    }
                  },
                ),
              ],

              /// ✅ ACCEPTED STATUS BUTTON (CASE COMPLETION)
              if (status == 'accepted') ...[
                CustomButton(
                  text: "Complete Case",
                  width: double.infinity,
                  height: 55.h,
                  gradientColors: [AppColors.liteBlue, AppColors.liteBlue.withValues(alpha: 0.09)], // You can change this color theme if needed
                  onTap: () async {
                    final confirm = await ConfirmationDialog.show(
                      context: context,
                      title: "Complete Case",
                      message: "Are you sure this case is complete? Once confirmed, the client will be able to leave a rating and review for your profile.",
                      confirmText: "Confirm",
                      confirmColor: AppColors.liteGreen,
                    );

                    if (confirm == true && context.mounted) {
                      // Dispatch status update to 'completed'
                      appointmentsBloc.add(
                        UpdateAppointmentStatus(
                          appointmentId: appointmentId,
                          newStatus: 'completed',
                        ),
                      );

                    }
                  },
                ),
              ],

              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppStyle.style14w400(color: AppColors.liteGery)),
          const Gap(5),
          Text(value, style: AppStyle.style18w600(color: color ?? AppColors.blackColor)),
          const Divider(),
        ],
      ),
    );
  }
}