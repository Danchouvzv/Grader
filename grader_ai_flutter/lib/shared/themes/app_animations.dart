import 'package:flutter/material.dart';

class AppAnimations {
  // Page transitions
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Scale animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide in from bottom
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = normal,
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 1.0, end: 0.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 100 * value),
          child: child,
        );
      },
      child: child,
    );
  }

  // Pulse animation
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 1.0, end: 1.1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Shake animation
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final shake = value * 10 * (1 - value);
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Bounce animation
  static Widget bounce({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final bounce = value < 0.5
            ? 2 * value * value
            : 1 - 2 * (value - 1) * (value - 1);
        return Transform.translate(
          offset: Offset(0, -20 * bounce),
          child: child,
        );
      },
      child: child,
    );
  }

  // Staggered children animation
  static List<Widget> staggeredChildren({
    required List<Widget> children,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = normal,
    Curve curve = Curves.easeOutCubic,
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      
      return TweenAnimationBuilder<double>(
        duration: duration + (delay * index),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: curve,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: child,
      );
    }).toList();
  }
}
