import 'package:flutter/material.dart';

class AppColors {
  // Primary Swatch
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF4A69BD,
    <int, Color>{
      50: Color(0xFFEEF2FC),
      100: Color(0xFFD6DFF8),
      200: Color(0xFFB3C0F0),
      300: Color(0xFF8FA0E3),
      400: Color(0xFF6B84D0),
      500: Color(0xFF4A69BD),
      600: Color(0xFF3F5982),
      700: Color(0xFF2D4263),
      800: Color(0xFF1B2B44),
      900: Color(0xFF0A1628),
    },
  );

  // Secondary Swatch
  static const MaterialColor secondarySwatch = MaterialColor(
    0xFF7C3AED,
    <int, Color>{
      50: Color(0xFFF5EBFE),
      100: Color(0xFFE9D5FD),
      200: Color(0xFFD4A7FA),
      300: Color(0xFFB883F7),
      400: Color(0xFF9D5FF2),
      500: Color(0xFF7C3AED),
      600: Color(0xFF664393),
      700: Color(0xFF4A2C6D),
      800: Color(0xFF2E1A47),
      900: Color(0xFF1A0B2E),
    },
  );

  // Core Colors
  static const Color primary = Color(0xFF4A69BD);
  static const Color primaryDark = Color(0xFF2D4263);
  static const Color primaryLight = Color(0xFF8FA0E3);

  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryDark = Color(0xFF4A2C6D);
  static const Color secondaryLight = Color(0xFFB883F7);

  static const Color accent = Color(0xFFF59E0B);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF047857);
  static const Color successLight = Color(0xFF34D399);

  static const Color warning = Color(0xFFF97316);
  static const Color warningDark = Color(0xFFC2410C);
  static const Color warningLight = Color(0xFFFB923C);

  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color errorLight = Color(0xFFF87171);

  // Neutrals - Light Mode
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral950 = Color(0xFF0A0A0A);

  // Dark Mode Backgrounds
  static const Color dark50 = Color(0xFF0A0A0A);
  static const Color dark100 = Color(0xFF171717);
  static const Color dark200 = Color(0xFF262626);
  static const Color dark300 = Color(0xFF404040);
  static const Color dark400 = Color(0xFF525252);
  static const Color dark600 = Color(0xFFA3A3A3);
  static const Color dark700 = Color(0xFFD4D4D4);
  static const Color dark800 = Color(0xFFE5E5E5);
  static const Color dark900 = Color(0xFFF5F5F5);
  static const Color dark950 = Color(0xFFFAFAFA);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A69BD), Color(0xFF7C3AED)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFB883F7)],
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFEEF2FC)],
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0A), Color(0xFF0A1628)],
  );
}
