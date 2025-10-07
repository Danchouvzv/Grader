import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../features/ielts/domain/entities/ielts_result.dart';
import 'interactive_exercise_page.dart';

class LearningInsightsPage extends StatefulWidget {
  final IeltsResult result;
  final String topic;
  final String transcript;

  const LearningInsightsPage({
    super.key,
    required this.result,
    required this.topic,
    required this.transcript,
  });

  @override
  State<LearningInsightsPage> createState() => _LearningInsightsPageState();
}

class _LearningInsightsPageState extends State<LearningInsightsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Learning Insights',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF3B82F6),
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Practice'),
            Tab(text: 'Progress'),
            Tab(text: 'Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPracticeTab(),
          _buildProgressTab(),
          _buildTipsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Summary
          _buildPerformanceSummary(),
          SizedBox(height: 24.h),
          
          // Key Insights
          _buildKeyInsights(),
          SizedBox(height: 24.h),
          
          // Weak Areas
          _buildWeakAreas(),
          SizedBox(height: 24.h),
          
          // Next Steps
          _buildNextSteps(),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3B82F6),
            const Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Summary',
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Topic: ${widget.topic}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Overall Band',
                  widget.result.overallBand.toString(),
                  Icons.star_rounded,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildScoreCard(
                  'Fluency',
                  widget.result.bands['fluency']?.toString() ?? '0',
                  Icons.speed_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Lexical Resource',
                  widget.result.bands['lexical_resource']?.toString() ?? '0',
                  Icons.book_rounded,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildScoreCard(
                  'Grammar',
                  widget.result.bands['grammar']?.toString() ?? '0',
                  Icons.checklist_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, String score, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20.w,
          ),
          SizedBox(height: 8.h),
          Text(
            score,
            style: AppTypography.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInsights() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: const Color(0xFFF59E0B),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Key Insights',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...widget.result.summary.split('\n').where((line) => line.isNotEmpty).map((insight) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    margin: EdgeInsets.only(top: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      insight.trim(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWeakAreas() {
    final weakAreas = _identifyWeakAreas();
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_down_rounded,
                color: const Color(0xFFEF4444),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Areas for Improvement',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...weakAreas.map((area) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFFECACA),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: const Color(0xFFEF4444),
                      size: 20.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        area,
                        style: AppTypography.bodyMedium.copyWith(
                          color: const Color(0xFF991B1B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.navigation_rounded,
                color: const Color(0xFF10B981),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Recommended Next Steps',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildNextStepCard(
            'Practice Similar Topics',
            'Try more questions on ${widget.topic} to build confidence',
            Icons.topic_rounded,
            const Color(0xFF3B82F6),
            () => _navigateToPractice(),
          ),
          SizedBox(height: 12.h),
          _buildNextStepCard(
            'Focus on Weak Areas',
            'Work on specific skills that need improvement',
            Icons.fitness_center_rounded,
            const Color(0xFFEF4444),
            () => _navigateToWeakAreas(),
          ),
          SizedBox(height: 12.h),
          _buildNextStepCard(
            'Vocabulary Building',
            'Learn new words and phrases for better expression',
            Icons.book_rounded,
            const Color(0xFF10B981),
            () => _navigateToVocabulary(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice Exercises',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Similar Topics
          _buildPracticeSection(
            'Similar Topics',
            'Practice more questions on the same topic',
            Icons.topic_rounded,
            const Color(0xFF3B82F6),
            _getSimilarTopics(),
          ),
          
          SizedBox(height: 20.h),
          
          // Grammar Practice
          _buildPracticeSection(
            'Grammar Practice',
            'Focus on grammar patterns you used',
            Icons.checklist_rounded,
            const Color(0xFF10B981),
            _getGrammarExercises(),
          ),
          
          SizedBox(height: 20.h),
          
          // Vocabulary Practice
          _buildPracticeSection(
            'Vocabulary Practice',
            'Learn new words and phrases',
            Icons.book_rounded,
            const Color(0xFFF59E0B),
            _getVocabularyExercises(),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeSection(
    String title,
    String description,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> exercises,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...exercises.map((exercise) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildExerciseCard(exercise, color),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, Color color) {
    return GestureDetector(
      onTap: () => _startExercise(exercise),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                exercise['icon'],
                color: color,
                size: 20.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['title'],
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    exercise['description'],
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_arrow_rounded,
              color: color,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Progress Chart
          _buildProgressChart(),
          SizedBox(height: 24.h),
          
          // Achievements
          _buildAchievements(),
          SizedBox(height: 24.h),
          
          // Study Streak
          _buildStudyStreak(),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Band Score Trend',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          // TODO: Add actual chart implementation
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'Progress chart coming soon',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Achievements',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildAchievementBadge('First Practice', Icons.star_rounded, const Color(0xFFF59E0B)),
              SizedBox(width: 12.w),
              _buildAchievementBadge('Band 6+', Icons.trending_up_rounded, const Color(0xFF10B981)),
              SizedBox(width: 12.w),
              _buildAchievementBadge('5 Sessions', Icons.local_fire_department_rounded, const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudyStreak() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: const Color(0xFFEF4444),
              size: 32.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Streak',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '3 days in a row!',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFEF4444)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalized Tips',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          
          ...widget.result.tips.map((tip) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 24.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Tip',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      tip,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Helper methods
  List<String> _identifyWeakAreas() {
    final weakAreas = <String>[];
    final bands = widget.result.bands;
    
    if ((bands['fluency'] ?? 0) < 6) {
      weakAreas.add('Fluency - Practice speaking more smoothly and naturally');
    }
    if ((bands['lexical_resource'] ?? 0) < 6) {
      weakAreas.add('Vocabulary - Use more varied and precise words');
    }
    if ((bands['grammar'] ?? 0) < 6) {
      weakAreas.add('Grammar - Focus on sentence structure and accuracy');
    }
    if ((bands['pronunciation'] ?? 0) < 6) {
      weakAreas.add('Pronunciation - Work on clear speech and intonation');
    }
    
    return weakAreas.isEmpty ? ['Keep practicing to maintain your current level!'] : weakAreas;
  }

  List<Map<String, dynamic>> _getSimilarTopics() {
    return [
      {
        'title': 'More ${widget.topic} Questions',
        'description': 'Practice similar questions to build confidence',
        'icon': Icons.question_answer_rounded,
      },
      {
        'title': 'Topic Vocabulary',
        'description': 'Learn key words and phrases for this topic',
        'icon': Icons.book_rounded,
      },
    ];
  }

  List<Map<String, dynamic>> _getGrammarExercises() {
    return [
      {
        'title': 'Sentence Structure',
        'description': 'Practice complex sentences you used',
        'icon': Icons.checklist_rounded,
      },
      {
        'title': 'Tense Practice',
        'description': 'Work on verb tenses from your response',
        'icon': Icons.schedule_rounded,
      },
    ];
  }

  List<Map<String, dynamic>> _getVocabularyExercises() {
    return [
      {
        'title': 'Word Families',
        'description': 'Learn related words and forms',
        'icon': Icons.family_restroom_rounded,
      },
      {
        'title': 'Collocations',
        'description': 'Practice common word combinations',
        'icon': Icons.link_rounded,
      },
    ];
  }

  void _navigateToPractice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InteractiveExercisePage(
          exerciseType: 'fluency',
          topic: widget.topic,
        ),
      ),
    );
  }

  void _navigateToWeakAreas() {
    // Determine weakest area and navigate to specific practice
    final weakSkills = _identifyWeakAreas();
    String exerciseType = 'mixed';
    
    if (weakSkills.any((area) => area.toLowerCase().contains('fluency'))) {
      exerciseType = 'fluency';
    } else if (weakSkills.any((area) => area.toLowerCase().contains('vocabulary'))) {
      exerciseType = 'vocabulary';
    } else if (weakSkills.any((area) => area.toLowerCase().contains('grammar'))) {
      exerciseType = 'grammar';
    } else if (weakSkills.any((area) => area.toLowerCase().contains('pronunciation'))) {
      exerciseType = 'pronunciation';
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InteractiveExercisePage(
          exerciseType: exerciseType,
          topic: widget.topic,
        ),
      ),
    );
  }

  void _navigateToVocabulary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InteractiveExercisePage(
          exerciseType: 'vocabulary',
          topic: widget.topic,
        ),
      ),
    );
  }

  void _startExercise(Map<String, dynamic> exercise) {
    String exerciseType = 'mixed';
    
    // Determine exercise type based on title
    final title = exercise['title'].toLowerCase();
    if (title.contains('vocabulary') || title.contains('word')) {
      exerciseType = 'vocabulary';
    } else if (title.contains('grammar') || title.contains('sentence')) {
      exerciseType = 'grammar';
    } else if (title.contains('fluency') || title.contains('speaking')) {
      exerciseType = 'fluency';
    } else if (title.contains('pronunciation') || title.contains('sound')) {
      exerciseType = 'pronunciation';
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InteractiveExercisePage(
          exerciseType: exerciseType,
          topic: widget.topic,
          exerciseData: exercise,
        ),
      ),
    );
  }
}
