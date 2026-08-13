import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexbid/core/constants/app_color.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_bloc.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_event.dart';
import 'package:lexbid/features/client/bloc/bottomNavBar/bottom_nav_bar_state.dart';
import 'package:lexbid/features/client/presentation/view/ClientHome/home.dart';
import 'package:lexbid/features/client/presentation/view/ai_chat/ai_chat_screen.dart';
import 'package:lexbid/features/client/presentation/view/client_profile/client_profile_screen.dart';

class ClientBottomNavView extends StatelessWidget {
  const ClientBottomNavView({super.key});

  static final List<Widget> _screens = [
    const HomeView(),
    const AIChatScreen(),
    const ClientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBarBloc, BottomNavBarState>(
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          body: _screens[state.selectedIndex],
          bottomNavigationBar: CustomAnimatedBottomBar(
            selectedIndex: state.selectedIndex,
            onItemSelected: (index) {
              context.read<BottomNavBarBloc>().add(ChangeClientTab(index));
            },
          ),
        );
      },
    );
  }
}

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
    Icons.chat_outlined,
    Icons.person_outline,
  ];

  final List<IconData> selectedIcons = const [
    Icons.home,
    Icons.chat,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        // Matches the image: generous side padding, small bottom gap
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 12.0,
          top: 0.0,
        ),
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

                // Bar height + how far the circle floats above it
                const double barHeight = 58.0;
                const double circleSize = 46.0;  // Smaller, matches screenshot
                const double circleFloatOffset = 18.0; // How high above bar center

                return SizedBox(
                  height: barHeight + circleFloatOffset,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── 1. Curved bar background ──────────────────────────
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: barHeight,
                        child: CustomPaint(
                          painter: NavBarPainter(
                            cx: cx,
                            barColor: AppColors.darkContrast,
                            // Notch sized to match the smaller circle
                            notchRadius: circleSize / 2 + 6,
                          ),
                        ),
                      ),

                      // ── 2. Unselected icons ───────────────────────────────
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: barHeight,
                        child: Row(
                          children: List.generate(
                            unselectedIcons.length,
                                (index) {
                              final distance = (value - index).abs();
                              final opacity = distance.clamp(0.3, 1.0);
                              // Sink icon when notch passes over it
                              final translateY =
                                  (1.0 - distance.clamp(0.0, 1.0)) * 10.0;

                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => onItemSelected(index),
                                  child: Transform.translate(
                                    offset: Offset(0, translateY),
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Icon(
                                        unselectedIcons[index],
                                        // Active slot shows selected icon
                                        // tinted by the circle, others grey
                                        color: index == value.round()
                                            ? Colors.transparent
                                            : Colors.grey.shade400,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // ── 3. Floating active circle ─────────────────────────
                      Positioned(
                        // Centre vertically so it sits half above the bar
                        bottom: barHeight - circleSize / 2 - 4,
                        left: cx - circleSize / 2,
                        child: IgnorePointer(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.liteBlue,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.liteBlue.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                selectedIcons[value.round()],
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Painter — draws the rounded bar with a smooth notch cutout
// ─────────────────────────────────────────────────────────────────────────────
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
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    // Outer rounded rectangle
    final backgroundPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(28.0), // Matches the pill shape in screenshot
        ),
      );

    // Notch — a smooth semicircular dip, not too aggressive
    final double nr = notchRadius;
    final double gap = 4.0; // tiny breathing gap between circle edge and notch

    final cutoutPath = Path()
      ..moveTo(cx - nr - gap * 2, 0)
      ..quadraticBezierTo(cx - nr - gap, 0, cx - nr, gap)
      ..arcToPoint(
        Offset(cx + nr, gap),
        radius: Radius.circular(nr),
        clockwise: false,
      )
      ..quadraticBezierTo(cx + nr + gap, 0, cx + nr + gap * 2, 0)
      ..lineTo(cx + nr + gap * 2, -10)
      ..lineTo(cx - nr - gap * 2, -10)
      ..close();

    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    // Soft shadow under the bar
    canvas.drawShadow(finalPath, Colors.black.withOpacity(0.4), 6, false);
    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant NavBarPainter old) =>
      old.cx != cx || old.barColor != barColor || old.notchRadius != notchRadius;
}