import 'package:flutter/material.dart';

class AppColors {
  // Base backgrounds (Off-White & Clean Light)
  static const Color background = Color(0xFFF7F7F2); // Main Off-White
  static const Color backgroundSecondary = Color(0xFFEFEFEA);
  static const Color surface = Color(0xFFFFFFFF); // Card Background White
  static const Color surfaceElevated = Color(0xFFF3F4ED);
  static const Color surfaceLight = Color(0xFFEBECE3);
  static const Color surfaceHighlight = Color(0xFFDFE1D5);

  // Olive Palette Accents
  static const Color primary = Color(0xFF667A3E); // Olive Green
  static const Color primaryDark = Color(0xFF4F6030); // Dark Olive
  static const Color primaryLight = Color(0xFF8B9A62); // Light Olive
  static const Color accentCyan = Color(0xFF4F6030); // Dark Olive Accent
  static const Color accentIndigo = Color(0xFF4F6030);

  // Status & Severity
  static const Color success = Color(0xFF388E3C); // Forest Green
  static const Color warning = Color(0xFFE65100); // Warm Amber
  static const Color error = Color(0xFFD32F2F); // SOS/Emergency Red
  static const Color critical = Color(0xFFD32F2F); // SOS/Emergency Red
  static const Color info = Color(0xFF667A3E); // Olive

  // Typography
  static const Color textPrimary = Color(0xFF1F2618); // Dark Charcoal
  static const Color textSecondary = Color(0xFF6B705C);
  static const Color textMuted = Color(0xFF9A9A91); // Disabled/Inactive
  static const Color textCyan = Color(0xFF4F6030);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E4D8); // Divider/Border
  static const Color borderLight = Color(0xFFECEEE4);
  static const Color borderActive = Color(0xFF667A3E);
  static const Color disabled = Color(0xFF9A9A91);

  // Common
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Overlays
  static Color glassBackground = const Color(0xFFFFFFFF).withValues(alpha: 0.90);
  static Color glassBorder = const Color(0xFFE2E4D8);
  static Color primaryGlow = const Color(0xFF667A3E).withValues(alpha: 0.15);
}
