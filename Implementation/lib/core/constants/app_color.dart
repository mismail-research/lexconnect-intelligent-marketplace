import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundColor = Color(0xFFE6F3FF);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color darkContrast = Color(0xFF253037);
  static const Color liteGery = Color(0xFF4D4D4D);
  static const Color lightGrey = Color(0xFF9E9E9E);
  static const Color liteBlue = Color(0xFF2196F3);
  static const Color amberColor = Color(0xFFFFBF00);

  static const Color blackColor = Color(0xFF0F172A);
  static const Color redColor = Color(0xFFEF4444);
  static const Color purpleColor = Color(0xFF9C27B0);
  static const Color litePurple = Color(0xFF83809B);

  static const Color successBackground = Color(0xFFE6F9F0);
  static const Color darkGreen = Color(0xFF064E3B);
  static const Color liteGreen = Color(0xFF22C55E);
  static const Color textPrimary = Color(0xFF040404);
  static const Color borderColor = Color(0xFF2A7B9B);
  static const Color liteBlack = Color(0xFF1E293B);

  static const List<Color> buttonGradient = [
    Color(0xFF253037),
    Color(0xFF2A7B9B),
  ];
  static const List<Color> buttonGradient1 = [
    Color(0xFF133001),
    Color(0xFF2196F3),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF253037), Color(0xFF2A7B9B)],
  );

  // Gradient 2: Darker (Maybe for specific accents)
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF253037), Color(0xFF000000)],
  );
}
