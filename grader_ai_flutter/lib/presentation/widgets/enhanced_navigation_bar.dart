import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';

class EnhancedNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;
  
  const EnhancedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<EnhancedNavigationBar> createState() => _EnhancedNavigationBarState();
}

class _EnhancedNavigationBarState extends State<EnhancedNavigationBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 0.8, end: 1.0)
            .animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut)))
        .toList();

    _slideAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 20.0, end: 0.0)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack)))
        .toList();

    // Animate current item
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(EnhancedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset previous animation
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      // Start new animation
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.elevatedShadow,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == widget.currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap(index);
              },
              child: AnimatedBuilder(
                animation: _animationControllers[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimations[index].value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimations[index].value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon with animated background
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                item.icon,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Label
                            Text(
                              item.label,
                              style: AppTypography.labelSmall.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const NavigationItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

// Floating Action Navigation Button
class FloatingNavButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color? color;
  final bool isExpanded;

  const FloatingNavButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    this.color,
    this.isExpanded = false,
  });

  @override
  State<FloatingNavButton> createState() => _FloatingNavButtonState();
}

class _FloatingNavButtonState extends State<FloatingNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isExpanded ? 20 : 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color ?? AppColors.primary,
                      (widget.color ?? AppColors.primary).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(widget.isExpanded ? 24 : 28),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.color ?? AppColors.primary).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                    if (widget.isExpanded) ...[
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Quick Action Button
class QuickActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final bool isCompact;

  const QuickActionButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: isCompact ? 20 : 24,
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
