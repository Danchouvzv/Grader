import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/themes/design_system.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
        splashColor: color.withOpacity(0.12),
        highlightColor: color.withOpacity(0.06),
        child: Container(
          decoration: BoxDecoration(
            color: DesignSystem.surface,
            borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
            border: Border.all(
              color: color.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: DesignSystem.cardShadow,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.space16.w,
            vertical: DesignSystem.space20.h,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.12),
                      color.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 24.w),
              ),
              SizedBox(height: DesignSystem.space12.h),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: DesignSystem.headlineMedium.copyWith(
                      fontSize: 22.sp,
                      color: DesignSystem.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(height: DesignSystem.space8.h),
              Text(
                label,
                style: DesignSystem.caption.copyWith(
                  color: DesignSystem.textSecondary,
                  fontSize: 13.sp,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


