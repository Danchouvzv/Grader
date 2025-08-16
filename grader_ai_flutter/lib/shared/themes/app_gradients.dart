import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  // Primary gradients
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryVertical = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryRadial = RadialGradient(
    colors: [AppColors.primaryLight, AppColors.primary],
    center: Alignment.center,
    radius: 1.0,
  );

  // Success gradients
  static const LinearGradient success = LinearGradient(
    colors: [AppColors.success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successVertical = LinearGradient(
    colors: [AppColors.success, Color(0xFF34D399)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Warning gradients
  static const LinearGradient warning = LinearGradient(
    colors: [AppColors.warning, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Error gradients
  static const LinearGradient error = LinearGradient(
    colors: [AppColors.error, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Info gradients
  static const LinearGradient info = LinearGradient(
    colors: [AppColors.info, Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark gradients
  static const LinearGradient dark = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF374151)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkVertical = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF374151)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Light gradients
  static const LinearGradient light = LinearGradient(
    colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass morphism gradients
  static const LinearGradient glass = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sunset gradients
  static const LinearGradient sunset = LinearGradient(
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
      Color(0xFFFF8E53),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ocean gradients
  static const LinearGradient ocean = LinearGradient(
    colors: [
      Color(0xFF667EEA),
      Color(0xFF764BA2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Forest gradients
  static const LinearGradient forest = LinearGradient(
    colors: [
      Color(0xFF11998E),
      Color(0xFF38EF7D),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Fire gradients
  static const LinearGradient fire = LinearGradient(
    colors: [
      Color(0xFFFF416C),
      Color(0xFFFF4B2B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sky gradients
  static const LinearGradient sky = LinearGradient(
    colors: [
      Color(0xFF56CCF2),
      Color(0xFF2F80ED),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Purple gradients
  static const LinearGradient purple = LinearGradient(
    colors: [
      Color(0xFF667EEA),
      Color(0xFF764BA2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Orange gradients
  static const LinearGradient orange = LinearGradient(
    colors: [
      Color(0xFFFF9A9E),
      Color(0xFFFECFEF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Green gradients
  static const LinearGradient green = LinearGradient(
    colors: [
      Color(0xFFA8EDEA),
      Color(0xFFFED6E3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Blue gradients
  static const LinearGradient blue = LinearGradient(
    colors: [
      Color(0xFFA8CABA),
      Color(0xFF5D4E75),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Red gradients
  static const LinearGradient red = LinearGradient(
    colors: [
      Color(0xFFFF9A9E),
      Color(0xFFFAD0C4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Yellow gradients
  static const LinearGradient yellow = LinearGradient(
    colors: [
      Color(0xFFFFECD2),
      Color(0xFFFCB69F),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Pink gradients
  static const LinearGradient pink = LinearGradient(
    colors: [
      Color(0xFFA8EDEA),
      Color(0xFFFED6E3),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Teal gradients
  static const LinearGradient teal = LinearGradient(
    colors: [
      Color(0xFF84FAB0),
      Color(0xFF8FD3F4),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Indigo gradients
  static const LinearGradient indigo = LinearGradient(
    colors: [
      Color(0xFFA18CD1),
      Color(0xFFFBC2EB),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Custom gradient creator
  static LinearGradient custom({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }

  // Radial gradient creator
  static RadialGradient customRadial({
    required List<Color> colors,
    Alignment center = Alignment.center,
    double radius = 1.0,
  }) {
    return RadialGradient(
      colors: colors,
      center: center,
      radius: radius,
    );
  }
}
