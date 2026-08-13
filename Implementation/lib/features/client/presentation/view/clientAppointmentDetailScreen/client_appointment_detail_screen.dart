import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lexbid/core/common/widgets/app_flushbar.dart';
import 'package:lexbid/core/common/widgets/confirmation_dialog.dart';
import 'package:lexbid/core/common/widgets/custom_botton.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/features/client/bloc/clientAppointmentDetailScreen/client_appointment_detail_screen_bloc.dart';
import 'package:lexbid/features/client/presentation/view/client_bottomNavBar.dart';

class ClientAppointmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;

  const ClientAppointmentDetailScreen({
    super.key,
    required this.appointmentData,
  });

  @override
  State<ClientAppointmentDetailScreen> createState() =>
      _ClientAppointmentDetailScreenState();
}

class _ClientAppointmentDetailScreenState
    extends State<ClientAppointmentDetailScreen> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>>
  _appointmentStream;

  @override
  void initState() {
    super.initState();
    final appointmentId = widget.appointmentData['appointmentId'];
    _appointmentStream = FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .snapshots();
  }

  String? _extractUidFromUrl(dynamic url) {
    if (url == null || url is! String || !url.contains('lawyers%2F')) {
      return null;
    }
    try {
      final parts = url.split('lawyers%2F');
      if (parts.length > 1) {
        return parts[1].split('%2F').first.split('/').first.split('?').first;
      }
    } catch (e) {
      debugPrint("Error parsing UID from image URL: $e");
    }
    return null;
  }

  // ✅ NEW: shared navigation used by both cancel-success and
  // rating-success, mirroring the lawyer side's "go home" behavior.
  void _goToClientHome() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const ClientBottomNavView(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentId = widget.appointmentData['appointmentId'];
    final fallbackLawyerUid = widget.appointmentData['lawyerUid'] ??
        _extractUidFromUrl(widget.appointmentData['imageUrl']);

    return BlocProvider(
      create: (_) => ClientAppointmentDetailScreenBloc(),
      child: BlocListener<ClientAppointmentDetailScreenBloc,
          ClientAppointmentDetailScreenState>(
        listener: (context, state) {
          if (state is ClientAppointmentActionSuccess) {
            AppFlushBar.showSuccess(
              context,
              message: "Appointment Cancelled Successfully",
            );

            // ✅ NEW: go to client home instead of just popping back
            Future.delayed(const Duration(milliseconds: 1800), () {
              _goToClientHome();
            });
          }

          if (state is ClientAppointmentActionError) {
            AppFlushBar.showError(
              context,
              message: state.message,
            );
          }

          if (state is RatingSubmissionSuccess) {
            AppFlushBar.showSuccess(
              context,
              message: "Thank you for your rating!",
            );

            // ✅ NEW: go to client home after a successful rating,
            // instead of leaving the client sitting on this screen.
            Future.delayed(const Duration(milliseconds: 1800), () {
              _goToClientHome();
            });
          }

          if (state is RatingSubmissionError) {
            AppFlushBar.showError(
              context,
              message: state.message,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Appointment Detail",
              style: AppStyle.style18w600(),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: AppColors.blackColor,
          ),
          body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _appointmentStream,
            builder: (context, snapshot) {
              // Merge live Firestore data over the data we navigated in
              // with, so the screen never relies on a stale snapshot.
              final liveData = snapshot.data?.data();
              final data = {
                ...widget.appointmentData,
                if (liveData != null) ...liveData,
              };

              final status = data['status'] ?? 'pending';
              final bool isRated = data['isRated'] ?? false;
              final lawyerUid = data['lawyerUid'] ?? fallbackLawyerUid;

              return Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      "Lawyer Name",
                      data['lawyerName'] ?? "Unknown",
                    ),

                    _buildDetailSection(
                      "Consultancy Type",
                      data['consultationType'] ?? "N/A",
                    ),

                    _buildDetailSection(
                      "Date",
                      data['date'] ?? "N/A",
                    ),

                    _buildDetailSection(
                      "Time",
                      data['time'] ?? "N/A",
                    ),

                    _buildDetailSection(
                      "Current Status",
                      status.toString().toUpperCase(),
                      color: status == 'accepted'
                          ? AppColors.liteGreen
                          : status == 'completed'
                          ? AppColors.purpleColor
                          : status == 'cancelled'
                          ? AppColors.amberColor
                          : status == 'rejected'
                          ? AppColors.redColor
                          : AppColors.liteBlue,
                    ),

                    if (status == 'accepted') ...[
                      _LawyerWhatsAppSection(lawyerUid: lawyerUid),
                    ],

                    const Spacer(),

                    if (status == 'pending') ...[
                      BlocBuilder<ClientAppointmentDetailScreenBloc,
                          ClientAppointmentDetailScreenState>(
                        buildWhen: (previous, current) =>
                        current is ClientAppointmentActionLoading ||
                            current is ClientAppointmentActionSuccess ||
                            current is ClientAppointmentActionError,
                        builder: (context, state) {
                          if (state is ClientAppointmentActionLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return CustomButton(
                            text: "Cancel Appointment",
                            width: double.infinity,
                            height: 55.h,
                            gradientColors: [
                              AppColors.redColor,
                              AppColors.redColor.withAlpha(60),
                            ],
                            onTap: () async {
                              final confirm = await ConfirmationDialog.show(
                                context: context,
                                title: "Cancel Appointment",
                                message:
                                "Are you sure you want to cancel this appointment?",
                                confirmText: "Confirm",
                              );

                              if (!context.mounted) return;
                              if (confirm == true) {
                                context
                                    .read<ClientAppointmentDetailScreenBloc>()
                                    .add(
                                  CancelAppointmentEvent(
                                    appointmentId: appointmentId,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],

                    // Rate button only shows when the appointment is
                    // completed AND the client hasn't rated yet. Both
                    // values now come straight from the live Firestore
                    // stream, so this stays correct even if the client
                    // navigated here with a stale cached map.
                    if (status == 'completed' && !isRated) ...[
                      BlocBuilder<ClientAppointmentDetailScreenBloc,
                          ClientAppointmentDetailScreenState>(
                        buildWhen: (previous, current) =>
                        current is RatingSubmissionLoading ||
                            current is RatingSubmissionSuccess ||
                            current is RatingSubmissionError,
                        builder: (context, state) {
                          if (state is RatingSubmissionLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          // If the bloc just succeeded, hide immediately
                          // even before the stream tick lands (and before
                          // navigation kicks in after the delay above).
                          if (state is RatingSubmissionSuccess) {
                            return const SizedBox.shrink();
                          }

                          return CustomButton(
                            text: "Rate Lawyer",
                            width: double.infinity,
                            height: 55.h,
                            gradientColors: [
                              AppColors.liteBlue,
                              AppColors.liteBlue.withAlpha(180),
                            ],
                            onTap: () {
                              if (lawyerUid == null || appointmentId == null) {
                                AppFlushBar.showError(
                                  context,
                                  message: "Missing valid core references.",
                                );
                                return;
                              }

                              _showRatingDialog(
                                context,
                                lawyerUid.toString(),
                                appointmentId.toString(),
                              );
                            },
                          );
                        },
                      ),
                    ],

                    Gap(20.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(
      BuildContext context, String lawyerUid, String appointmentId) {
    double selectedRating = 5.0;
    final parentBloc =
    BlocProvider.of<ClientAppointmentDetailScreenBloc>(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Center(
                child: Text(
                  "Rate Lawyer",
                  style: AppStyle.style18w600(),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "How was your session consultation?",
                    style: AppStyle.style14w400(color: AppColors.liteGery),
                    textAlign: TextAlign.center,
                  ),
                  Gap(15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.amberColor,
                          size: 32.r,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = starValue.toDouble();
                          });
                        },
                      );
                    }),
                  ),
                  Text(
                    "$selectedRating / 5.0",
                    style: AppStyle.style14w400(color: AppColors.blackColor),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    "Cancel",
                    style: AppStyle.style14w400(color: AppColors.liteGery),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    parentBloc.add(
                      SubmitLawyerRatingEvent(
                        lawyerUid: lawyerUid,
                        appointmentId: appointmentId,
                        rating: selectedRating,
                      ),
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    "Submit",
                    style: AppStyle.style14w400(color: AppColors.liteBlue),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(
      String title,
      String value, {
        Color? color,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyle.style14w400(
              color: AppColors.liteGery,
            ),
          ),
          Gap(5.h),
          Text(
            value,
            style: AppStyle.style18w600(
              color: color ?? AppColors.blackColor,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

/// Small isolated widget so the WhatsApp fetch event is only dispatched
/// once per lawyerUid and doesn't re-trigger on every stream tick.
class _LawyerWhatsAppSection extends StatefulWidget {
  final dynamic lawyerUid;

  const _LawyerWhatsAppSection({required this.lawyerUid});

  @override
  State<_LawyerWhatsAppSection> createState() =>
      _LawyerWhatsAppSectionState();
}

class _LawyerWhatsAppSectionState extends State<_LawyerWhatsAppSection> {
  @override
  void initState() {
    super.initState();
    if (widget.lawyerUid != null) {
      context.read<ClientAppointmentDetailScreenBloc>().add(
        FetchLawyerWhatsAppEvent(lawyerUid: widget.lawyerUid.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientAppointmentDetailScreenBloc,
        ClientAppointmentDetailScreenState>(
      buildWhen: (previous, current) =>
      current is FetchLawyerWhatsAppLoading ||
          current is FetchLawyerWhatsAppSuccess ||
          current is FetchLawyerWhatsAppError,
      builder: (context, state) {
        if (state is FetchLawyerWhatsAppLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is FetchLawyerWhatsAppSuccess) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WhatsApp Number",
                  style: AppStyle.style14w400(color: AppColors.liteGery),
                ),
                Gap(5.h),
                Text(
                  state.whatsAppNo,
                  style: AppStyle.style18w600(color: AppColors.liteGreen),
                ),
                const Divider(),
              ],
            ),
          );
        }

        if (state is FetchLawyerWhatsAppError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WhatsApp Number",
                  style: AppStyle.style14w400(color: AppColors.liteGery),
                ),
                Gap(5.h),
                Text(
                  "Unavailable",
                  style: AppStyle.style18w600(),
                ),
                const Divider(),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Center(
            child: Text(
              "Loading contact details...",
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        );
      },
    );
  }
}