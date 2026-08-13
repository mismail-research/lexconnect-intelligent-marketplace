import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CaseShuffleLoader extends StatefulWidget {
  final double size;

  const CaseShuffleLoader({
    super.key,
    this.size = 80,
  });

  @override
  State<CaseShuffleLoader> createState() => _CaseShuffleLoaderState();
}

class _CaseShuffleLoaderState extends State<CaseShuffleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Colors from your reference image
  static const Color teal = Color(0xFF0F9E89);
  static const Color navy = Color(0xFF185FA5);
  static const Color sky = Color(0xFF00AEEF);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600), // sped up from 2400ms
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Apply screen scaling dynamically to the fallback sizing base
    final double scaledSize = widget.size.r;

    return SizedBox(
      width: scaledSize,
      height: scaledSize,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = _ctrl.value;

          // Group rotation: 0 -> 180deg during 0-50%, then 180 -> 360 during 50-100%
          double rotationDeg;
          if (t < 0.5) {
            rotationDeg = _easeInOut(t / 0.5) * 180;
          } else {
            rotationDeg = 180 + _easeInOut((t - 0.5) / 0.5) * 180;
          }

          // Convergence scale: circles shrink toward center at the midpoint
          double convergeT;
          if (t < 0.45) {
            convergeT = 0;
          } else if (t < 0.55) {
            convergeT = _easeInOut((t - 0.45) / 0.10);
          } else if (t < 0.85) {
            convergeT = 1;
          } else {
            convergeT = 1 - _easeInOut((t - 0.85) / 0.15);
          }

          return Transform.rotate(
            angle: rotationDeg * math.pi / 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildCircle(
                  color: teal,
                  baseOffset: const Offset(0, -1),
                  convergeT: convergeT,
                  size: scaledSize,
                ),
                _buildCircle(
                  color: navy,
                  baseOffset: const Offset(-0.87, 0.5),
                  convergeT: convergeT,
                  size: scaledSize,
                ),
                _buildCircle(
                  color: sky,
                  baseOffset: const Offset(0.87, 0.5),
                  convergeT: convergeT,
                  size: scaledSize,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircle({
    required Color color,
    required Offset baseOffset,
    required double convergeT,
    required double size,
  }) {
    final radius = size * 0.32;
    final dx = baseOffset.dx * radius * (1 - convergeT);
    final dy = baseOffset.dy * radius * (1 - convergeT);
    final scale = 1.0 - (convergeT * 0.7);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size * 0.38,
          height: size * 0.38,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  double _easeInOut(double t) {
    return t < 0.5
        ? 2 * t * t
        : 1 - math.pow(-2 * t + 2, 2) / 2;
  }
}