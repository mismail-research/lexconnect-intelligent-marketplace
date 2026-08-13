import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_assets.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/core/constants/app_text_style.dart';
import 'package:lexbid/routes.dart';

class LawyerCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final double? cardWidth;
  final int animationIndex;

  const LawyerCard({
    super.key,
    required this.data,
    this.cardWidth,
    this.animationIndex = 0,
  });

  @override
  State<LawyerCard> createState() => _LawyerCardState();
}

class _LawyerCardState extends State<LawyerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(
      Duration(milliseconds: 100 + (widget.animationIndex * 120)),
          () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.data['avatarUrl'];
    final bool isAvailable = widget.data['isAvailable'] ?? false;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: child,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteGenerator.lawyerDetail,
            arguments: widget.data,
          );
        },
        child: Container(
          width: widget.cardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: AppColors.whiteColor.withValues(alpha: 0.20),
            ),
            color: AppColors.whiteColor,
          ),
          child: Stack(
            children: [
              /// IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return _ImageShimmer();
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

              /// GRADIENT
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              /// NAME
              Positioned(
                bottom: 10.h,
                left: 10.w,
                right: 10.w,
                child: Text(
                  widget.data['businessName'] ?? widget.data['name'] ?? "Lawyer",
                  style: AppStyle.style12w600(
                    color: AppColors.whiteColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              /// STATUS
              Positioned(
                top: 8.h,
                right: 8.w,
                child: _AnimatedStatusBadge(isAvailable: isAvailable),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Image Shimmer ─────────────────────────────────────────────────────────────

class _ImageShimmer extends StatefulWidget {
  @override
  State<_ImageShimmer> createState() => _ImageShimmerState();
}

class _ImageShimmerState extends State<_ImageShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      // ✅ Fixed Warning on Line 212: Changed (_, __) to explicitly named arguments
      builder: (context, child) => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_anim.value - 0.4).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.4).clamp(0.0, 1.0),
            ],
            colors: [
              AppColors.backgroundColor,
              AppColors.whiteColor.withValues(alpha: 0.7),
              AppColors.backgroundColor,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pulsing Status Badge ──────────────────────────────────────────────────────

class _AnimatedStatusBadge extends StatefulWidget {
  final bool isAvailable;
  const _AnimatedStatusBadge({required this.isAvailable});

  @override
  State<_AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<_AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    if (widget.isAvailable) _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        height: 22.h,
        width: 22.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isAvailable
              ? AppColors.liteBlue
              : AppColors.redColor,
        ),
        child: Icon(
          widget.isAvailable ? Icons.check : Icons.close,
          size: 14.sp,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }
}