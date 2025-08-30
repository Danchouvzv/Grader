import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../widgets/enhanced_results_widget.dart';
import '../widgets/animated_background.dart';
import '../../features/ielts/domain/entities/ielts_result.dart';

class EnhancedIeltsResultsPage extends StatefulWidget {
  final IeltsResult assessment;
  final String transcript;
  final bool showNextPartButton;
  final VoidCallback? onNextPart;

  const EnhancedIeltsResultsPage({
    super.key,
    required this.assessment,
    required this.transcript,
    this.showNextPartButton = false,
    this.onNextPart,
  });

  @override
  State<EnhancedIeltsResultsPage> createState() => _EnhancedIeltsResultsPageState();
}

class _EnhancedIeltsResultsPageState extends State<EnhancedIeltsResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  
  int _currentTab = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _contentController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTab = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    HapticFeedback.lightImpact();
  }

  void _onSaveResult() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text('Result saved to your history'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onShare() {
    HapticFeedback.lightImpact();
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onTryAgain() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header
              SlideTransition(
                position: _headerSlideAnimation,
                child: _buildEnhancedHeader(),
              ),
              
              // Tab Navigation
              _buildTabNavigation(),
              
              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Navigation Row
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IELTS Assessment',
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Your detailed results',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              GestureDetector(
                onTap: _onShare,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Overall Band',
                  widget.assessment.overallBand.toStringAsFixed(1),
                  Icons.emoji_events_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Assessment',
                  _getBandLabel(widget.assessment.overallBand),
                  Icons.verified_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTabNavigation() {
    final tabs = [
      {'label': 'Scores', 'icon': Icons.analytics_rounded},
      {'label': 'Transcript', 'icon': Icons.text_snippet_rounded},
      {'label': 'Tips', 'icon': Icons.lightbulb_rounded},
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == _currentTab;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab['label'] as String,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentTab = index;
        });
      },
      children: [
        // Scores Tab
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: EnhancedResultsWidget(
            result: widget.assessment,
            onSaveResult: _onSaveResult,
            onShare: _onShare,
            onTryAgain: _onTryAgain,
          ),
        ),
        
        // Transcript Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _buildTranscriptTab(),
        ),
        
        // Tips Tab
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTipsTab(),
              
              // Next Part Button (if needed)
              if (widget.showNextPartButton && widget.onNextPart != null) ...[
                const SizedBox(height: 32),
                _buildNextPartButton(),
              ],
              
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.text_snippet_rounded,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Response',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'AI-generated transcript of your speaking',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.transcript));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transcript copied to clipboard'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: Icon(
                  Icons.copy_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Transcript Content
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            widget.transcript.isNotEmpty
                ? widget.transcript
                : 'No transcript available.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Stats
        Row(
          children: [
            Expanded(
              child: _buildTranscriptStat(
                'Word Count',
                widget.transcript.split(' ').length.toString(),
                Icons.format_list_numbered_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTranscriptStat(
                'Estimated Time',
                '${(widget.transcript.split(' ').length / 150).ceil()} min',
                Icons.timer_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTranscriptStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personalized Tips
        Container(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personalized Tips',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Based on your performance',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...widget.assessment.tips.asMap().entries.map((entry) {
                final index = entry.key;
                final tip = entry.value;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
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
                            color: AppColors.textPrimary,
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
        ),
        
        const SizedBox(height: 24),
        
        // General Tips
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'General IELTS Speaking Tips',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...[
                'Practice speaking English daily, even if just for a few minutes',
                'Record yourself speaking and listen back to identify areas for improvement',
                'Learn topic-specific vocabulary and practice using it in context',
                'Work on your pronunciation by listening to native speakers',
                'Practice organizing your thoughts quickly for Part 2 topics',
              ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
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
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextPartButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE53935), // Red
            const Color(0xFF1976D2), // Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context); // Закрываем страницу результатов
          widget.onNextPart?.call(); // Переходим к следующей части
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Continue to Next Part',
              style: AppTypography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBandLabel(double band) {
    if (band >= 8.5) return 'Excellent';
    if (band >= 7.0) return 'Good';
    if (band >= 6.0) return 'Competent';
    if (band >= 5.0) return 'Limited';
    return 'Needs Improvement';
  }
}
