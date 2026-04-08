import 'package:flutter/material.dart';

/// Plagit brand colors — single source of truth.
class AppColors {
  AppColors._();

  // Primary
  static const Color teal = Color(0xFF2BB8B0);
  static const Color lightTeal = Color(0xFF5DDDD4);
  static const Color darkTeal = Color(0xFF1A9090);

  // Accent
  static const Color gold = Color(0xFFFFD700);
  static const Color navy = Color(0xFF0D3035);
  static const Color purple = Color(0xFF8B5CF6);

  // Backgrounds
  static const Color background = Color(0xFFF5F5F7);
  static const Color card = Colors.white;

  // Text
  static const Color charcoal = Color(0xFF1A1C24);
  static const Color secondary = Color(0xFF707580);
  static const Color tertiary = Color(0xFF9EA0AD);

  // Status
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color green = Color(0xFF10B981);

  // Utility
  static const Color divider = Color(0xFFEBEDEF);
  static const Color border = Color(0xFFE6E8ED);

  // Shadows
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.06),
    blurRadius: 12,
    offset: const Offset(0, 2),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [cardShadow],
  );
}
