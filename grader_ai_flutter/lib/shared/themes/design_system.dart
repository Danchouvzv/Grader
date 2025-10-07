import 'package:flutter/material.dart';

/// Централизованная система дизайна
/// Premium UI с белым фоном и современными акцентами
class DesignSystem {
  // ============ ЦВЕТОВАЯ ПАЛИТРА ============
  
  /// Основные синие оттенки (базовые)
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue50 = Color(0xFFEFF6FF);
  
  /// Фиолетовые оттенки (акцентные для креативности)
  static const Color purple600 = Color(0xFF9333EA);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple400 = Color(0xFFC084FC);
  static const Color purple50 = Color(0xFFFAF5FF);
  
  /// Красные/Розовые оттенки (акцентные)
  static const Color accentRed = Color(0xFFF43F5E);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red500 = Color(0xFFEF4444);
  static const Color pink500 = Color(0xFFEC4899);
  static const Color pink400 = Color(0xFFF472B6);
  static const Color red50 = Color(0xFFFEF2F2);
  
  /// Зеленые оттенки (для успеха и прогресса)
  static const Color green600 = Color(0xFF059669);
  static const Color green500 = Color(0xFF10B981);
  static const Color green400 = Color(0xFF34D399);
  static const Color green50 = Color(0xFFECFDF5);
  
  /// Янтарные оттенки (для энергии и streak)
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color orange500 = Color(0xFFF97316);
  
  /// Фоны и поверхности
  static const Color background = Color(0xFFFFFFFF); // Чистый белый
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceGray = Color(0xFFF5F5F5);
  
  /// Текст
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  /// Границы и разделители
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFE2E8F0);
  
  // ============ ГРАДИЕНТЫ ============
  
  /// Градиент для хедера (синий + фиолетовый)
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue600, blue500, purple500],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Градиент для streak метрики (теплый)
  static const LinearGradient streakGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber500, orange500],
  );
  
  /// Градиент для target score (прохладный синий)
  static const LinearGradient targetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue500, purple500],
  );
  
  /// Градиент для CTA кнопок (яркий розово-красный)
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [pink500, accentRed],
  );
  
  /// Градиент для прогресса (зеленый успех)
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [green600, green400],
  );
  
  /// Градиент фона (очень легкий, почти белый)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
  );
  
  /// Стеклянный эффект
  static LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.9),
      Colors.white.withOpacity(0.7),
    ],
  );
  
  // ============ SPACING SCALE ============
  
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  
  // ============ BORDER RADIUS ============
  
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  
  // ============ ТЕНИ ============
  
  /// Очень мягкая тень для карточек (нейтральная)
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 24,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 12,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Средняя тень для приподнятых элементов
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 32,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  /// Цветная тень для синих элементов
  static List<BoxShadow> blueShadow = [
    BoxShadow(
      color: blue500.withOpacity(0.2),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  /// Цветная тень для розовых элементов
  static List<BoxShadow> pinkShadow = [
    BoxShadow(
      color: pink500.withOpacity(0.25),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  /// Цветная тень для фиолетовых элементов
  static List<BoxShadow> purpleShadow = [
    BoxShadow(
      color: purple500.withOpacity(0.2),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  /// Цветная тень для янтарных элементов
  static List<BoxShadow> amberShadow = [
    BoxShadow(
      color: amber500.withOpacity(0.25),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  /// Стеклянная тень (для элементов с glassMorphism)
  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
  
  // ============ ТИПОГРАФИКА ============
  
  /// Крупный заголовок (имя пользователя)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.8,
  );
  
  /// Средний заголовок (секции)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.5,
  );
  
  /// Средний заголовок
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );
  
  /// Маленький заголовок
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );
  
  /// Основной текст
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  
  /// Средний текст
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  
  /// Маленький текст
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  /// Подписи (Caption)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.2,
  );
  
  /// Метки (Labels)
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.8,
  );
  
  /// Числовые значения (для метрик)
  static const TextStyle metric = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  /// Подзаголовки метрик
  static const TextStyle metricLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.3,
  );
  
  // ============ ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ============
  
  /// Создает стандартную карточку с тенью
  static BoxDecoration cardDecoration({
    Color? color,
    List<BoxShadow>? shadow,
    double? radius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius ?? radiusLarge),
      border: border,
      boxShadow: shadow ?? cardShadow,
    );
  }
  
  /// Создает стеклянную карточку (для использования на цветном фоне)
  static BoxDecoration glassDecoration({double? radius}) {
    return BoxDecoration(
      gradient: glassGradient,
      borderRadius: BorderRadius.circular(radius ?? radiusMedium),
      border: Border.all(
        color: Colors.white.withOpacity(0.4),
        width: 1.5,
      ),
      boxShadow: glassShadow,
    );
  }
  
  /// Создает градиентную карточку
  static BoxDecoration gradientDecoration({
    required LinearGradient gradient,
    double? radius,
    List<BoxShadow>? shadow,
    Border? border,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius ?? radiusLarge),
      border: border,
      boxShadow: shadow ?? cardShadow,
    );
  }
}

