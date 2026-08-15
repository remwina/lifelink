import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color tokens (from prototype CSS :root) ──────────────────────────────────
class AppColors {
  AppColors._();

  // Primary brand
  static const Color primary = Color(0xFFE53935);       // --color-primary
  static const Color primaryLight = Color(0xFFFFEBEE);  // --color-primary-light
  static const Color primaryDark = Color(0xFFC62828);   // --color-primary-dark
  static const Color primaryLightDark = Color(0xFF4A1518); // dark variant of primaryLight

  // Neutrals - Light Mode
  static const Color background = Color(0xFFF5F0EB);    // --color-bg
  static const Color surface = Color(0xFFFFFFFF);       // --color-surface
  static const Color surfaceAlt = Color(0xFFFAF7F4);    // --color-surface-alt

  // Neutrals - Dark Mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceAltDark = Color(0xFF2A2A2A);

  // Text - Light Mode
  static const Color textPrimary = Color(0xFF1A1A1A);   // --color-text-primary
  static const Color textSecondary = Color(0xFF6B6B6B); // --color-text-secondary
  static const Color textMuted = Color(0xFF9E9E9E);     // --color-text-muted

  // Text - Dark Mode
  static const Color textPrimaryDark = Color(0xFFE5E5E5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textMutedDark = Color(0xFF757575);

  // Borders
  static const Color border = Color(0xFFE8E0D8);        // --color-border
  static const Color borderDark = Color(0xFF333333);

  // Status / semantic
  static const Color success = Color(0xFF2E7D32);       // --color-success
  static const Color successLight = Color(0xFFE8F5E9);  // --color-success-light
  static const Color successDark = Color(0xFF1B5E20);
  static const Color successLightDark = Color(0xFF2E4A2E);
  
  static const Color warning = Color(0xFFF57F17);       // --color-warning
  static const Color warningLight = Color(0xFFFFF8E1);  // --color-warning-light
  static const Color warningDark = Color(0xFFF57F17);
  static const Color warningLightDark = Color(0xFF3D3320);
  
  static const Color danger = Color(0xFFB71C1C);        // --color-danger
  static const Color dangerLight = Color(0xFFFFEBEE);   // --color-danger-light
  static const Color dangerDark = Color(0xFFCF6679);
  static const Color dangerLightDark = Color(0xFF3A2020);

  // Blood supply levels
  static const Color levelHigh = Color(0xFF43A047);     // ≥ 50 %
  static const Color levelMid = Color(0xFFFFA726);      // 20–49 %
  static const Color levelLow = Color(0xFFE53935);      // < 20 %
  static const Color levelBg = Color(0xFFEEEEEE);       // empty bar bg
  static const Color levelBgDark = Color(0xFF2A2A2A);

  // Accent
  static const Color accent = Color(0xFFFF6F00);        // --color-accent (streak)
}

// ── Text styles ───────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(BuildContext context) =>
      GoogleFonts.dmSerifDisplay(fontSize: 28, color: AppColors.textPrimary);

  static TextStyle headlineLarge(BuildContext context) =>
      GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle headlineMedium(BuildContext context) =>
      GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle headlineSmall(BuildContext context) =>
      GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  static TextStyle bodySmall(BuildContext context) =>
      GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textMuted);

  static TextStyle labelLarge(BuildContext context) =>
      GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static TextStyle labelSmall(BuildContext context) =>
      GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5);
}

// ── ThemeData ─────────────────────────────────────────────────────────────────
ThemeData buildAppTheme({bool isDark = false}) {
  final colorScheme = isDark
      ? const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimaryDark,
          error: AppColors.dangerDark,
          background: AppColors.backgroundDark,
        )
      : const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.danger,
        );

  final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
  final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
  final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
  final borderColor = isDark ? AppColors.borderDark : AppColors.border;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: bgColor,
    appBarTheme: AppBarTheme(
      backgroundColor: bgColor,
      foregroundColor: textColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: isDark ? AppColors.textMutedDark : AppColors.textMuted,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: DividerThemeData(color: borderColor, space: 1),
    textTheme: GoogleFonts.dmSansTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ),
  );
}
