import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_background.dart';
import '../../shared/widgets/creative_buttons.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../shared/themes/app_icons.dart';
import '../../shared/themes/app_animations.dart';
import '../widgets/career_test_section.dart';
import '../widgets/career_results_section.dart';
import '../widgets/career_recommendations_section.dart';
import 'professions_swipe_screen.dart';
import '../../core/models/profession.dart';
import '../../core/controllers/swipe_deck_controller.dart';

class CareerGuidancePage extends StatefulWidget {
  const CareerGuidancePage({super.key});

  @override
  State<CareerGuidancePage> createState() => _CareerGuidancePageState();
}

class _CareerGuidancePageState extends State<CareerGuidancePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  CareerTestStatus _testStatus = CareerTestStatus.notStarted;
  CareerTestResult? _testResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onTestCompleted(CareerTestResult result) {
    setState(() {
      _testResult = result;
      _testStatus = CareerTestStatus.completed;
    });
  }

  void _onTestStarted() {
    setState(() {
      _testStatus = CareerTestStatus.inProgress;
      _error = null;
    });
  }

  void _onTestError(String error) {
    setState(() {
      _error = error;
      _testStatus = CareerTestStatus.error;
    });
  }

  void _onRetakeTest() {
    setState(() {
      _testStatus = CareerTestStatus.notStarted;
      _testResult = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: AppColors.textPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Career Guidance AI',
                                    style: AppTypography.headlineMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Discover your perfect career path',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              if (_testStatus == CareerTestStatus.notStarted)
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildWelcomeSection(),
                    ),
                  ),
                ),

              if (_testStatus == CareerTestStatus.inProgress)
                SliverToBoxAdapter(
                  child: CareerTestSection(
                    onTestCompleted: _onTestCompleted,
                    onTestError: _onTestError,
                  ),
                ),

              if (_testStatus == CareerTestStatus.completed && _testResult != null)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      CareerResultsSection(
                        result: _testResult!,
                        onRetakeTest: _onRetakeTest,
                      ),
                      const SizedBox(height: 24),
                      _buildSwipeProfessionsSection(),
                      const SizedBox(height: 24),
                      CareerRecommendationsSection(
                        result: _testResult!,
                      ),
                    ],
                  ),
                ),

              if (_testStatus == CareerTestStatus.error)
                SliverToBoxAdapter(
                  child: _buildErrorSection(),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Hero card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.9),
                  AppColors.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '🎯 AI-Powered Career Discovery',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Take our comprehensive career assessment to discover your perfect professional path',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Features grid with overflow protection
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 160, // Increased height to prevent overflow
            ),
            itemBuilder: (context, index) {
              final features = [
                {
                  'icon': Icons.psychology_alt_rounded,
                  'title': 'RIASEC Model',
                  'description': 'Holland\'s proven career classification',
                  'color': AppColors.primary,
                },
                {
                  'icon': Icons.person_search_rounded,
                  'title': 'Big Five Analysis',
                  'description': 'Deep personality insights',
                  'color': AppColors.accent,
                },
                {
                  'icon': Icons.category_rounded,
                  'title': 'MBTI Integration',
                  'description': '16 personality types mapping',
                  'color': AppColors.warning,
                },
                {
                  'icon': Icons.work_rounded,
                  'title': '200+ Professions',
                  'description': 'Comprehensive career database',
                  'color': AppColors.success,
                },
              ];
              
              final feature = features[index];
              return _buildFeatureCard(
                icon: feature['icon'] as IconData,
                title: feature['title'] as String,
                description: feature['description'] as String,
                color: feature['color'] as Color,
              );
            },
            itemCount: 4,
          ),

          const SizedBox(height: 32),

          // Start test button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _onTestStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Start Career Assessment',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                color: Color(0xFF6B7280),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeProfessionsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔥 Swipe Your Perfect Match',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          Text(
            'Discover careers in a fun, Tinder-like experience. Swipe right on professions that excite you!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Swipe CTA Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF1D4ED8),
                  Color(0xFF1E40AF),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Swipe animation preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSwipeIcon(Icons.thumb_down_rounded, const Color(0xFFEF4444)),
                    SizedBox(width: 20.w),
                    Container(
                      width: 60.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.work_rounded,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    _buildSwipeIcon(Icons.favorite_rounded, const Color(0xFF10B981)),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                Text(
                  'Interactive Career Discovery',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                Text(
                  'Swipe through personalized career matches based on your assessment results',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 20.h),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _launchSwipeExperience,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3B82F6),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe_rounded,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Start Swiping Careers',
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
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20.sp,
      ),
    );
  }

  void _launchSwipeExperience() {
    // Generate professions based on test results
    final professions = _generatePersonalizedProfessions();
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChangeNotifierProvider(
              create: (_) => SwipeDeckController(professions),
              child: const ProfessionsSwipeScreen(),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  List<Profession> _generatePersonalizedProfessions() {
    // Generate professions based on career test results
    return [
      Profession(
        id: 'software_engineer',
        title: 'Software Engineer',
        subtitle: 'Build innovative software solutions',
        matchLabel: '92% Match',
        matchPercentage: 0.92,
        skills: ['Programming', 'Problem Solving', 'Algorithms', 'Team Work'],
        education: "Bachelor's in Computer Science",
        salaryRange: '\$70,000 - \$150,000',
        pros: ['High demand', 'Remote work options', 'Creative problem solving'],
        cons: ['Long hours during deadlines', 'Continuous learning required'],
        heroImage: 'assets/images/careers/software_engineer.jpg',
        category: 'Technical',
        actionableAdvice: [
          '💻 Start with a free coding course on Coursera or Udemy',
          '🔧 Build a portfolio with 3-5 personal projects',
          '📚 Learn a popular programming language like Python or JavaScript',
          '🤝 Join developer communities on GitHub and Stack Overflow',
          '🎯 Apply for internships or entry-level positions',
        ],
        ctaLinks: {
          'jobs': 'https://stackoverflow.com/jobs',
          'courses': 'https://coursera.org/computer-science',
          'mentorship': 'https://mentorcruise.com',
        },
        priority: 10,
      ),
      
      Profession(
        id: 'data_scientist',
        title: 'Data Scientist',
        subtitle: 'Extract insights from complex data',
        matchLabel: '89% Match',
        matchPercentage: 0.89,
        skills: ['Python', 'Statistics', 'Machine Learning', 'SQL'],
        education: "Master's in Data Science or related field",
        salaryRange: '\$80,000 - \$160,000',
        pros: ['High growth field', 'Intellectual challenges', 'Impact on business'],
        cons: ['Requires advanced math', 'Data can be messy'],
        heroImage: 'assets/images/careers/data_scientist.jpg',
        category: 'Technical',
        actionableAdvice: [
          '📊 Learn Python and R for data analysis',
          '🧮 Study statistics and probability theory',
          '🤖 Take a machine learning course',
          '💾 Practice with real datasets on Kaggle',
          '📈 Build a data science portfolio',
        ],
        ctaLinks: {
          'jobs': 'https://kaggle.com/jobs',
          'courses': 'https://coursera.org/data-science',
          'mentorship': 'https://adplist.org',
        },
        priority: 9,
      ),
      
      Profession(
        id: 'ux_designer',
        title: 'UX Designer',
        subtitle: 'Create intuitive user experiences',
        matchLabel: '85% Match',
        matchPercentage: 0.85,
        skills: ['Design Thinking', 'Prototyping', 'User Research', 'Figma'],
        education: "Bachelor's in Design or related field",
        salaryRange: '\$60,000 - \$120,000',
        pros: ['Creative work', 'User impact', 'Growing field'],
        cons: ['Subjective feedback', 'Tight deadlines'],
        heroImage: 'assets/images/careers/ux_designer.jpg',
        category: 'Creative',
        actionableAdvice: [
          '🎨 Learn design tools like Figma and Sketch',
          '🔍 Study user research methodologies',
          '📱 Create UI/UX case studies for your portfolio',
          '👥 Practice with real user testing',
          '🏆 Participate in design challenges',
        ],
        ctaLinks: {
          'jobs': 'https://dribbble.com/jobs',
          'courses': 'https://coursera.org/ux-design',
          'mentorship': 'https://adplist.org',
        },
        priority: 8,
      ),
      
      Profession(
        id: 'product_manager',
        title: 'Product Manager',
        subtitle: 'Drive product strategy and execution',
        matchLabel: '82% Match',
        matchPercentage: 0.82,
        skills: ['Strategy', 'Analytics', 'Communication', 'Leadership'],
        education: "Bachelor's in Business or related field",
        salaryRange: '\$90,000 - \$180,000',
        pros: ['Strategic thinking', 'Cross-functional work', 'High impact'],
        cons: ['High pressure', 'Balancing stakeholders'],
        heroImage: 'assets/images/careers/product_manager.jpg',
        category: 'Business',
        actionableAdvice: [
          '📊 Learn product analytics tools',
          '🚀 Study successful product launches',
          '🤝 Develop stakeholder management skills',
          '📝 Practice writing product requirements',
          '💡 Work on a personal product project',
        ],
        ctaLinks: {
          'jobs': 'https://productmanagerhq.com/jobs',
          'courses': 'https://coursera.org/product-management',
          'mentorship': 'https://mentorcruise.com',
        },
        priority: 7,
      ),
      
      Profession(
        id: 'marketing_specialist',
        title: 'Digital Marketing Specialist',
        subtitle: 'Drive growth through digital channels',
        matchLabel: '78% Match',
        matchPercentage: 0.78,
        skills: ['SEO', 'Social Media', 'Analytics', 'Content Creation'],
        education: "Bachelor's in Marketing or related field",
        salaryRange: '\$45,000 - \$90,000',
        pros: ['Creative campaigns', 'Measurable results', 'Diverse channels'],
        cons: ['Algorithm changes', 'Constant adaptation needed'],
        heroImage: 'assets/images/careers/marketing_specialist.jpg',
        category: 'Business',
        actionableAdvice: [
          '📈 Get Google Analytics certification',
          '📱 Master social media advertising',
          '✍️ Create a content marketing blog',
          '🎯 Run A/B tests on campaigns',
          '📊 Learn marketing automation tools',
        ],
        ctaLinks: {
          'jobs': 'https://marketingjobs.com',
          'courses': 'https://coursera.org/digital-marketing',
          'mentorship': 'https://growthmentor.com',
        },
        priority: 6,
      ),
    ];
  }

  Widget _buildErrorSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 32,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Something went wrong',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? 'An unexpected error occurred. Please try again.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: AppColors.error.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'Go Back',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _onRetakeTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Try Again',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
enum CareerTestStatus {
  notStarted,
  inProgress,
  completed,
  error,
}

class CareerTestResult {
  final Map<String, double> riasecScores;
  final Map<String, double> bigFiveScores;
  final String mbtiType;
  final String klimovType;
  final String topRiasecCode;
  final String riasecInterpretation;
  final String personalityInsights;
  final List<CareerRecommendation> recommendations;
  final List<CareerInsight> insights;
  final List<CareerNextStep> nextSteps;
  final DateTime timestamp;

  CareerTestResult({
    required this.riasecScores,
    required this.bigFiveScores,
    required this.mbtiType,
    required this.klimovType,
    required this.topRiasecCode,
    required this.riasecInterpretation,
    required this.personalityInsights,
    required this.recommendations,
    required this.insights,
    required this.nextSteps,
    required this.timestamp,
  });

  factory CareerTestResult.fromApiResponse(Map<String, dynamic> data) {
    return CareerTestResult(
      riasecScores: data['riasecScores'] ?? {},
      bigFiveScores: data['bigFiveScores'] ?? {},
      mbtiType: data['mbtiType'] ?? '',
      klimovType: data['klimovType'] ?? '',
      topRiasecCode: data['topRiasecCode'] ?? '',
      riasecInterpretation: data['riasecInterpretation'] ?? '',
      personalityInsights: data['personalityInsights'] ?? '',
      recommendations: (data['recommendations'] as List?)
          ?.map((r) => CareerRecommendation.fromMap(r))
          .toList() ?? [],
      insights: (data['insights'] as List?)
          ?.map((i) => CareerInsight.fromMap(i))
          .toList() ?? [],
      nextSteps: (data['nextSteps'] as List?)
          ?.map((s) => CareerNextStep.fromMap(s))
          .toList() ?? [],
      timestamp: DateTime.now(),
    );
  }
}

class CareerInsight {
  final String title;
  final String description;

  CareerInsight({
    required this.title,
    required this.description,
  });

  factory CareerInsight.fromMap(Map<String, dynamic> map) {
    return CareerInsight(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

class CareerNextStep {
  final String number;
  final String title;
  final String description;

  CareerNextStep({
    required this.number,
    required this.title,
    required this.description,
  });

  factory CareerNextStep.fromMap(Map<String, dynamic> map) {
    return CareerNextStep(
      number: map['number'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

class CareerRecommendation {
  final String profession;
  final String description;
  final double matchScore;
  final List<String> requiredSkills;
  final String educationLevel;
  final String salaryRange;
  final List<String> pros;
  final List<String> cons;

  CareerRecommendation({
    required this.profession,
    required this.description,
    required this.matchScore,
    required this.requiredSkills,
    required this.educationLevel,
    required this.salaryRange,
    required this.pros,
    required this.cons,
  });

  factory CareerRecommendation.fromMap(Map<String, dynamic> map) {
    return CareerRecommendation(
      profession: map['profession'] ?? '',
      description: map['description'] ?? '',
      matchScore: (map['matchScore'] ?? 0.0).toDouble(),
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      educationLevel: map['educationLevel'] ?? '',
      salaryRange: map['salaryRange'] ?? '',
      pros: List<String>.from(map['pros'] ?? []),
      cons: List<String>.from(map['cons'] ?? []),
    );
  }
}

