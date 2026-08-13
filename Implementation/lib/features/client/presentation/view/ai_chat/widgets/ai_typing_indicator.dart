import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';

class AiTypingIndicator extends StatelessWidget {
  final String statusText;

  const AiTypingIndicator({
    super.key,
    this.statusText = '', // 👈 optional, defaults to empty
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28.w,
            height: 28.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: AppColors.whiteColor,
              size: 13.r,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
                bottomLeft: Radius.circular(4.r),
                bottomRight: Radius.circular(14.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkContrast.withValues(alpha: 0.06),
                  blurRadius: 6.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: statusText.isNotEmpty
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _AnimatedTypingDots(),
                SizedBox(width: 8.w),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.borderColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
                : const _AnimatedTypingDots(),
          ),
        ],
      ),
    );
  }
}

class _AnimatedTypingDots extends StatefulWidget {
  const _AnimatedTypingDots();

  @override
  State<_AnimatedTypingDots> createState() => _AnimatedTypingDotsState();
}

class _AnimatedTypingDotsState extends State<_AnimatedTypingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    final double targetOffset = -5.h;

    _animations = _controllers
        .map((c) => Tween<double>(begin: 0, end: targetOffset).animate(
      CurvedAnimation(parent: c, curve: Curves.easeInOut),
    ))
        .toList();

    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              width: 7.w,
              height: 7.h,
              margin: EdgeInsets.only(right: i < 2 ? 4.w : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.borderColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      }),
    );
  }
}