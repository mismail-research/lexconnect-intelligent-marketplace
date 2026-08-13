import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_strings.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/core/utils/app_padding.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_bloc.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_event.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerAppointments/lawyer_appointments_state.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerAppointments/widgets/detailAppointmentCard.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerAppointments/widgets/skeletons/detail_appointment_card_skeletons.dart';
import 'package:lexbid/widgets/no_data.dart';

class LawyerAppointments extends StatefulWidget {
  const LawyerAppointments({super.key});

  @override
  State<LawyerAppointments> createState() => _LawyerAppointmentsState();
}

class _LawyerAppointmentsState extends State<LawyerAppointments> {
  final ScrollController _scrollController = ScrollController();
  String? _targetAppointmentId;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && _targetAppointmentId == null) {
      _targetAppointmentId = args;

    }
  }
  void _scrollToTarget(List appointments) {
    if (_targetAppointmentId == null) return;

    final index = appointments.indexWhere(
          (element) => element.appointmentId == _targetAppointmentId,
    );

    if (index != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;

        double itemExtent = 100.h;
        double targetOffset = index * itemExtent;

        if (targetOffset > _scrollController.position.maxScrollExtent) {
          targetOffset = _scrollController.position.maxScrollExtent;
        }

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LawyerAppointmentsBloc()..add(LoadLawyerAppointmentsEvent()),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: AppPadding.horizontal,
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      AppStrings.appointment,
                      style: AppStyle.style20w900(),
                    ),
                  ],
                ),

                SizedBox(height: 15.h),

                // ── List ─────────────────────────────────────────
                Expanded(
                  child: BlocBuilder<LawyerAppointmentsBloc,
                      LawyerAppointmentsState>(
                    builder: (context, state) {
                      if (state is LawyerAppointmentsLoading) {
                        return ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 6,
                          // ✅ Fixed: Replaced multiple wildcards with context metrics
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10.h),
                          itemBuilder: (context, index) =>
                          const DetailAppointmentCardSkeleton(),
                        );
                      }

                      if (state is LawyerAppointmentsLoaded) {
                        if (state.appointments.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const EmptyAppointments(size: 200),
                                SizedBox(height: 10.h),
                                Text(
                                  'No appointments found',
                                  style: AppStyle.style14w400(
                                      color: AppColors.liteGery),
                                ),
                              ],
                            ),
                          );
                        }

                        _scrollToTarget(state.appointments);

                        return ListView.separated(
                          controller: _scrollController,
                          itemCount: state.appointments.length,
                          // ✅ Fixed: Cleared out duplicate layout wildcards
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final appointment = state.appointments[index];


                            return DetailAppointmentCard(
                              isHighlighted: !appointment.isSeenByLawyer,
                              fullData: {
                                'appointmentId': appointment.appointmentId,
                                'clientName': appointment.clientName,
                                'consultationType': appointment.consultancyType,
                                'imageUrl': appointment.imageUrl,
                                'status': appointment.status,
                                'date': appointment.date,
                                'time': appointment.time,
                              },
                            );
                          },
                        );
                      }

                      if (state is LawyerAppointmentsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: AppStyle.style14w400(
                                color: AppColors.redColor),
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}