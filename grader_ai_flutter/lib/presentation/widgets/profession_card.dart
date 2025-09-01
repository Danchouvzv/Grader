import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../../core/models/profession.dart';

class ProfessionCard extends StatelessWidget {
  final Profession profession;
  final double dragProgress; // -1.0 to 1.0 (left to right)
  final double rotationAngle; // Rotation during drag
  final bool isTopCard;
  final VoidCallback? onTap;

  const ProfessionCard({
    super.key,
    required this.profession,
    this.dragProgress = 0.0,
    this.rotationAngle = 0.0,
    this.isTopCard = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final likeOpacity = (dragProgress * 2).clamp(0.0, 1.0);
    final nopeOpacity = (-dragProgress * 2).clamp(0.0, 1.0);
    final superlikeOpacity = isTopCard ? 0.0 : 0.0; // Will be used for upward swipes
    
    return Transform.rotate(
      angle: rotationAngle * 0.1, // Subtle rotation during drag
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: profession.accentColor.withOpacity(0.08),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              // Hero background
              _buildHeroBackground(),
              
              // Gradient overlay for text readability
              _buildGradientOverlay(),
              
              // Match badge
              _buildMatchBadge(),
              
              // Main content
              _buildMainContent(),
              
              // Skills chips
              _buildSkillsChips(),
              
              // Swipe overlays
              if (likeOpacity > 0) _buildSwipeOverlay('LIKE', Colors.greenAccent, likeOpacity, Alignment.topLeft),
              if (nopeOpacity > 0) _buildSwipeOverlay('NOPE', Colors.redAccent, nopeOpacity, Alignment.topRight),
              
              // Tap detector
              if (onTap != null)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24.r),
                      onTap: onTap,
                      splashColor: profession.accentColor.withOpacity(0.1),
                      highlightColor: profession.accentColor.withOpacity(0.05),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBackground() {
    return Positioned.fill(
      child: profession.heroImage.startsWith('http')
          ? Image.network(
              profession.heroImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackBackground(),
            )
          : profession.heroImage.startsWith('assets')
              ? Image.asset(
                  profession.heroImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildFallbackBackground(),
                )
              : _buildFallbackBackground(),
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            profession.accentColor.withOpacity(0.8),
            profession.accentColor.withOpacity(0.6),
            profession.accentColor.withOpacity(0.9),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(),
          size: 120.sp,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (profession.category.toLowerCase()) {
      case 'business':
        return Icons.business_center_rounded;
      case 'creative':
        return Icons.palette_rounded;
      case 'technical':
        return Icons.code_rounded;
      case 'healthcare':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.work_rounded;
    }
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xDD0D0F14), // Darker at bottom for text readability
              const Color(0x440D0F14), // Medium in middle
              const Color(0x000D0F14), // Transparent at top
            ],
            stops: const [0.0, 0.4, 0.8],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchBadge() {
    return Positioned(
      top: 20.h,
      right: 20.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: profession.accentColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: profession.accentColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              profession.matchLabel,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Positioned(
      left: 24.w,
      right: 24.w,
      bottom: 120.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              profession.category.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Title
          Text(
            profession.title,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 8.h),
          
          // Subtitle
          Text(
            profession.subtitle,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.4,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 16.h),
          
          // Salary and education quick info
          Row(
            children: [
              _buildQuickInfo(Icons.school_rounded, profession.education),
              SizedBox(width: 20.w),
              Expanded(
                child: _buildQuickInfo(Icons.attach_money_rounded, profession.salaryRange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 18.sp,
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsChips() {
    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: 20.h,
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: profession.skills.take(6).map((skill) => _buildSkillChip(skill)).toList(),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        skill,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2E3646),
        ),
      ),
    );
  }

  Widget _buildSwipeOverlay(String text, Color color, double opacity, Alignment alignment) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: alignment == Alignment.topLeft ? -0.3 : 0.3,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  color: color.withOpacity(0.1),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 24.sp,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Карточка для стека (неактивная)
class ProfessionCardStack extends StatelessWidget {
  final Profession profession;
  final double depth; // 0, 1, 2 for stack effect
  
  const ProfessionCardStack({
    super.key,
    required this.profession,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 - (depth * 0.05); // Smaller cards behind
    final offset = depth * 8.h; // Vertical offset for stack effect
    
    return Transform.scale(
      scale: scale,
      child: Container(
        margin: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 8.h + offset,
          bottom: 8.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08 - depth * 0.02),
              blurRadius: 16 - depth * 4,
              spreadRadius: 1,
              offset: Offset(0, 8 - depth * 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              // Simplified background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        profession.accentColor.withOpacity(0.7),
                        profession.accentColor.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Minimal content preview
              Positioned(
                left: 24.w,
                right: 24.w,
                bottom: 24.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profession.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      profession.category,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
