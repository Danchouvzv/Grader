import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Button styles
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
    shadowColor: AppColors.primary.withOpacity(0.3),
  );

  static ButtonStyle get secondaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
    side: BorderSide(
      color: AppColors.primary.withOpacity(0.3),
      width: 1.5,
    ),
  );

  static ButtonStyle get successButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.success,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
    shadowColor: AppColors.success.withOpacity(0.3),
  );

  // Input styles
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.primary.withOpacity(0.2),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.primary.withOpacity(0.2),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.primary,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  // Card styles
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: AppColors.cardShadow,
    border: Border.all(
      color: AppColors.primary.withOpacity(0.1),
      width: 1,
    ),
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(24),
    boxShadow: AppColors.elevatedShadow,
    border: Border.all(
      color: AppColors.primary.withOpacity(0.1),
      width: 1,
    ),
  );

  // Divider styles
  static Widget get divider => Container(
    height: 1,
    color: AppColors.primary.withOpacity(0.1),
  );

  static Widget get thickDivider => Container(
    height: 2,
    color: AppColors.primary.withOpacity(0.15),
  );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
}
