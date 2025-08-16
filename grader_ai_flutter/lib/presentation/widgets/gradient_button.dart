import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color> gradientColors;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isOutlined;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradientColors = const [Color(0xFF1976D2), Color(0xFF1565C0)],
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.isOutlined = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: widget.width ?? double.infinity,
                height: widget.height ?? 56.h,
                decoration: BoxDecoration(
                  gradient: widget.isOutlined 
                      ? null 
                      : LinearGradient(colors: widget.gradientColors),
                  border: widget.isOutlined 
                      ? Border.all(
                          color: widget.gradientColors.first,
                          width: 2,
                        ) 
                      : null,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: widget.isOutlined 
                      ? null 
                      : [
                          BoxShadow(
                            color: widget.gradientColors.first.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28.r),
                    onTap: null, // Handled by GestureDetector
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.textColor ?? 
                                  (widget.isOutlined 
                                      ? widget.gradientColors.first 
                                      : Colors.white),
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: widget.textColor ?? 
                                  (widget.isOutlined 
                                      ? widget.gradientColors.first 
                                      : Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
