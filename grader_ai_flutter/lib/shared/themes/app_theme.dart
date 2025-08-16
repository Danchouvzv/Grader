import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_styles.dart';

class AppTheme {
  // Light theme
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    
    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.headlineMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      iconTheme: IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    ),
    
    // Scaffold theme
    scaffoldBackgroundColor: AppColors.background,
    
    // Card theme
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: AppColors.cardShadow.first.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppStyles.primaryButton,
    ),
    
    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppStyles.secondaryButton,
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
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
    ),
    
    // Icon theme
    iconTheme: IconThemeData(
      color: AppColors.textSecondary,
      size: 24,
    ),
    
    // Text theme
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      displaySmall: AppTypography.displaySmall,
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    ),
    
    // Divider theme
    dividerTheme: DividerThemeData(
      color: AppColors.primary.withOpacity(0.1),
      thickness: 1,
      space: 1,
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primary.withOpacity(0.1),
      selectedColor: AppColors.primary,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.primary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Progress indicator theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.primary.withOpacity(0.1),
      circularTrackColor: AppColors.primary.withOpacity(0.1),
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Navigation rail theme
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.surface,
      selectedIconTheme: IconThemeData(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: AppColors.textTertiary),
      selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.primary,
      ),
      unselectedLabelTextStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.textTertiary,
      ),
    ),
    
    // Floating action button theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Snack bar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // Dialog theme
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surface,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: AppTypography.headlineMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
    
    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: 24,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
    ),
    
    // Popup menu theme
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: AppTypography.labelMedium.copyWith(
        color: Colors.white,
      ),
    ),
    
    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textTertiary;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary.withOpacity(0.3);
        }
        return AppColors.textTertiary.withOpacity(0.3);
      }),
    ),
    
    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    
    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textTertiary;
      }),
    ),
    
    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.primary.withOpacity(0.3),
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withOpacity(0.2),
    ),
  );

  // Dark theme
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    
    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.textPrimary,
      foregroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.headlineMedium.copyWith(
        color: AppColors.surface,
      ),
      iconTheme: IconThemeData(
        color: AppColors.surface,
        size: 24,
      ),
    ),
    
    // Scaffold theme
    scaffoldBackgroundColor: AppColors.textPrimary,
    
    // Card theme
    cardTheme: CardTheme(
      color: AppColors.textPrimary,
      elevation: 0,
      shadowColor: AppColors.cardShadow.first.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppStyles.primaryButton,
    ),
    
    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppStyles.secondaryButton.copyWith(
        backgroundColor: MaterialStateProperty.all(AppColors.textPrimary),
        foregroundColor: MaterialStateProperty.all(AppColors.primaryLight),
        side: MaterialStateProperty.all(
          BorderSide(color: AppColors.primaryLight.withOpacity(0.3)),
        ),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.textPrimary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryLight.withOpacity(0.2),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryLight.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryLight,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    // Icon theme
    iconTheme: IconThemeData(
      color: AppColors.surface,
      size: 24,
    ),
    
    // Text theme
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.surface,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.surface,
      ),
      displaySmall: AppTypography.displaySmall.copyWith(
        color: AppColors.surface,
      ),
      headlineLarge: AppTypography.headlineLarge.copyWith(
        color: AppColors.surface,
      ),
      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: AppColors.surface,
      ),
      headlineSmall: AppTypography.headlineSmall.copyWith(
        color: AppColors.surface,
      ),
      titleLarge: AppTypography.titleLarge.copyWith(
        color: AppColors.surface,
      ),
      titleMedium: AppTypography.titleMedium.copyWith(
        color: AppColors.surface,
      ),
      titleSmall: AppTypography.titleSmall.copyWith(
        color: AppColors.surface,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(
        color: AppColors.surface,
      ),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: AppColors.surface.withOpacity(0.8),
      ),
      bodySmall: AppTypography.bodySmall.copyWith(
        color: AppColors.surface.withOpacity(0.6),
      ),
      labelLarge: AppTypography.labelLarge.copyWith(
        color: AppColors.surface,
      ),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.surface.withOpacity(0.8),
      ),
      labelSmall: AppTypography.labelSmall.copyWith(
        color: AppColors.surface.withOpacity(0.6),
      ),
    ),
    
    // Divider theme
    dividerTheme: DividerThemeData(
      color: AppColors.surface.withOpacity(0.1),
      thickness: 1,
      space: 1,
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primaryLight.withOpacity(0.1),
      selectedColor: AppColors.primaryLight,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.primaryLight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Progress indicator theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearTrackColor: AppColors.primaryLight.withOpacity(0.1),
      circularTrackColor: AppColors.primaryLight.withOpacity(0.1),
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.textPrimary,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.surface.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Navigation rail theme
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.textPrimary,
      selectedIconTheme: IconThemeData(color: AppColors.primaryLight),
      unselectedIconTheme: IconThemeData(color: AppColors.surface.withOpacity(0.6)),
      selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.primaryLight,
      ),
      unselectedLabelTextStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.surface.withOpacity(0.6),
      ),
    ),
    
    // Floating action button theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Snack bar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // Dialog theme
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.textPrimary,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: AppTypography.headlineMedium.copyWith(
        color: AppColors.surface,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.surface.withOpacity(0.8),
      ),
    ),
    
    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.textPrimary,
      elevation: 24,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
    ),
    
    // Popup menu theme
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.textPrimary,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.textPrimary,
      ),
    ),
    
    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.surface.withOpacity(0.6);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryLight.withOpacity(0.3);
        }
        return AppColors.surface.withOpacity(0.3);
      }),
    ),
    
    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(AppColors.textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    
    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.surface.withOpacity(0.6);
      }),
    ),
    
    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primaryLight,
      inactiveTrackColor: AppColors.primaryLight.withOpacity(0.3),
      thumbColor: AppColors.primaryLight,
      overlayColor: AppColors.primaryLight.withOpacity(0.2),
    ),
  );
}
