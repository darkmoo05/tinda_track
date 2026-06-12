import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryContainer = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF059669); // Emerald Growth Green
  static const Color secondaryContainer = Color(0xFF10B981);

  // Surface & Background
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0); // Slate 200
  static const Color outlineVariant = Color(0xFFCBD5E1); // Slate 300

  // Semantic
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color onSurface = Color(0xFF0F172A); // Slate 900
  static const Color onSurfaceVariant = Color(0xFF475569); // Slate 600
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Wallet Brand Accents (Specific to GCash/Maya/Cash for branding accuracy)
  static const Color gcash = Color(0xFF005DAC);
  static const Color maya = Color(0xFF106D20);
  static const Color onHand = Color(0xFF8E6C00);
  static const Color onHandGold = Color(0xFFD4AF37);
  static const Color onHandLight = Color(0xFFFFF8E7);
  static const Color gcashNeon = Color(0xFF3D9BFF);
  static const Color mayaNeon = Color(0xFF39FF95);
  static const Color cashNeon = Color(0xFFFFD060);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);
  static const Color successMedium = Color(0xFF059669);
  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningOrange = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningContainer = Color(0xFFFDE68A);
  static const Color warningText = Color(0xFF92400E);
  static const Color warningTextDark = Color(0xFF78350F);

  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDeep = Color(0xFFB91C1C);

  // Screen/Card specific custom tokens (Enhanced for Web3 Midnight Mode)
  static const Color loginBackground = Color(0xFF0B0F19); // Midnight Blue Background
  static const Color loginSurface = Color(0xFF161D30); // Midnight Card Surface
  static const Color loginNeonCyan = Color(0xFF00E5FF);
  static const Color loginNeonPurple = Color(0xFF651FFF);

  static const Color tealAccent = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFFCCFBF1);

  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color softBlueBackground = Color(0xFFEFF6FF);
  static const Color lightGrey = Color(0xFFF1F5F9);
  static const Color lightBlueBackground = Color(0xFFEFF6FF);

  static const Color darkNavy = Color(0xFF0B0F19); // Midnight Blue Background
  static const Color darkIndigo = Color(0xFF161D30); // Midnight Card Surface
  static const Color tooltipDark = Color(0xFF1E293B); // Slate 800
  static const Color darkNavyTile = Color(0xFF1E293B);
  static const Color softNavy = Color(0xFF475569);

  // Banner colors
  static const Color bannerAmber = Color(0xFFF59E0B);
  static const Color bannerOrange = Color(0xFFD97706);
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
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.onSurface,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
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

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        surface: AppColors.darkIndigo,
        error: AppColors.error,
        onSurface: const Color(0xFFF8FAFC),
      ),
      scaffoldBackgroundColor: AppColors.darkNavy,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF8FAFC),
        ),
        displayMedium: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF8FAFC),
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFFF8FAFC),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFFF8FAFC),
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF94A3B8),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkIndigo,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
