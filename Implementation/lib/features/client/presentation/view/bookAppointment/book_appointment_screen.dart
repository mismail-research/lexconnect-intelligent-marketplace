import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lexbid/core/common/widgets/app_flushbar.dart';
import 'package:lexbid/core/common/widgets/confirmation_dialog.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_strings.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/core/utils/app_padding.dart';
import 'package:lexbid/features/client/bloc/bookAppointment/appointment_bloc.dart';
import 'package:lexbid/features/client/bloc/bookAppointment/appointment_event.dart';
import 'package:lexbid/features/client/bloc/bookAppointment/appointment_state.dart';
import 'package:lexbid/features/client/presentation/view/bookAppointment/widget/consultation_type_card.dart';
import 'package:lexbid/features/client/presentation/view/bookAppointment/widget/data_selector.dart';
import 'package:lexbid/features/client/presentation/view/bookAppointment/widget/lawyer_info_card.dart';
import 'package:lexbid/features/client/presentation/view/bookAppointment/widget/time_slot_grid.dart';
import 'package:lexbid/widgets/dot_lottie_loader.dart';

class BookAppointmentScreen extends StatelessWidget {
  final Map<String, dynamic> lawyerData;

  const BookAppointmentScreen({
    super.key,
    required this.lawyerData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      AppointmentBloc()..add(LoadAppointmentData(lawyerData)),
      child: BlocListener<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state.isLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: DotLottieLoader(),
              ),
            );
          }

          /// SUCCESS
          if (state.bookingSuccess) {
            Navigator.of(context, rootNavigator: true).pop();
            AppFlushBar.showSuccess(
              context,
              message: "Appointment Booked Successfully!",
            );
          }

          /// ERROR
          if (state.errorMessage != null) {
            Navigator.of(context, rootNavigator: true).pop();
            AppFlushBar.showError(
              context,
              message: state.errorMessage!,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: AppPadding.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.darkContrast,
                          radius: 20.r,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.whiteColor,
                              size: 18.sp,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.bookAppointment,
                              style: AppStyle.style18w600(),
                            ),
                            Text(
                              "Select your preferred",
                              style: AppStyle.style12w400(
                                  color: AppColors.lightGrey),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Gap(30.h),

                    /// MAIN DATA
                    BlocBuilder<AppointmentBloc, AppointmentState>(
                      builder: (context, state) {
                        if (state.lawyer == null) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50.h),
                              child: const CircularProgressIndicator(),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// LAWYER CARD
                            LawyerInfoCard(lawyer: state.lawyer!),

                            Gap(30.h),

                            /// CONSULTATION TYPE
                            Text(
                              "Consultation Type",
                              style: AppStyle.style18w600(),
                            ),

                            Gap(10.h),

                            ...state.consultationTypes.map(
                                  (type) => ConsultationTypeCard(
                                type: type,
                                isSelected: state.selectedTypeId == type.id,
                                onTap: () {
                                  context.read<AppointmentBloc>().add(
                                    SelectConsultationType(type.id),
                                  );
                                },
                              ),
                            ),

                            Gap(20.h),

                            /// DATE SELECTOR
                            DateSelector(
                              dates: state.availableDates,
                              selectedDate: state.selectedDate,
                              onDateSelected: (date) {
                                context.read<AppointmentBloc>().add(
                                  SelectDate(date),
                                );
                              },
                            ),

                            Gap(20.h),

                            /// TIME SELECTOR
                            TimeSlotSelector(
                              timeSlots: state.timeSlots,
                              selectedTime: state.selectedTime,
                              selectedDate: state.selectedDate,
                              onTimeSelected: (time) {
                                context.read<AppointmentBloc>().add(
                                  SelectTime(time),
                                );
                              },
                            ),

                            Gap(10.h),

                            /// BOOK BUTTON
                            Center(
                              child: InkWell(
                                onTap: () async {
                                  final blocContext = context;
                                  final currentState = state;

                                  final lawyerDoc = await FirebaseFirestore
                                      .instance
                                      .collection('lawyers')
                                      .doc(currentState.lawyer!.uid)
                                      .get();

                                  // Guard structure to verify the context is still mounted after the async Firestore fetch
                                  if (!blocContext.mounted) return;

                                  final data = lawyerDoc.data();
                                  if (data == null ||
                                      !data.containsKey('isAvailable')) {
                                    AppFlushBar.showError(
                                      blocContext,
                                      message: "Lawyer info not complete",
                                    );
                                    return;
                                  }

                                  final bool isAvailable =
                                      data['isAvailable'] ?? false;

                                  if (!isAvailable) {
                                    AppFlushBar.showError(
                                      blocContext,
                                      message: "Lawyer is not available",
                                    );
                                    return;
                                  }

                                  if (currentState.selectedDate == null ||
                                      currentState.selectedTime == null ||
                                      currentState.selectedTypeId == null) {
                                    AppFlushBar.showError(
                                      blocContext,
                                      message:
                                      "Please select Type, Date, & Time",
                                    );
                                    return;
                                  }

                                  final timeFormat = DateFormat("hh:mm a");
                                  final parsedTime = timeFormat
                                      .parse(currentState.selectedTime!);

                                  final selectedDateTime = DateTime(
                                    currentState.selectedDate!.year,
                                    currentState.selectedDate!.month,
                                    currentState.selectedDate!.day,
                                    parsedTime.hour,
                                    parsedTime.minute,
                                  );

                                  if (selectedDateTime
                                      .isBefore(DateTime.now())) {
                                    AppFlushBar.showError(
                                      blocContext,
                                      message:
                                      "Selected time already passed. Please choose future time.",
                                    );
                                    return;
                                  }

                                  final consultationType = currentState
                                      .consultationTypes
                                      .firstWhere((t) =>
                                  t.id == currentState.selectedTypeId)
                                      .title;

                                  final formattedDate = DateFormat.yMMMMd()
                                      .format(currentState.selectedDate!);

                                  final confirm = await ConfirmationDialog.show(
                                    context: blocContext,
                                    title: "Confirm Appointment",
                                    message:
                                    "Lawyer: ${currentState.lawyer!.name}\n"
                                        "Consultation: $consultationType\n"
                                        "Date: $formattedDate\n"
                                        "Time: ${currentState.selectedTime}",
                                    confirmText: "Confirm",
                                    cancelText: "Cancel",
                                    confirmColor: AppColors.liteBlue,
                                  );

                                  if (!blocContext.mounted) return;

                                  if (confirm == true) {
                                    final clientName = FirebaseAuth
                                        .instance.currentUser?.displayName ??
                                        "Client";

                                    blocContext
                                        .read<AppointmentBloc>()
                                        .add(BookAppointment(clientName));
                                  }
                                },
                                child: Container(
                                  height: 55.h,
                                  width: 55.w,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.borderColor
                                            .withValues(alpha: 0.15),
                                        blurRadius: 10.r,
                                        offset: Offset(0, 5.h),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.whiteColor,
                                    size: 20.r,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}