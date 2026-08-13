import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_strings.dart';
import 'package:lexbid/routes.dart';
import '../bloc/role_selection_bloc.dart';
import '../bloc/role_selection_event.dart';
import '../bloc/role_selection_state.dart';

class RoleSelectionView extends StatefulWidget {
  const RoleSelectionView({super.key});

  @override
  State<RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<RoleSelectionView>
    with TickerProviderStateMixin {
  // header animation
  late AnimationController _headerController;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;

  // client card animation
  late AnimationController _clientController;
  late Animation<double> _clientOpacity;
  late Animation<Offset> _clientSlide;

  // lawyer card animation
  late AnimationController _lawyerController;
  late Animation<double> _lawyerOpacity;
  late Animation<Offset> _lawyerSlide;

  // press scale for cards
  double _clientScale = 1.0;
  double _lawyerScale = 1.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // header
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    // client card
    _clientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _clientOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _clientController, curve: Curves.easeOut),
    );
    _clientSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _clientController, curve: Curves.easeOut),
    );

    // lawyer card
    _lawyerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _lawyerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lawyerController, curve: Curves.easeOut),
    );
    _lawyerSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _lawyerController, curve: Curves.easeOut),
    );
  }

  Future<void> _startAnimations() async {
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 250));
    _clientController.forward();

    await Future.delayed(const Duration(milliseconds: 150));
    _lawyerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _clientController.dispose();
    _lawyerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoleSelectionBloc, RoleSelectionState>(
      listener: (context, state) {
        if (state is ClientSelected) {
          Navigator.pushNamed(
            context,
            RouteGenerator.loginRoute,
            arguments: {'userType': AppStrings.client},
          );
        } else if (state is LawyerSelected) {
          Navigator.pushNamed(
            context,
            RouteGenerator.loginRoute,
            arguments: {'userType': AppStrings.lawyer},
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.h),

                // header section
                FadeTransition(
                  opacity: _headerOpacity,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 8.w),
                        Text(
                          'LEXIUM',
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.borderColor,
                            letterSpacing: 1.5.w,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // main heading
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkContrast,
                              height: 1.25,
                            ),
                            children: const [
                              TextSpan(text: 'Select your\n'),
                              TextSpan(
                                text: 'role ',
                                style: TextStyle(color: AppColors.borderColor),
                              ),
                              TextSpan(text: 'to continue'),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // subheading
                        Text(
                          'Choose how you would like\nto use LEXIUM today',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.darkContrast.withValues(
                              alpha: 0.45,
                            ),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // client card
                FadeTransition(
                  opacity: _clientOpacity,
                  child: SlideTransition(
                    position: _clientSlide,
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _clientScale = 0.97),
                      onTapUp: (_) {
                        setState(() => _clientScale = 1.0);
                        context.read<RoleSelectionBloc>().add(SelectClient());
                      },
                      onTapCancel: () => setState(() => _clientScale = 1.0),
                      child: AnimatedScale(
                        scale: _clientScale,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: _buildRoleCard(
                          title: AppStrings.client,
                          description:
                          'Find expert lawyers for your legal matters',
                          icon: _clientIcon(),
                          iconBg: AppColors.darkContrast.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // lawyer card
                FadeTransition(
                  opacity: _lawyerOpacity,
                  child: SlideTransition(
                    position: _lawyerSlide,
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _lawyerScale = 0.97),
                      onTapUp: (_) {
                        setState(() => _lawyerScale = 1.0);
                        context.read<RoleSelectionBloc>().add(SelectLawyer());
                      },
                      onTapCancel: () => setState(() => _lawyerScale = 1.0),
                      child: AnimatedScale(
                        scale: _lawyerScale,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: _buildRoleCard(
                          title: AppStrings.lawyer,
                          description:
                          'Connect with clients and grow your practice',
                          icon: _lawyerIcon(),
                          iconBg: AppColors.borderColor.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required Widget icon,
    required Color iconBg,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.darkContrast.withValues(alpha: 0.07),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkContrast.withValues(alpha: 0.05),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // icon box
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(child: icon),
          ),
          SizedBox(width: 16.w),

          // text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkContrast,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.darkContrast.withValues(alpha: 0.45),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // arrow box
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 14.r,
              color: AppColors.borderColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _clientIcon() {
    return Icon(
      Icons.person_outline_rounded,
      size: 26.r,
      color: AppColors.borderColor,
    );
  }

  Widget _lawyerIcon() {
    return Icon(
      Icons.gavel_rounded,
      size: 26.r,
      color: AppColors.borderColor,
    );
  }
}