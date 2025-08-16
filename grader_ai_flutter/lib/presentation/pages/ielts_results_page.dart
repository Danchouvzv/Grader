import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/animated_background.dart';
import '../../core/services/ielts_assessment_service.dart';

class IeltsResultsPage extends StatefulWidget {
  final IeltsAssessment assessment;
  final String transcript;

  const IeltsResultsPage({
    super.key,
    required this.assessment,
    required this.transcript,
  });

  @override
  State<IeltsResultsPage> createState() => _IeltsResultsPageState();
}

class _IeltsResultsPageState extends State<IeltsResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  _buildHeader(),
                  SizedBox(height: 30.h),
                  _buildOverallScoreCard(),
                  SizedBox(height: 30.h),
                  _buildCriteriaScores(),
                  SizedBox(height: 30.h),
                  _buildStrengthsAndWeaknesses(),
                  SizedBox(height: 30.h),
                  _buildStudyPlan(),
                  SizedBox(height: 30.h),
                  _buildTranscriptSection(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: const Color(0xFF1976D2),
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IELTS Assessment',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  'Detailed Results & Feedback',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getScoreColors(widget.assessment.overallBand),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: _getScoreColors(widget.assessment.overallBand)[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Overall Band Score',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              widget.assessment.overallBand.toString(),
              style: TextStyle(
                fontSize: 56.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _getScoreDescription(widget.assessment.overallBand),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Speaking Time: ${widget.assessment.estimatedSpeakingTime}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaScores() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Scores',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 16.h),
            _buildCriterionCard(
              'Fluency & Coherence',
              widget.assessment.fluencyCoherence,
              Icons.record_voice_over,
              const Color(0xFF2196F3),
            ),
            SizedBox(height: 16.h),
            _buildCriterionCard(
              'Lexical Resource',
              widget.assessment.lexicalResource,
              Icons.library_books,
              const Color(0xFF4CAF50),
            ),
            SizedBox(height: 16.h),
            _buildCriterionCard(
              'Grammatical Range',
              widget.assessment.grammaticalRange,
              Icons.rule,
              const Color(0xFFFF9800),
            ),
            SizedBox(height: 16.h),
            _buildCriterionCard(
              'Pronunciation',
              widget.assessment.pronunciation,
              Icons.hearing,
              const Color(0xFF9C27B0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriterionCard(
    String title,
    CriterionAssessment criterion,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Band ${criterion.score}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text(
                    criterion.score.toString(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            criterion.feedback,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          if (criterion.examples.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Examples:',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 4.h),
            ...criterion.examples.map((example) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color, fontSize: 12.sp)),
                  Expanded(
                    child: Text(
                      example,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStrengthsAndWeaknesses() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // На узких экранах показываем в колонку
          if (constraints.maxWidth < 600.w) {
            return Column(
              children: [
                _buildInfoCard(
                  'Strengths',
                  widget.assessment.strengths,
                  Icons.thumb_up,
                  const Color(0xFF4CAF50),
                ),
                SizedBox(height: 16.h),
                _buildInfoCard(
                  'Areas to Improve',
                  widget.assessment.areasForImprovement,
                  Icons.trending_up,
                  const Color(0xFFFF9800),
                ),
              ],
            );
          }
          
          // На широких экранах показываем в ряд
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Strengths',
                    widget.assessment.strengths,
                    Icons.thumb_up,
                    const Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildInfoCard(
                    'Areas to Improve',
                    widget.assessment.areasForImprovement,
                    Icons.trending_up,
                    const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4.w,
                  height: 4.h,
                  margin: EdgeInsets.only(top: 6.h, right: 8.w),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStudyPlan() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalized Study Plan',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'Daily tasks to improve your score',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            ...widget.assessment.studyPlan.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        task,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF2C3E50),
                          height: 1.4,
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
    );
  }

  Widget _buildTranscriptSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_snippet,
                  color: const Color(0xFF1976D2),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Your Response',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Text(
                widget.transcript,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF2C3E50),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getScoreColors(double score) {
    if (score >= 8.0) return [const Color(0xFF4CAF50), const Color(0xFF388E3C)];
    if (score >= 7.0) return [const Color(0xFF8BC34A), const Color(0xFF689F38)];
    if (score >= 6.0) return [const Color(0xFFFF9800), const Color(0xFFF57C00)];
    if (score >= 5.0) return [const Color(0xFFFF5722), const Color(0xFFE64A19)];
    return [const Color(0xFFE53935), const Color(0xFFD32F2F)];
  }

  String _getScoreDescription(double score) {
    if (score >= 8.0) return 'Very Good User';
    if (score >= 7.0) return 'Good User';
    if (score >= 6.0) return 'Competent User';
    if (score >= 5.0) return 'Modest User';
    if (score >= 4.0) return 'Limited User';
    return 'Needs Improvement';
  }
}
