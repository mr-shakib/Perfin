import 'package:flutter/material.dart';

class AppColors {
  // Primary Swatch - Navy
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF303E50,
    <int, Color>{
      50: Color(0xFFF8F9FA),
      100: Color(0xFFE5E7EB),
      200: Color(0xFFD1D5DB),
      300: Color(0xFF9CA3AF),
      400: Color(0xFF6B7280),
      500: Color(0xFF303E50),
      600: Color(0xFF2D3748),
      700: Color(0xFF1F2937),
      800: Color(0xFF111827),
      900: Color(0xFF0A0F1A),
    },
  );

  // Secondary Swatch - Orange
  static const MaterialColor secondarySwatch = MaterialColor(
    0xFFFF7A4A,
    <int, Color>{
      50: Color(0xFFFFF5F0),
      100: Color(0xFFFFE8DC),
      200: Color(0xFFFFD1B9),
      300: Color(0xFFFFB896),
      400: Color(0xFFFF9A6A),
      500: Color(0xFFFF7A4A),
      600: Color(0xFFE65A2A),
      700: Color(0xFFCC4A1A),
      800: Color(0xFFB33A0A),
      900: Color(0xFF992A00),
    },
  );

  // Core Colors - Navy (Primary)
  static const Color primary = Color(0xFF303E50);
  static const Color primaryDark = Color(0xFF1F2937);
  static const Color primaryLight = Color(0xFF4A5568);

  // Orange (Secondary/Accent)
  static const Color secondary = Color(0xFFFF7A4A);
  static const Color secondaryDark = Color(0xFFE65A2A);
  static const Color secondaryLight = Color(0xFFFF9A6A);

  static const Color accent = Color(0xFFFF7A4A);
  static const Color accentDark = Color(0xFFE65A2A);
  static const Color accentLight = Color(0xFFFF9A6A);

  // Cream/Warm Backgrounds
  static const Color creamBackground = Color(0xFFFFF8DB);
  static const Color creamCard = Color(0xFFFFFCE2);
  static const Color creamLight = Color(0xFFFFFDF0);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF047857);
  static const Color successLight = Color(0xFF34D399);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFBBF24);

  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFF87171);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFF60A5FA);

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
    colors: [Color(0xFF303E50), Color(0xFF4A5568)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7A4A), Color(0xFFFF9A6A)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7A4A), Color(0xFFF59E0B)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF8DB)],
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
  );
}
