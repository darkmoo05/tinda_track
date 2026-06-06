import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary & Secondary
  static const Color primary = Color(0xFF005DAC);
  static const Color primaryContainer = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF106D20); // Growth Green
  static const Color secondaryContainer = Color(0xFF9DF898);

  // Surface & Background
  static const Color background = Color(0xFFF9F9FC);
  static const Color surface = Color(0xFFF9F9FC);
  static const Color surfaceContainerLow = Color(0xFFF3F3F6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE8E8EA);
  static const Color outlineVariant = Color(0xFFC1C6D4);

  // Semantic
  static const Color error = Color(0xFFBA1A1A);
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF414752);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Wallet Brand Accents
  static const Color gcash = Color(0xFF005DAC);
  static const Color maya = Color(0xFF106D20);
  static const Color onHand = Color(0xFF8E6C00);
  static const Color onHandGold = Color(0xFFD4AF37);
  static const Color onHandLight = Color(0xFFFFF8E7);
  static const Color gcashNeon = Color(0xFF3D9BFF);
  static const Color mayaNeon = Color(0xFF39FF95);
  static const Color cashNeon = Color(0xFFFFD060);

  // Semantic Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successBorder = Color(0xFFC8E6C9);
  static const Color successMedium = Color(0xFF388E3C);
  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningOrange = Color(0xFFFF6B00);
  static const Color warningLight = Color(0xFFFFE0BD);
  static const Color warningContainer = Color(0xFFFFCC99);
  static const Color warningText = Color(0xFF8B4513);
  static const Color warningTextDark = Color(0xFF4A2C00);

  static const Color errorLight = Color(0xFFFF6B6B);
  static const Color errorDeep = Color(0xFFD32F2F);

  // Screen/Card specific custom tokens
  static const Color loginBackground = Color(0xFF0F0F12);
  static const Color loginSurface = Color(0xFF1E1E24);
  static const Color loginNeonCyan = Color(0xFF00E5FF);
  static const Color loginNeonPurple = Color(0xFF651FFF);

  static const Color tealAccent = Color(0xFF4DB6AC);
  static const Color tealLight = Color(0xFF80CBC4);

  static const Color cyanAccent = Color(0xFF00C9FF);
  static const Color softBlueBackground = Color(0xFFEBF3FF);
  static const Color lightGrey = Color(0xFFEEEEF0);
  static const Color lightBlueBackground = Color(0xFFF4F6FB);

  static const Color darkNavy = Color(0xFF0A1628);
  static const Color darkIndigo = Color(0xFF1C0E38);
  static const Color tooltipDark = Color(0xFF0D1F35);
  static const Color darkNavyTile = Color(0xFF1E3A5F);
  static const Color softNavy = Color(0xFF4A7EA6);

  // Banner colors
  static const Color bannerAmber = Color(0xFFFFA500);
  static const Color bannerOrange = Color(0xFFFF6B00);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onSurface: AppColors.onSurface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        displayMedium: GoogleFonts.manrope(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        headlineSmall: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurface,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
