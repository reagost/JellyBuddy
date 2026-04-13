import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDurations {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);
}

class AppCurves {
  static const Curve standard = Curves.easeInOut;
  static const Curve decelerate = Curves.easeOut;
  static const Curve accelerate = Curves.easeIn;
  static const Curve elastic = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
}

class AppDecorations {
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(24));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(12));

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
