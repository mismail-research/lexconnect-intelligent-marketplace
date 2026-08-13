import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/common/widgets/app_flushbar.dart';
import 'package:lexbid/core/common/widgets/confirmation_dialog.dart';
import 'package:lexbid/core/common/widgets/notification_bell_icon.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_strings.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/core/utils/app_padding.dart';
import 'package:lexbid/core/utils/text_utils.dart';
import 'package:lexbid/features/auth/bloc/auth_bloc.dart';
import 'package:lexbid/features/auth/bloc/auth_event.dart';
import 'package:lexbid/features/auth/bloc/auth_state.dart';
import 'package:lexbid/features/lawyer/presentation/bloc/lawyerHome/lawyer_home_bloc.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerHome/widgets/appointmentCard.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerHome/widgets/lawyer_quick_stats_widget.dart';
import 'package:lexbid/features/lawyer/presentation/view/lawyerHome/widgets/skeletons/apointment_card_skeleton.dart';
import 'package:lexbid/routes.dart';
import 'package:lexbid/widgets/ui_loader.dart';

class LawyerHome extends StatelessWidget {
  const LawyerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LawyerHomeBloc()..add(LoadLawyerDataEvent()),
      child: const _LawyerHomeView(),
    );
  }
}

class _LawyerHomeView extends StatelessWidget {
  const _LawyerHomeView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(
                  child: UiLoader(),   // 👈 same animated loader as client home
                ),
              );
            }

            if (state is AuthUnauthenticated) {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }

              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteGenerator.roleSelectionRoute,
                    (_) => false,
              );
            }

            if (state is AuthFailure) {
              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }

              AppFlushBar.showError(
                context,
                message: state.failure.message,
              );
            }
          },
        ),
        BlocListener<LawyerHomeBloc, LawyerHomeState>(
          listener: (context, state) {
            if (state is LawyerHomeError) {
              AppFlushBar.showError(
                context,
                message: state.message,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: AppPadding.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      iconSize: 60.r,
                      padding: EdgeInsets.zero,
                      icon: BlocBuilder<LawyerHomeBloc, LawyerHomeState>(
                        builder: (context, state) {
                          String? avatarUrl;

                          if (state is LawyerHomeLoaded) {
                            avatarUrl = state.imageUrl;
                          }

                          return CircleAvatar(
                            radius: 30.r,
                            backgroundColor: AppColors.borderColor,
                            backgroundImage: (avatarUrl != null &&
                                avatarUrl.trim().isNotEmpty)
                                ? CachedNetworkImageProvider(avatarUrl)
                                : const AssetImage(
                              AppAssets.defaultLawyerImage,
                            ) as ImageProvider,
                          );
                        },
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteGenerator.lawyerProfile,
                        );
                      },
                    ),

                    SizedBox(width: 10.w),

                    /// NAME SECTION
                    BlocBuilder<LawyerHomeBloc, LawyerHomeState>(
                      builder: (context, state) {
                        String lawyerName = "Lawyer";

                        if (state is LawyerHomeLoaded) {
                          lawyerName = state.lawyerName;
                        } else if (state is LawyerHomeLogoutLoading) {
                          lawyerName = state.lawyerName;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome', style: AppStyle.style18w600()),
                            Text(
                              TextUtils.limitText(lawyerName),
                              style: AppStyle.style16w400(
                                color: AppColors.liteGery,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                    ),

                    const Spacer(),

                    NotificationBellIcon(
                      collection: 'lawyers',
                      uid: FirebaseAuth.instance.currentUser!.uid,
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteGenerator.lawyerAppointments);
                      },
                    ),

                    /// LOGOUT BUTTON
                    IconButton(
                      iconSize: 30.r,
                      icon: const Icon(Icons.logout_outlined),
                      onPressed: () async {
                        final confirm = await ConfirmationDialog.show(
                          context: context,
                          title: 'Logout',
                          message: 'Are you sure you want to logout?',
                          confirmText: 'Logout',
                          confirmColor: AppColors.redColor,
                        );

                        if (confirm != true) return;

                        // FIX: Safeguard asynchronous context gap warning here
                        if (!context.mounted) return;

                        final uid = FirebaseAuth.instance.currentUser?.uid;

                        if (uid == null) return;

                        final token =
                            await FirebaseMessaging.instance.getToken() ?? "";

                        if (!context.mounted) return;

                        context.read<AuthBloc>().add(
                          LogoutEvent(
                            uid: uid,
                            deviceToken: token,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Text("Quick Stats", style: AppStyle.style20w900()),
                SizedBox(height: 15.h),
                const LawyerQuickStatsWidget(),
                SizedBox(height: 15.h),
                Text(AppStrings.appointment, style: AppStyle.style20w900()),
                SizedBox(height: 15.h),

                SizedBox(
                  height: 210.h,
                  child: BlocBuilder<LawyerHomeBloc, LawyerHomeState>(
                    builder: (context, state) {
                      if (state is LawyerHomeLoading) {
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          separatorBuilder: (_, child) =>
                              SizedBox(height: 10.h),
                          itemBuilder: (_, child) =>
                          const AppointmentCardSkeleton(),
                        );
                      }
                      if (state is LawyerHomeLoaded) {
                        if (state.appointments.isEmpty) {
                          return const Center(
                              child: Text("No appointments yet"));
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.appointments.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final appointment = state.appointments[index];
                            return AppointmentCard(
                              name: appointment.clientName,
                              consultancyType: appointment.consultancyType,
                              date: appointment.date,
                              day: appointment.day,
                              imageUrl: appointment.imageUrl,
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
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