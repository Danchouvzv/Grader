import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors - Professional & Trustworthy
  static const Color primary = Color(0xFF1E3A8A); // Deep professional blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E40AF);
  
  // Secondary colors
  static const Color secondary = Color(0xFF10B981); // Success green
  static const Color accent = Color(0xFFF59E0B); // Warm accent
  
  // Neutral colors - Clean & Professional
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB); // Light gray border
  
  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // IELTS Band colors
  static const Color bandExcellent = Color(0xFF059669); // 8.5-9.0
  static const Color bandGood = Color(0xFF10B981);     // 7.0-8.0
  static const Color bandCompetent = Color(0xFF3B82F6); // 6.0-6.5
  static const Color bandLimited = Color(0xFFF59E0B);   // 5.0-5.5
  static const Color bandPoor = Color(0xFFEF4444);      // Below 5.0
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1F2937).withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1F2937).withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF1F2937).withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF1F2937).withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
