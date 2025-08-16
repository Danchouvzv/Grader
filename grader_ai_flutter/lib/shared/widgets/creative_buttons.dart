import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreativeButtons {
  // 🚀 Креативная MVP кнопка с градиентом и анимацией
  static Widget mvpButton({
    required VoidCallback onTap,
    required String title,
    required String description,
    required IconData icon,
    required List<String> features,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                  const Color(0xFFf093fb),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFF764ba2).withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24.r),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onTap();
                },
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      // Animated icon with glow effect
                      Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated background circles
                            ...List.generate(3, (index) {
                              return Positioned(
                                left: 8 + (index * 8),
                                top: 8 + (index * 8),
                                child: Container(
                                  width: 16.w,
                                  height: 16.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }),
                            // Main icon
                            Icon(
                              icon,
                              color: Colors.white,
                              size: 32.sp,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      // Title with emoji and gradient text effect
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, Colors.white.withOpacity(0.9)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // Description
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      // Animated feature badges with overflow protection
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: features.map((feature) {
                            final parts = feature.split(' ');
                            final emoji = parts.first;
                            final text = parts.skip(1).join(' ');
                            return _buildFeatureBadge(emoji, text, value);
                          }).toList(),
                        ),
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Animated CTA button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Start Now',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 🎨 Креативная карточка сервиса с hover эффектами
  static Widget serviceCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required List<String> stats,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24.r),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap();
                  },
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon with animated background
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                        
                        SizedBox(height: 20.h),
                        
                        // Title with gradient text
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(height: 8.h),
                        
                        // Description with overflow protection
                        Flexible(
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(height: 20.h),
                        
                        // Animated stats with better spacing
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: stats.asMap().entries.map((entry) {
                            final index = entry.key;
                            final stat = entry.value;
                            return _buildAnimatedStatChip(stat, color, value, index);
                          }).toList(),
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Animated arrow
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: color,
                              size: 14.sp,
                            ),
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
    );
  }

  // 🌟 Креативная кнопка действия с пульсацией
  static Widget actionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double height = 56,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor ?? const Color(0xFF667eea),
                backgroundColor?.withOpacity(0.8) ?? const Color(0xFF764ba2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? const Color(0xFF667eea)).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                HapticFeedback.mediumImpact();
                onTap();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        icon,
                        color: textColor ?? Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    
                    SizedBox(width: 12.w),
                    
                    // Text with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          textColor ?? Colors.white,
                          (textColor ?? Colors.white).withOpacity(0.9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Animated arrow
                    SizedBox(width: 8.w),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: textColor ?? Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 🎯 Вспомогательные виджеты
  static Widget _buildFeatureBadge(String emoji, String text, double animationValue) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15 * animationValue),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.3 * animationValue),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 18.sp),
          ),
          SizedBox(height: 4.h),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAnimatedStatChip(String text, Color color, double animationValue, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + (index * 100)),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1 * animationValue),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withOpacity(0.3 * animationValue),
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
