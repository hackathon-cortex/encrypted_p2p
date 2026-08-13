import 'package:flutter/material.dart';

class AppColors {
  // Base backgrounds
  static const Color background = Color(0xFF070B11);
  static const Color backgroundSecondary = Color(0xFF0B101A);
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceElevated = Color(0xFF162032);
  static const Color surfaceLight = Color(0xFF1E293B);
  static const Color surfaceHighlight = Color(0xFF27354E);

  // Brand Accents
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accentCyan = Color(0xFF06B6D4); // Cyber Cyan
  static const Color accentIndigo = Color(0xFF6366F1);

  // Status & Severity
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Crimson
  static const Color critical = Color(0xFFDC2626); // Deep Red
  static const Color info = Color(0xFF0EA5E9); // Sky Blue

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textCyan = Color(0xFF38BDF8);

  // Borders & Dividers
  static const Color border = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFF334155);
  static const Color borderActive = Color(0xFF3B82F6);

  // Common
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Glassmorphism overlays
  static Color glassBackground = const Color(0xFF0F172A).withValues(alpha: 0.75);
  static Color glassBorder = const Color(0xFF334155).withValues(alpha: 0.5);
  static Color primaryGlow = const Color(0xFF2563EB).withValues(alpha: 0.2);
}
