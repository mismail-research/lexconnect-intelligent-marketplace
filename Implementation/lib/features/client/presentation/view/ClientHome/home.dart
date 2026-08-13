import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/common/widgets/app_flushbar.dart';
import 'package:lexbid/core/common/widgets/confirmation_dialog.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/core/utils/app_padding.dart';
import 'package:lexbid/core/utils/text_utils.dart';
import 'package:lexbid/features/auth/bloc/auth_bloc.dart';
import 'package:lexbid/features/auth/bloc/auth_event.dart';
import 'package:lexbid/features/auth/bloc/auth_state.dart';
import 'package:lexbid/features/client/bloc/home/client_home_bloc.dart';
import 'package:lexbid/features/client/presentation/view/ClientHome/widgets/empty_lawyer_state.dart';
import 'package:lexbid/features/client/presentation/view/ClientHome/widgets/lawyer_card.dart';
import 'package:lexbid/features/client/presentation/view/ClientHome/widgets/lawyer_type_chip.dart';
import 'package:lexbid/features/client/presentation/view/ClientHome/widgets/legal_quotes_card.dart';
import 'package:lexbid/routes.dart';
import 'package:lexbid/widgets/dot_lottie_loader.dart';
import 'package:lexbid/widgets/ui_loader.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _promoController;
  late AnimationController _sectionController;
  late AnimationController _bellController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _promoFade;
  late Animation<Offset> _promoSlide;
  late Animation<double> _sectionFade;
  late Animation<Offset> _sectionSlide;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _promoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _promoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _promoController, curve: Curves.easeOut),
    );
    _promoSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _promoController, curve: Curves.easeOutCubic),
    );

    _sectionFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sectionController, curve: Curves.easeOut),
    );
    _sectionSlide = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _sectionController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _headerController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _promoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _sectionController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _bellController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _promoController.dispose();
    _sectionController.dispose();
    _bellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientHomeBloc()..add(LoadLawyerTypes()),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
        current is AuthLoading ||
            current is AuthFailure ||
            current is AuthUnauthenticated,
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Center(
                child: UiLoader(),
              ),
            );
          }

          if (state is AuthUnauthenticated) {
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

            AppFlushBar.showError(context, message: state.failure.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Padding(
            padding: AppPadding.afterAuth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ──────────────────────────────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Row(
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('clients')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            String? imageUrl;
                            String displayName = 'Good Morning';

                            if (snapshot.hasData && snapshot.data!.exists) {
                              final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                              imageUrl = data['avatarUrl'];
                              if (data['name'] != null &&
                                  (data['name'] as String).isNotEmpty) {
                                displayName = TextUtils.limitText(data['name']);
                              }
                            }

                            return Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      RouteGenerator.clientProfile,
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  icon: CircleAvatar(
                                    radius: 27.r,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: (imageUrl != null &&
                                        imageUrl.isNotEmpty)
                                        ? NetworkImage(imageUrl)
                                        : const AssetImage(
                                      AppAssets.defaultLawyerImage,
                                    ) as ImageProvider,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Welcome',
                                        style: AppStyle.style18w600()),
                                    Text(
                                      displayName,
                                      style: AppStyle.style16w400(
                                        color: AppColors.liteGery,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const Spacer(),

                        // ✅ NEW: badge count now sourced from
                        // clients/{uid}.unreadNotifications, incremented
                        // server-side whenever the lawyer accepts/rejects/
                        // completes an appointment.
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('appointments')
                              .where('clientUid',
                              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                              .where('isSeenByClient', isEqualTo: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final unread = snapshot.hasData ? snapshot.data!.docs.length : 0;

                            return _WiggleBell(
                              controller: _bellController,
                              unreadCount: unread,
                            );
                          },

                        ),

                        /// LOGOUT
                        IconButton(
                          icon: Icon(
                            Icons.logout_outlined,
                            size: 30.r,
                            color: AppColors.darkContrast,
                          ),
                          onPressed: () async {
                            final confirm = await ConfirmationDialog.show(
                              context: context,
                              title: 'Logout',
                              message: 'Are you sure you want to logout?',
                              confirmText: 'Logout',
                              confirmColor: AppColors.redColor,
                            );

                            if (confirm != true) return;

                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;

                            String token = "";
                            try {
                              token = await FirebaseMessaging.instance.getToken() ?? "";
                            } catch (e) {
                              debugPrint("FCM Logout Token Error: $e");
                            }

                            if (!context.mounted) return;

                            context.read<AuthBloc>().add(
                              LogoutEvent(uid: uid, deviceToken: token),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 25.h),

                FadeTransition(
                  opacity: _promoFade,
                  child: SlideTransition(
                    position: _promoSlide,
                    child: LegalQuotesCard(
                      imagePath: 'assets/images/judge_scale.png',
                    ),
                  ),
                ),
                SizedBox(height: 30.h),

                // ── Section labels ───────────────────────────────
                FadeTransition(
                  opacity: _sectionFade,
                  child: SlideTransition(
                    position: _sectionSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Legal Help, Your Way',
                          style: AppStyle.style14w400(color: AppColors.blackColor),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Find Top Class Lawyers',
                          style: AppStyle.style20w900(color: AppColors.blackColor),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Chips ────────────────────────────────────────
                BlocBuilder<ClientHomeBloc, ClientHomeState>(
                  builder: (context, state) {
                    if (state is! LawyerTypesLoaded) {
                      return SizedBox(
                        height: 42.h,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.borderColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 42.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.types.length,
                        separatorBuilder: (_, child) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          final type = state.types[index];

                          return LawyerTypeChip(
                            title: type.title,
                            isSelected: state.selectedIndex == index,
                            animationIndex: index,
                            onTap: () {
                              context.read<ClientHomeBloc>().add(
                                SelectLawyerType(index),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),


                // ── Lawyer list ──────────────────────────────────
                Expanded(
                  child: BlocBuilder<ClientHomeBloc, ClientHomeState>(
                    builder: (context, state) {
                      if (state is! LawyerTypesLoaded) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.borderColor,
                          ),
                        );
                      }

                      final selectedType = state
                          .types[state.selectedIndex]
                          .title
                          .toLowerCase();

                      return
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('lawyers')
                              .where('approvalStatus', isEqualTo: 'approved')
                              .where('lawyerType', isEqualTo: selectedType)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: DotLottieLoader(),
                              );
                            }

                            // ── Empty state ────────────────────────
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return EmptyLawyerState(
                                category: state.types[state.selectedIndex].title,
                              );
                            }

                            final docs = snapshot.data!.docs;

                            // Single lawyer — centered
                            if (docs.length == 1) {
                              final data =
                              docs.first.data() as Map<String, dynamic>;

                              return Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 240.w,
                                  height: 270.h,
                                  child: LawyerCard(
                                    data: data,
                                    animationIndex: 0,
                                  ),
                                ),
                              );
                            }

                            /// ✅ MULTIPLE LAWYERS -> HORIZONTAL LIST
                            return ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              scrollDirection: Axis.horizontal,
                              itemCount: docs.length,
                              separatorBuilder: (_, child) => SizedBox(width: 15.w),
                              itemBuilder: (context, index) {
                                final data =
                                docs[index].data() as Map<String, dynamic>;

                                return SizedBox(
                                  width: 170.w,
                                  child: LawyerCard(
                                    data: data,
                                    animationIndex: index,
                                  ),
                                );
                              },
                            );
                          },
                        );
                    },
                  ),
                ),
                SizedBox(height: 50.h,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Wiggling bell ─────────────────────────────────────────────────────────────

class _WiggleBell extends StatelessWidget {
  final AnimationController controller;
  final int unreadCount;
  const _WiggleBell({required this.controller, this.unreadCount = 0});

  @override
  Widget build(BuildContext context) {
    final wiggle = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0.2), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: -0.15), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: wiggle,
      builder: (_, child) => Transform.rotate(
        angle: wiggle.value,
        child: child,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              size: 30.sp,
              color: AppColors.darkContrast,
            ),
            onPressed: () => Navigator.pushNamed(
              context,
              RouteGenerator.clientAppointments,
            ),
          ),

          // ✅ NEW: unread count badge
          if (unreadCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: IgnorePointer(
                child: Container(
                  padding:
                   EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.redColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.backgroundColor,
                      width: 1.5.w,
                    ),
                  ),
                  constraints:
                  BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.2.h,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}