import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';

class LawyerProfileImageCard extends StatefulWidget {
  final String? imageUrl;
  final bool isAvailable;
  final String specialization;

  const LawyerProfileImageCard({
    super.key,
    this.imageUrl,
    required this.isAvailable,
    required this.specialization,
  });

  @override
  State<LawyerProfileImageCard> createState() =>
      _LawyerProfileImageCardState();
}

class _LawyerProfileImageCardState extends State<LawyerProfileImageCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _badgeCtrl;

  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _badgeAnim;

  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutBack),
    );

    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _badgeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _badgeCtrl, curve: Curves.easeOutBack),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _scaleCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _badgeCtrl.forward();
        if (widget.isAvailable) _pulseCtrl.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _pulseCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  String get _specializationLabel {
    final s = widget.specialization.trim();
    if (s.isEmpty) return 'Lawyer';
    return '${s[0].toUpperCase()}${s.substring(1)} Lawyer';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          width: 260.w,
          height: 240.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Image ──────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                    ? Image.network(
                  widget.imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.backgroundColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.borderColor,
                          strokeWidth: 2.w,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    AppAssets.defaultLawyerImage,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : Image.asset(
                  AppAssets.defaultLawyerImage,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // ── Gradient overlay ───────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.darkContrast.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // ── Pulsing status badge ───────────────────────────
              Positioned(
                top: 12.h,
                right: 12.w,
                child: ScaleTransition(
                  scale: _badgeAnim,
                  child: ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      height: 28.h,
                      width: 28.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isAvailable
                            ? AppColors.liteBlue
                            : AppColors.redColor,
                        border: Border.all(
                          color: AppColors.whiteColor,
                          width: 2.w,
                        ),
                      ),
                      child: Icon(
                        widget.isAvailable ? Icons.check : Icons.close,
                        size: 14.r,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Specialization pill ────────────────────────────
              Positioned(
                bottom: -20.h,
                left: (260.w - 170.w) / 2,
                child: Container(
                  width: 170.w,
                  height: 40.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: const LinearGradient(
                      colors: AppColors.buttonGradient1,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkContrast.withValues(alpha: 0.2),
                        blurRadius: 8.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Text(
                    _specializationLabel,
                    style: AppStyle.style12w600(color: AppColors.whiteColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}