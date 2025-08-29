import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../features/ielts/domain/entities/ielts_result.dart';

class EnhancedResultsWidget extends StatefulWidget {
  final IeltsResult result;
  final VoidCallback? onSaveResult;
  final VoidCallback? onShare;
  final VoidCallback? onTryAgain;

  const EnhancedResultsWidget({
    super.key,
    required this.result,
    this.onSaveResult,
    this.onShare,
    this.onTryAgain,
  });

  @override
  State<EnhancedResultsWidget> createState() => _EnhancedResultsWidgetState();
}

class _EnhancedResultsWidgetState extends State<EnhancedResultsWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _progressController;
  late List<AnimationController> _cardControllers;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _cardAnimations = _cardControllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack)))
        .toList();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();
    
    // Staggered card animations
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 100 + (i * 50)));
      _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    for (final controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getBandColor(double band) {
    if (band >= 8.5) return AppColors.bandExcellent;
    if (band >= 7.0) return AppColors.bandGood;
    if (band >= 6.0) return AppColors.bandCompetent;
    if (band >= 5.0) return AppColors.bandLimited;
    return AppColors.bandPoor;
  }

  String _getBandLabel(double band) {
    if (band >= 8.5) return 'Excellent';
    if (band >= 7.0) return 'Good';
    if (band >= 6.0) return 'Competent';
    if (band >= 5.0) return 'Limited';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // Overall Score
          _buildOverallScoreCard(),
          
          const SizedBox(height: 24),
          
          // Individual Scores
          _buildIndividualScores(),
          
          const SizedBox(height: 24),
          
          // Summary
          _buildSummaryCard(),
          
          const SizedBox(height: 24),
          
          // Tips
          _buildTipsCard(),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getBandColor(widget.result.overallBand),
              _getBandColor(widget.result.overallBand).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _getBandColor(widget.result.overallBand).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Trophy Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Overall Band Score
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final animatedBand = widget.result.overallBand * _progressAnimation.value;
                return Text(
                  animatedBand.toStringAsFixed(1),
                  style: AppTypography.displayLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 56,
                  ),
                );
              },
            ),
            
            Text(
              'IELTS Band Score',
              style: AppTypography.titleMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getBandLabel(widget.result.overallBand),
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualScores() {
    final criteria = [
      {'key': 'fluency_coherence', 'title': 'Fluency & Coherence', 'icon': Icons.record_voice_over_rounded},
      {'key': 'lexical_resource', 'title': 'Lexical Resource', 'icon': Icons.library_books_rounded},
      {'key': 'grammar', 'title': 'Grammar', 'icon': Icons.spellcheck_rounded},
      {'key': 'pronunciation', 'title': 'Pronunciation', 'icon': Icons.hearing_rounded},
    ];

    return Column(
      children: criteria.asMap().entries.map((entry) {
        final index = entry.key;
        final criterion = entry.value;
        final score = widget.result.bands[criterion['key']] ?? 0.0;
        final reason = widget.result.reasons[criterion['key']] ?? '';

        return AnimatedBuilder(
          animation: _cardAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimations[index].value,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                  border: Border.all(
                    color: _getBandColor(score).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getBandColor(score).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        criterion['icon'] as IconData,
                        color: _getBandColor(score),
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                criterion['title'] as String,
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getBandColor(score),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  score.toStringAsFixed(1),
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            reason,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Progress Bar
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: (score / 9.0) * _progressAnimation.value,
                                backgroundColor: _getBandColor(score).withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(_getBandColor(score)),
                                minHeight: 6,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: AppColors.info.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.summarize_rounded,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Assessment Summary',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.result.summary,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: AppColors.warning.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Improvement Tips',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...widget.result.tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      tip,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            onTap: widget.onTryAgain,
            icon: Icons.refresh_rounded,
            label: 'Try Again',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            onTap: widget.onSaveResult,
            icon: Icons.bookmark_rounded,
            label: 'Save Result',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          onTap: widget.onShare,
          icon: Icons.share_rounded,
          label: 'Share',
          color: AppColors.info,
          isCompact: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String label,
    required Color color,
    bool isCompact = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            if (!isCompact) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Animated Score Circle Widget
class AnimatedScoreCircle extends StatefulWidget {
  final double score;
  final double maxScore;
  final Color color;
  final String label;
  final double size;

  const AnimatedScoreCircle({
    super.key,
    required this.score,
    required this.maxScore,
    required this.color,
    required this.label,
    this.size = 80,
  });

  @override
  State<AnimatedScoreCircle> createState() => _AnimatedScoreCircleState();
}

class _AnimatedScoreCircleState extends State<AnimatedScoreCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.score / widget.maxScore,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.color.withOpacity(0.2),
                      ),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    ),
                  ),
                  // Score text
                  Text(
                    (widget.score * _animation.value).toStringAsFixed(1),
                    style: AppTypography.headlineMedium.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
