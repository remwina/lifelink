import 'package:flutter/material.dart';
import 'theme.dart';

extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get colorBackground =>
      isDark ? AppColors.backgroundDark : AppColors.background;

  Color get colorSurface =>
      isDark ? AppColors.surfaceDark : AppColors.surface;

  Color get colorSurfaceAlt =>
      isDark ? AppColors.surfaceAltDark : AppColors.surfaceAlt;

  Color get colorTextPrimary =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

  Color get colorTextSecondary =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

  Color get colorTextMuted =>
      isDark ? AppColors.textMutedDark : AppColors.textMuted;

  Color get colorBorder =>
      isDark ? AppColors.borderDark : AppColors.border;

  Color get colorPrimaryLight =>
      isDark ? AppColors.primaryLightDark : AppColors.primaryLight;

  Color get colorLevelBg =>
      isDark ? AppColors.levelBgDark : AppColors.levelBg;
}
