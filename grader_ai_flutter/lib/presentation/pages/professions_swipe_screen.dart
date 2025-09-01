import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../core/models/profession.dart';
import '../../core/controllers/swipe_deck_controller.dart';
import '../widgets/profession_card.dart';
import 'profession_details_screen.dart';
import 'career_summary_screen.dart';

class ProfessionsSwipeScreen extends StatefulWidget {
  const ProfessionsSwipeScreen({super.key});

  @override
  State<ProfessionsSwipeScreen> createState() => _ProfessionsSwipeScreenState();
}

class _ProfessionsSwipeScreenState extends State<ProfessionsSwipeScreen>
    with TickerProviderStateMixin {
  double _dragProgress = 0.0; // -1.0 to 1.0 (left to right)
  double _rotationAngle = 0.0;
  bool _isDragging = false;
  
  late AnimationController _pulseController;
  late AnimationController _badgeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _badgeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Пульсация для кнопок действий
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Анимация для бейджей
    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _badgeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.elasticOut,
    ));

    // Загружаем сохранённую сессию
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SwipeDeckController>().loadSavedSession();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<SwipeDeckController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                // Header with progress
                _buildHeader(controller),
                
                // Main swipe area
                Expanded(
                  child: controller.hasMore
                      ? _buildSwipeDeck(controller)
                      : _buildCompletionState(controller),
                ),
                
                // Action buttons
                _buildActionButtons(controller),
                
                SizedBox(height: 20.h),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(SwipeDeckController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Title and stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Career Matches',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Find your perfect career',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              // Stats badges
              Row(
                children: [
                  _buildStatBadge(
                    icon: Icons.favorite_rounded,
                    count: controller.liked.length + controller.superliked.length,
                    color: const Color(0xFF10B981),
                  ),
                  SizedBox(width: 12.w),
                  _buildStatBadge(
                    icon: Icons.local_fire_department_rounded,
                    count: controller.streakCount,
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Progress bar
          _buildProgressBar(controller),
        ],
      ),
    );
  }

  Widget _buildStatBadge({required IconData icon, required int count, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(SwipeDeckController controller) {
    final progress = controller.completionPercentage;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.index} of ${controller.total}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8.h,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFF3B82F6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeDeck(SwipeDeckController controller) {
    final remainingCards = controller.remainingCards;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Background cards (stack effect)
            ...List.generate(
              math.min(3, remainingCards.length),
              (index) {
                if (index == 0) return const SizedBox.shrink(); // Skip top card
                
                final profession = remainingCards[index];
                return Positioned(
                  top: index * 8.h,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ProfessionCardStack(
                    profession: profession,
                    depth: index.toDouble(),
                  ),
                );
              },
            ).reversed.toList(),
            
            // Top card (interactive)
            if (remainingCards.isNotEmpty)
              Positioned.fill(
                child: _buildDismissibleCard(remainingCards.first, controller),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDismissibleCard(Profession profession, SwipeDeckController controller) {
    return Dismissible(
      key: ValueKey(profession.id),
      direction: DismissDirection.horizontal,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.3,
        DismissDirection.endToStart: 0.3,
      },
      onUpdate: (details) {
        setState(() {
          _isDragging = true;
          final screenWidth = MediaQuery.of(context).size.width;
          _dragProgress = (details.progress * 2 - 1) * 
              (details.direction == DismissDirection.startToEnd ? 1 : -1);
          _rotationAngle = _dragProgress * 0.3; // Subtle rotation
        });
      },
      onDismissed: (direction) {
        setState(() {
          _dragProgress = 0.0;
          _rotationAngle = 0.0;
          _isDragging = false;
        });
        
        final action = direction == DismissDirection.endToStart
            ? SwipeAction.dislike
            : SwipeAction.like;
        
        controller.swipe(action);
        
        // Show badge animation for likes
        if (action == SwipeAction.like) {
          _badgeController.forward().then((_) {
            _badgeController.reset();
          });
        }
      },
      child: GestureDetector(
        onTap: () => _showProfessionDetails(profession),
        child: ProfessionCard(
          profession: profession,
          dragProgress: _dragProgress,
          rotationAngle: _rotationAngle,
          isTopCard: true,
          onTap: () => _showProfessionDetails(profession),
        ),
      ),
    );
  }

  Widget _buildCompletionState(SwipeDeckController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Celebration icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration_rounded,
                size: 60.sp,
                color: const Color(0xFF10B981),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              'Great job!',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F2937),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            Text(
              'You\'ve reviewed all career matches',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToSummary(controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.summarize_rounded, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'View Summary',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => controller.reset(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Review Again',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(SwipeDeckController controller) {
    if (!controller.hasMore) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Dislike button
          _buildActionButton(
            icon: Icons.close_rounded,
            color: const Color(0xFFEF4444),
            backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
            onTap: () => controller.swipe(SwipeAction.dislike),
            size: 56.w,
          ),
          
          // Info button
          _buildActionButton(
            icon: Icons.info_outline_rounded,
            color: const Color(0xFF6B7280),
            backgroundColor: Colors.white,
            onTap: () => _showProfessionDetails(controller.current!),
            size: 48.w,
          ),
          
          // Rewind button (if available)
          _buildActionButton(
            icon: Icons.undo_rounded,
            color: const Color(0xFF8B5CF6),
            backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
            onTap: controller.index > 0 ? () => controller.rewind() : null,
            size: 48.w,
          ),
          
          // Like button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _buildActionButton(
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                  onTap: () => controller.swipe(SwipeAction.like),
                  size: 56.w,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback? onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: onTap != null ? color : color.withOpacity(0.3),
          size: size * 0.4,
        ),
      ),
    );
  }

  void _showProfessionDetails(Profession profession) {
    HapticFeedback.lightImpact();
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProfessionDetailsScreen(profession: profession),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToSummary(SwipeDeckController controller) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CareerSummaryScreen(controller: controller),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
