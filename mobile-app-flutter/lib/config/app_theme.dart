import 'package:flutter/material.dart';

// ── Brand Colors (mirrored from SwiftUI Theme.swift) ──
class AppColors {
  AppColors._();

  // Primary brand
  static const Color teal = Color(0xFF00B5B0);
  static const Color tealDark = Color(0xFF009490);
  static Color get tealLight => teal.withValues(alpha: 0.10);
  static Color get tealSubtle => teal.withValues(alpha: 0.06);

  // Backgrounds
  static const Color background = Color(0xFFF7F8F9);
  static const Color cardBackground = Colors.white;
  static const Color surface = Color(0xFFF9FAFB);

  // Text
  static const Color charcoal = Color(0xFF1A1C24);
  static const Color secondary = Color(0xFF707580);
  static const Color tertiary = Color(0xFF9EA0AD);

  // Dividers & borders
  static const Color divider = Color(0xFFEBEDEF);
  static const Color border = Color(0xFFE6E8ED);

  // Status
  static const Color online = Color(0xFF2ECC71);
  static const Color urgent = Color(0xFFF55747);
  static const Color verified = teal;

  // Accent
  static const Color amber = Color(0xFFF59E33);
  static const Color indigo = Color(0xFF6675F0);
  static const Color purple = Color(0xFF8F59F5);
  static const Color purpleDark = Color(0xFF7040DB);
}

// ── Spacing ──
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double sectionGap = 28;
}

// ── Radius ──
class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 100;
}

// ── Theme ──
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
      primary: AppColors.teal,
      onPrimary: Colors.white,
      surface: AppColors.cardBackground,
      error: AppColors.urgent,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.charcoal,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.tertiary, fontSize: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.teal),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.dark,
    ),
  );
}
