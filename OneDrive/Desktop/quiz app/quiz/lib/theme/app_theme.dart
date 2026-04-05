// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Deep Navy Corporate
  static const Color primary = Color(0xFF0A1628);
  static const Color primaryLight = Color(0xFF1A2E4A);
  static const Color primaryDark = Color(0xFF050D1A);

  // Accent - Electric Blue
  static const Color accent = Color(0xFF2563EB);
  static const Color accentLight = Color(0xFF3B82F6);
  static const Color accentGlow = Color(0xFF60A5FA);

  // Secondary Accent - Gold
  static const Color gold = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFBBF24);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);

  // Neutral Shades
  static const Color surface = Color(0xFF0F1F36);
  static const Color surfaceElevated = Color(0xFF162840);
  static const Color surfaceCard = Color(0xFF1C3252);
  static const Color border = Color(0xFF243B55);
  static const Color borderLight = Color(0xFF2D4A6B);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Difficulty Colors
  static const Color easy = Color(0xFF10B981);
  static const Color medium = Color(0xFFF59E0B);
  static const Color hard = Color(0xFFEF4444);
  static const Color expert = Color(0xFF8B5CF6);

  // Category Colors
  static const List<Color> categoryGradients = [
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFFDC2626),
    Color(0xFFD97706),
    Color(0xFF0891B2),
  ];
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.gold,
        surface: AppColors.surface,
        background: AppColors.primary,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.primary,
      fontFamily: 'Outfit',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentLight,
          textStyle: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -1),
        displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5),
        displaySmall: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.6),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary),
        labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            letterSpacing: 0.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.textMuted, fontFamily: 'Outfit'),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.accent.withOpacity(0.3),
        labelStyle: TextStyle(
            fontFamily: 'Outfit', fontSize: 13, color: AppColors.textSecondary),
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textMuted,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        labelStyle:
            TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w400),
      ),
    );
  }
}
