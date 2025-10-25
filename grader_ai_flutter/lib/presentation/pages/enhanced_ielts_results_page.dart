import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../widgets/enhanced_results_widget.dart';
import '../widgets/animated_background.dart';
import '../../features/ielts/domain/entities/ielts_result.dart';
import '../../core/openai_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/config/api_config.dart';
import '../../core/services/learning_progress_service.dart';
import 'learning_insights_page.dart';
import 'interactive_exercise_page.dart';

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
  Map<String, dynamic>? _enhancedData;
  bool _isEnhancing = false;
  Map<String, dynamic>? _actionableTips;
  bool _isGeneratingTips = false;
  bool _tipsRequestedOnce = false;
  Map<String, dynamic>? _coachPlan;
  bool _isGeneratingCoachPlan = false;

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
    if (index == 2) {
      _ensureTipsLoaded();
    }
  }

  void _onSaveResult() {
    HapticFeedback.mediumImpact();
    FirestoreService.instance.saveIeltsResult(
      overallBand: widget.assessment.overallBand,
      fluency: widget.assessment.bands['fluency_coherence'] ?? 0.0,
      lexical: widget.assessment.bands['lexical_resource'] ?? 0.0,
      grammar: widget.assessment.bands['grammar'] ?? 0.0,
      pronunciation: widget.assessment.bands['pronunciation'] ?? 0.0,
      transcript: widget.transcript,
      enhancedData: _enhancedData,
      actionableTips: _actionableTips,
    ).then((_) {
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
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }

  void _onShare() async {
    HapticFeedback.lightImpact();
    
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generate share content
      final shareContent = await _generateShareContent();
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show share options
      if (mounted) {
        _showShareOptions(shareContent);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to prepare share content: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<Map<String, String>> _generateShareContent() async {
    final assessment = widget.assessment;
    final now = DateTime.now();
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    // Generate text content
    final textContent = _generateTextContent(assessment, dateFormat.format(now));
    
    // Generate image content (screenshot)
    final imagePath = await _captureScreenshot();
    
    return {
      'text': textContent,
      'image': imagePath,
    };
  }

  String _generateTextContent(IeltsResult assessment, String date) {
    final overallBand = assessment.overallBand.toStringAsFixed(1);
    final fluency = assessment.bands['fluency']?.toStringAsFixed(1) ?? '0.0';
    final coherence = assessment.bands['coherence']?.toStringAsFixed(1) ?? '0.0';
    final vocabulary = assessment.bands['vocabulary']?.toStringAsFixed(1) ?? '0.0';
    final grammar = assessment.bands['grammar']?.toStringAsFixed(1) ?? '0.0';
    final pronunciation = assessment.bands['pronunciation']?.toStringAsFixed(1) ?? '0.0';
    
    return '''
🎯 IELTS Speaking Assessment Results
📅 $date

🏆 Overall Band Score: $overallBand/9.0

📊 Detailed Scores:
• Fluency & Coherence: $fluency/9.0
• Lexical Resource: $vocabulary/9.0
• Grammatical Range: $grammar/9.0
• Pronunciation: $pronunciation/9.0

💡 Key Feedback:
${assessment.summary.isNotEmpty ? assessment.summary : 'Great job! Keep practicing to improve your English skills.'}

🚀 Practice more with Grader.AI to achieve your target band score!

#IELTS #EnglishLearning #GraderAI #SpeakingPractice
''';
  }

  Future<String> _captureScreenshot() async {
    try {
      // Get the current page content
      final RenderRepaintBoundary boundary = _pageController.position.context.storageContext
          .findRenderObject() as RenderRepaintBoundary;
      
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      
      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ielts_results_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      
      return file.path;
    } catch (e) {
      // Fallback: create a simple text-based image
      return await _createTextImage();
    }
  }

  Future<String> _createTextImage() async {
    // This is a fallback method - in a real implementation, you'd use a package like image
    // to create a proper image with the results
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/ielts_results_text_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(_generateTextContent(widget.assessment, DateFormat('MMM dd, yyyy').format(DateTime.now())));
    return file.path;
  }

  void _showShareOptions(Map<String, String> content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Share Your Results',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to share your IELTS results',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Share options
                  Row(
                    children: [
                      Expanded(
                        child: _buildShareOption(
                          icon: Icons.text_fields_rounded,
                          label: 'Text Only',
                          onTap: () => _shareText(content['text']!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildShareOption(
                          icon: Icons.image_rounded,
                          label: 'With Screenshot',
                          onTap: () => _shareWithImage(content),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Social media options
                  Row(
                    children: [
                      Expanded(
                        child: _buildShareOption(
                          icon: Icons.copy_rounded,
                          label: 'Copy Text',
                          onTap: () => _copyToClipboard(content['text']!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildShareOption(
                          icon: Icons.more_horiz_rounded,
                          label: 'More Options',
                          onTap: () => _shareWithImage(content),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textTertiary),
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
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _shareText(String text) async {
    try {
      await Share.share(
        text,
        subject: 'My IELTS Speaking Results',
      );
    } catch (e) {
      _showError('Failed to share text: $e');
    }
  }

  void _shareWithImage(Map<String, String> content) async {
    try {
      await Share.shareXFiles(
        [XFile(content['image']!)],
        text: content['text'],
        subject: 'My IELTS Speaking Results',
      );
    } catch (e) {
      _showError('Failed to share with image: $e');
    }
  }

  void _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Results copied to clipboard!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to copy to clipboard: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
        if (index == 2) {
          _ensureTipsLoaded();
        }
      },
      children: [
        // Scores Tab
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              EnhancedResultsWidget(
                result: widget.assessment,
                onSaveResult: _onSaveResult,
                onShare: _onShare,
                onTryAgain: _onTryAgain,
              ),
              
              // Learning Insights Button - always show
              const SizedBox(height: 32),
              _buildLearningInsightsButton(),
              
              // Next Part Button (if needed) - moved to Scores tab
              if (widget.showNextPartButton && widget.onNextPart != null) ...[
                const SizedBox(height: 16),
                _buildNextPartButton(),
              ],
              
              const SizedBox(height: 40), // Bottom padding
            ],
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
        
        const SizedBox(height: 16),

        // Enhance to Band 8 button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isEnhancing ? null : _onEnhancePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(_isEnhancing ? Icons.hourglass_bottom_rounded : Icons.auto_fix_high_rounded),
            label: Text(_isEnhancing ? 'Generating improved version…' : 'Generate Band 8 version'),
          ),
        ),

        const SizedBox(height: 12),

        // Generate Coach Plan button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isGeneratingCoachPlan ? null : _onGenerateCoachPlan,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.6), width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(_isGeneratingCoachPlan ? Icons.hourglass_empty_rounded : Icons.flag_rounded),
            label: Text(_isGeneratingCoachPlan ? 'Preparing coach plan…' : 'Generate 7‑day Coach Plan'),
          ),
        ),

        const SizedBox(height: 16),

        if (_enhancedData != null) _buildEnhancedSection(),

        const SizedBox(height: 16),
        
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

  Future<void> _onEnhancePressed() async {
    if (widget.transcript.trim().isEmpty) return;
    setState(() {
      _isEnhancing = true;
    });
    try {
      final service = OpenAIService(ApiConfig.openAiApiKey);
      final data = await service.enhanceSpeech(widget.transcript);
      setState(() {
        _enhancedData = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate improved version: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEnhancing = false;
        });
      }
    }
  }

  Future<void> _onGenerateCoachPlan() async {
    if (widget.transcript.trim().isEmpty) return;
    setState(() { _isGeneratingCoachPlan = true; });
    try {
      final service = OpenAIService(ApiConfig.openAiApiKey);
      final bands = <String, double>{
        'fluency': widget.assessment.bands['fluency_coherence'] ?? 0.0,
        'lexical': widget.assessment.bands['lexical_resource'] ?? 0.0,
        'grammar': widget.assessment.bands['grammar'] ?? 0.0,
        'pronunciation': widget.assessment.bands['pronunciation'] ?? 0.0,
      };
      final plan = await service.generateCoachPlan(
        transcript: widget.transcript,
        bands: bands,
      );
      setState(() { _coachPlan = plan; });
      await FirestoreService.instance.saveCoachPlan(plan: plan);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Coach plan saved to your profile'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _showCoachPlanDialog(plan);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate plan: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() { _isGeneratingCoachPlan = false; });
    }
  }

  void _showCoachPlanDialog(Map<String, dynamic> plan) {
    final days = (plan['days'] as List?) ?? const [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan['week_goal']?.toString() ?? 'Weekly Coach Plan', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(plan['rationale']?.toString() ?? '', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: days.length,
                      itemBuilder: (context, i) {
                        final d = days[i] as Map<String, dynamic>;
                        final missions = (d['missions'] as List?)?.cast<String>() ?? const <String>[];
                        final targets = (d['target_phrases'] as List?)?.cast<String>() ?? const <String>[];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Day ${d['day']}: ${d['title'] ?? ''}', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                              if (missions.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('Missions:', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                                ...missions.map((m) => Text('• $m', style: AppTypography.bodyMedium)).toList(),
                              ],
                              if (targets.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('Target phrases:', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                                Wrap(spacing: 6, runSpacing: 6, children: targets.map((t) => Chip(label: Text(t))).toList()),
                              ],
                              if ((d['checkpoint']?.toString() ?? '').isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('Checkpoint: ${d['checkpoint']}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedSection() {
    final improved = (_enhancedData?['improved'] ?? '') as String;
    final phrases = List<String>.from(_enhancedData?['advanced_phrases'] ?? const <String>[]);
    final rationale = (_enhancedData?['rationale'] ?? '') as String;
    final fillerReport = _analyzeFillers(widget.transcript);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Improved Transcript
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.success.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.upgrade_rounded, color: AppColors.success, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Band 8 style version',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                improved.isNotEmpty ? improved : 'No improved version available.',
                style: AppTypography.bodyLarge.copyWith(height: 1.6, color: AppColors.textPrimary),
              ),
              if (rationale.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  rationale,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                )
              ],
              if (phrases.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Advanced, natural phrases used',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                ...phrases.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)))
                    ],
                  ),
                ))
              ]
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Filler word analysis
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.warning.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.record_voice_over_rounded, color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filler words and repetition',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (fillerReport['items'].isEmpty)
                Text('Great! No distracting fillers detected.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...List<Map<String, dynamic>>.from(fillerReport['items']).map((item) {
                      final word = item['word'] as String;
                      final count = item['count'] as int;
                      final suggestions = List<String>.from(item['suggestions'] as List);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning.withOpacity(0.12), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('"$word" repeated $count times',
                                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text('Try these alternatives:',
                                style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: suggestions.map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
                                ),
                                child: Text(s, style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary)),
                              )).toList(),
                            )
                          ],
                        ),
                      );
                    })
                  ],
                )
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _analyzeFillers(String text) {
    final lower = text.toLowerCase();
    final candidates = <String, List<String>>{
      'like': ['for instance', 'such as', 'for example'],
      'you know': ['to be clear', 'notably', 'in fact'],
      'um': ['(pause silently)', 'let me think', 'well'],
      'uh': ['(pause silently)', 'well', 'actually'],
      'basically': ['in essence', 'fundamentally', 'essentially'],
      'actually': ['in fact', 'indeed', 'as a matter of fact'],
      'i think': ['in my view', 'from my perspective', 'it seems to me'],
      'kind of': ['somewhat', 'to some extent', 'relatively'],
      'sort of': ['somewhat', 'to some extent', 'relatively'],
      'maybe': ['perhaps', 'potentially', 'possibly'],
    };
    final items = <Map<String, dynamic>>[];
    candidates.forEach((word, synonyms) {
      final pattern = RegExp('\\b' + RegExp.escape(word) + '\\b');
      final count = pattern.allMatches(lower).length;
      if (count >= 2) {
        items.add({'word': word, 'count': count, 'suggestions': synonyms});
      }
    });
    return {'items': items};
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
                'Actionable, transcript‑based tips',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (_isGeneratingTips)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Text('Analyzing your transcript…', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else if (_actionableTips != null)
                _buildActionableTips(_actionableTips!)
              else
                Text('Tips will appear here shortly based on your transcript.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onGenerateTips() async {
    if (widget.transcript.trim().isEmpty) return;
    setState(() {
      _isGeneratingTips = true;
    });
    try {
      final service = OpenAIService(ApiConfig.openAiApiKey);
      final data = await service.actionableTips(widget.transcript);
      setState(() {
        _actionableTips = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to analyze transcript: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingTips = false;
        });
      }
    }
  }

  void _ensureTipsLoaded() {
    if (_tipsRequestedOnce || _isGeneratingTips) return;
    _tipsRequestedOnce = true;
    _onGenerateTips();
  }

  Widget _buildActionableTips(Map<String, dynamic> tips) {
    final repeated = List<Map<String, dynamic>>.from(tips['repeated_words'] ?? const []);
    final simple = List<Map<String, dynamic>>.from(tips['simple_words'] ?? const []);
    final priority = List<String>.from(tips['priority_tips'] ?? const []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (repeated.isNotEmpty) ...[
          Text('Overused/filler words',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...repeated.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.12), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _openPracticeSheet(r['word'].toString()),
                      child: Text('${r['word']} • ${r['count']} times',
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                    if ((r['note'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(r['note'].toString(), style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List<String>.from(r['c1_synonyms'] ?? const <String>[])
                          .map((s) => GestureDetector(
                                onTap: () => _openPracticeSheet(s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
                                  ),
                                  child: Text(s, style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary)),
                                ),
                              ))
                          .toList(),
                    )
                  ],
                ),
              )),
          const SizedBox(height: 14),
        ],

        if (simple.isNotEmpty) ...[
          Text('Upgrade simple words to C1 level',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...simple.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.12), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _openPracticeSheet(r['word'].toString()),
                      child: Text('${r['word']} • ${r['count']} times',
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List<String>.from(r['c1_synonyms'] ?? const <String>[])
                          .map((s) => GestureDetector(
                                onTap: () => _openPracticeSheet(s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
                                  ),
                                  child: Text(s, style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary)),
                                ),
                              ))
                          .toList(),
                    ),
                    if ((r['example'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Example:', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(r['example'].toString(), style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
                    ]
                  ],
                ),
              )),
          const SizedBox(height: 14),
        ],

        if (priority.isNotEmpty) ...[
          Text('Top priorities for your next attempt',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...priority.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Text(p, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5)),
                    ),
                  ],
                ),
              )),
        ]
      ],
    );
  }

  void _openPracticeSheet(String target) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        int remaining = 5;
        return StatefulBuilder(
          builder: (context, setBsState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.record_voice_over_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Practice: $target',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Say this word/phrase 5 times with natural intonation. Tap each time you say it clearly.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      children: List.generate(5, (i) {
                        final done = i >= (5 - remaining);
                        return GestureDetector(
                          onTap: () {
                            if (remaining > 0) setBsState(() => remaining -= 1);
                            HapticFeedback.selectionClick();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: done ? AppColors.success.withOpacity(0.15) : AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: done ? AppColors.success.withOpacity(0.4) : AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(done ? Icons.check_circle_rounded : Icons.circle_outlined,
                                    size: 18, color: done ? AppColors.success : AppColors.primary),
                                const SizedBox(width: 8),
                                Text('Say', style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        remaining > 0 ? '${remaining} left' : 'Great job!',
                        style: AppTypography.labelMedium.copyWith(
                          color: remaining > 0 ? AppColors.textSecondary : AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLearningInsightsButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6), // Blue
            const Color(0xFF1D4ED8), // Darker blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Save result to learning progress
          final progressService = LearningProgressService();
          progressService.addSessionResult(widget.assessment, 'Speaking Practice');
          
          // Navigate to Learning Insights
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LearningInsightsPage(
                result: widget.assessment,
                topic: 'Speaking Practice',
                transcript: widget.transcript,
              ),
            ),
          );
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
              Icons.school_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Learning Insights & Practice',
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
