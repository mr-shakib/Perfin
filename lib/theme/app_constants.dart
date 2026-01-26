import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class AppBorderRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double circle = 999.0;

  // Component-specific
  static const double button = 12.0;
  static const double card = 16.0;
  static const double dialog = 24.0;
  static const double input = 12.0;
  static const double fab = 18.0;
  static const double chip = 20.0;
}

class AppElevation {
  static const double none = 0.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 16.0;

  // Component-specific
  static const double card = 0.0; // Using borders instead
  static const double cardElevated = 4.0;
  static const double appBar = 0.0;
  static const double bottomNav = 8.0;
  static const double fab = 6.0;
  static const double dialog = 16.0;
  static const double snackbar = 4.0;
}

class AppShadows {
  // Light Mode Shadows
  static List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardElevatedLight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadowLight = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.24),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> fabShadowLight = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.32),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Dark Mode Shadows
  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.24),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardElevatedDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.32),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadowDark = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.32),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> fabShadowDark = [
    BoxShadow(
      color: AppColors.secondary.withOpacity(0.4),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppAnimations {
  // Duration
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);

  // Curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
  static const Curve emphasized = Curves.easeOutCubic;

  // Material 3 curves
  static const Curve standard = Cubic(0.4, 0, 0.2, 1);
  static const Curve decelerate = Cubic(0, 0, 0.2, 1);
  static const Curve accelerate = Cubic(0.4, 0, 1, 1);
}
