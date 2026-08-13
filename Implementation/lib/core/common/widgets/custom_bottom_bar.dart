import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lexbid/core/constants/app_color.dart';

class CustomAnimatedBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomAnimatedBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<IconData> unselectedIcons = const [
    Icons.home_outlined,
    Icons.analytics_outlined,
    Icons.person_outline,
  ];

  final List<IconData> selectedIcons = const [
    Icons.home,
    Icons.analytics,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12.h),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = width / unselectedIcons.length;

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: selectedIndex.toDouble()),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final cx = (itemWidth * value) + (itemWidth / 2);

                final double barHeight = 58.h;
                final double circleSize = 46.r;

                return SizedBox(
                  height: barHeight + 18.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      /// BACKGROUND
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: barHeight,
                        child: CustomPaint(
                          painter: NavBarPainter(
                            cx: cx,
                            barColor: AppColors.darkContrast,
                            notchRadius: (circleSize / 2) + 6.r,
                          ),
                        ),
                      ),

                      /// ICONS
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: barHeight,
                        child: Row(
                          children: List.generate(unselectedIcons.length, (
                              index,
                              ) {
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => onItemSelected(index),
                                child: Icon(
                                  index == selectedIndex
                                      ? selectedIcons[index]
                                      : unselectedIcons[index],
                                  size: 24.r,
                                  color: index == selectedIndex
                                      ? Colors.transparent
                                      : AppColors.liteGery,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      /// ACTIVE CIRCLE
                      Positioned(
                        bottom: barHeight - (circleSize / 2) - 4.h,
                        left: cx - (circleSize / 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.liteBlue,
                          ),
                          child: Icon(
                            selectedIcons[selectedIndex],
                            color: AppColors.whiteColor,
                            size: 24.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NavBarPainter extends CustomPainter {
  final double cx;
  final Color barColor;
  final double notchRadius;

  const NavBarPainter({
    required this.cx,
    required this.barColor,
    required this.notchRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = barColor;

    final background = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(28.r),
        ),
      );

    final cutout = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, 0), radius: notchRadius));

    final finalPath = Path.combine(
      PathOperation.difference,
      background,
      cutout,
    );

    canvas.drawShadow(finalPath, Colors.black26, 6.r, false);
    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant NavBarPainter oldDelegate) {
    return oldDelegate.cx != cx || oldDelegate.notchRadius != notchRadius;
  }
}