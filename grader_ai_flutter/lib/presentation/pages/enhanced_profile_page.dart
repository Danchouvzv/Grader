import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models/user_profile.dart';
import '../../core/models/session_record.dart';
import '../../core/models/achievement.dart';
import '../../core/services/profile_service.dart';
import '../../shared/themes/app_theme.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/themes/design_system.dart';
import 'subscription_page.dart';

/// Enhanced Profile Page with proper Flutter architecture
/// Fixes all UI/UX and frontend issues mentioned in the review
class EnhancedProfilePage extends StatefulWidget {
  const EnhancedProfilePage({super.key});

  @override
  State<EnhancedProfilePage> createState() => _EnhancedProfilePageState();
}

class _EnhancedProfilePageState extends State<EnhancedProfilePage> 
    with TickerProviderStateMixin {
  
  // Services
  final ProfileService _profileService = ProfileService();
  
  // State
  UserProfile? _profile;
  List<SessionRecord> _recentSessions = [];
  List<Achievement> _achievements = [];
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _weeklyProgress = [];
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _counterController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _counterAnimation;
  
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfileData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _counterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _counterController.forward();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Initialize profile if doesn't exist
      _profile = await _profileService.getCurrentProfile();
      _profile ??= await _profileService.initializeProfile('User');
      
      if (_profile != null) {
        // Load all profile data in parallel
        final futures = await Future.wait([
          _profileService.getRecentSessions(_profile!.id!),
          _profileService.getAchievements(_profile!.id!),
          _profileService.getUserStats(_profile!.id!),
          _profileService.getWeeklyProgress(_profile!.id!),
        ]);
        
        _recentSessions = futures[0] as List<SessionRecord>;
        _achievements = futures[1] as List<Achievement>;
        _stats = futures[2] as Map<String, dynamic>;
        _weeklyProgress = futures[3] as List<Map<String, dynamic>>;
        
        // 🎯 MOCK DATA FOR DEMO - Replace with real data
        _loadMockData();
        
        print('🏆 Profile loaded:');
        print('   Achievements: ${_achievements.length}');
        print('   Types: ${_achievements.map((a) => a.achievementType).toList()}');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile data: $e';
      });
      print('❌ Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadMockData() {
    // Mock profile with realistic progress
    _profile = UserProfile(
      id: _profile?.id ?? 1,
      name: 'Alex Johnson',
      email: 'alex.johnson@email.com',
      targetBand: 7.5,
      currentStreak: 14, // 14 days streak
      avatarPath: 'professional',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );

    // Mock stats showing improvement
    _stats = {
      'totalSessions': 47,
      'totalTime': 1840, // minutes
      'averageBand': 6.8, // improved from 6.3
      'bestBand': 7.2, // improved from 6.8
      'currentLevel': 8,
      'xpToNextLevel': 320,
      'totalXP': 2840,
    };

    // Mock weekly progress showing improvement trend
    final now = DateTime.now();
    _weeklyProgress = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
      
      // Simulate increasing performance over the week
      final baseSessions = [2, 3, 1, 4, 2, 3, 5][index];
      final baseBand = [6.5, 6.7, 6.4, 6.9, 6.6, 6.8, 7.1][index];
      
      return {
        'day': dayName,
        'sessions': baseSessions,
        'band': baseBand,
        'date': DateFormat('yyyy-MM-dd').format(date),
      };
    });

    // Mock recent sessions with improvement
    _recentSessions = [
      SessionRecord(
        id: 1,
        userId: _profile!.id!,
        overallBand: 7.2,
        fluency: 7.0,
        lexical: 7.5,
        grammar: 7.0,
        pronunciation: 7.3,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SessionRecord(
        id: 2,
        userId: _profile!.id!,
        overallBand: 6.9,
        fluency: 6.8,
        lexical: 7.0,
        grammar: 6.9,
        pronunciation: 7.0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SessionRecord(
        id: 3,
        userId: _profile!.id!,
        overallBand: 6.7,
        fluency: 6.5,
        lexical: 6.8,
        grammar: 6.7,
        pronunciation: 6.8,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    // Mock achievements - unlock some realistic ones
    _achievements = [
      Achievement(
        id: 1,
        userId: _profile!.id!,
        achievementType: 'first_session',
        title: 'First Steps',
        description: 'Complete your first IELTS speaking session',
        unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
        iconData: 'Icons.flag_rounded',
        colorHex: '#3B82F6',
      ),
      Achievement(
        id: 2,
        userId: _profile!.id!,
        achievementType: 'streak_7',
        title: 'Week Warrior',
        description: 'Practice for 7 days straight',
        unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
        iconData: 'Icons.local_fire_department_rounded',
        colorHex: '#F59E0B',
      ),
      Achievement(
        id: 3,
        userId: _profile!.id!,
        achievementType: 'streak_14',
        title: 'Streak Master',
        description: 'Practice for 14 days straight',
        unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
        iconData: 'Icons.local_fire_department_rounded',
        colorHex: '#EF4444',
      ),
      Achievement(
        id: 4,
        userId: _profile!.id!,
        achievementType: 'band_improvement',
        title: 'Rising Star',
        description: 'Improve your band score by 0.5 points',
        unlockedAt: DateTime.now().subtract(const Duration(days: 3)),
        iconData: 'Icons.trending_up_rounded',
        colorHex: '#10B981',
      ),
      Achievement(
        id: 5,
        userId: _profile!.id!,
        achievementType: 'sessions_25',
        title: 'Dedicated Learner',
        description: 'Complete 25 practice sessions',
        unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
        iconData: 'Icons.emoji_events_rounded',
        colorHex: '#8B5CF6',
      ),
    ];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading 
            ? _buildLoadingState()
            : _error != null 
                ? _buildErrorState()
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: DesignSystem.backgroundGradient,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            
            // Header skeleton
            _buildShimmerCard(
              height: 260.h,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  // Avatar skeleton
                  _buildShimmerCircle(diameter: 100.w),
                  SizedBox(height: 16.h),
                  // Name skeleton
                  _buildShimmerBox(width: 150.w, height: 24.h),
                  SizedBox(height: 8.h),
                  // Target skeleton
                  _buildShimmerBox(width: 100.w, height: 18.h),
                  SizedBox(height: 24.h),
                  // Metrics row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShimmerBox(width: 140.w, height: 90.h),
                      _buildShimmerBox(width: 140.w, height: 90.h),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Stats grid skeleton
            _buildShimmerCard(
              height: 180.h,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                padding: EdgeInsets.all(16.w),
                children: List.generate(
                  4,
                  (index) => _buildShimmerBox(width: double.infinity, height: double.infinity),
                ),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Weekly progress skeleton
            _buildShimmerCard(
              height: 240.h,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(width: 150.w, height: 20.h),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          7,
                          (index) => _buildShimmerBox(
                            width: 30.w,
                            height: (60 + (index * 15) % 100).h,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Achievements skeleton
            _buildShimmerCard(
              height: 160.h,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(width: 120.w, height: 18.h),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: List.generate(
                        6,
                        (index) => _buildShimmerCircle(diameter: 60.w),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard({
    required double height,
    required EdgeInsets margin,
    required Widget child,
  }) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
        boxShadow: DesignSystem.cardShadow,
      ),
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: -1.0, end: 2.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: [
                        value - 0.3,
                        value,
                        value + 0.3,
                      ].map((e) => e.clamp(0.0, 1.0)).toList(),
                    ),
                  ),
                );
              },
              onEnd: () {
                if (mounted && _isLoading) {
                  setState(() {});
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DesignSystem.surfaceGray,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium.r),
      ),
    );
  }

  Widget _buildShimmerCircle({required double diameter}) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: DesignSystem.surfaceGray,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.w,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _error!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadProfileData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: DesignSystem.backgroundGradient,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Enhanced Header
              _buildEnhancedHeader(),
              
              // Stats Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: DesignSystem.space20.w),
                  child: _buildStatsGrid(),
                ),
              ),
              
              // Weekly Progress Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    DesignSystem.space20.w,
                    DesignSystem.space16.h,
                    DesignSystem.space20.w,
                    0,
                  ),
                  child: _buildWeeklyProgressChart(),
                ),
              ),
              
              // Recent Sessions
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    DesignSystem.space20.w,
                    DesignSystem.space16.h,
                    DesignSystem.space20.w,
                    0,
                  ),
                  child: _buildRecentSessions(),
                ),
              ),
              
              // Achievements
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    DesignSystem.space20.w,
                    DesignSystem.space16.h,
                    DesignSystem.space20.w,
                    0,
                  ),
                  child: _buildAchievements(),
                ),
              ),
              
              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: 100.h),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(DesignSystem.space20.w),
        child: Column(
          children: [
            // Hero Card with Avatar and Name
            _buildHeroCard(),
            
            SizedBox(height: DesignSystem.space16.h),
            
            // Key Metrics Row
            _buildKeyMetricsRow(),
            
            SizedBox(height: DesignSystem.space16.h),
            
            // Premium Button
            _buildPremiumButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: EdgeInsets.all(DesignSystem.space24.w),
      decoration: BoxDecoration(
        gradient: DesignSystem.premiumGradient,
        borderRadius: BorderRadius.circular(DesignSystem.radiusXLarge.r),
        boxShadow: DesignSystem.blueShadow,
      ),
      child: Row(
        children: [
          // Avatar with 3D effect
          _buildPremiumAvatar(),
          
          SizedBox(width: 16.w),
          
          // Name and Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile?.name ?? 'IELTS Learner',
                  style: DesignSystem.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 28.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.military_tech_rounded,
                        color: DesignSystem.amber400,
                        size: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Level ${_profile?.level ?? 1}',
                        style: DesignSystem.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Settings Button
          _buildGlassButton(
            icon: Icons.settings_rounded,
            onTap: _showEditProfileDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAvatar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _getAvatarGradient(),
              ),
              child: Center(
                child: _profile?.avatarPath != null && _profile!.avatarPath!.isNotEmpty
                    ? Icon(
                        _getAvatarIcon(_profile!.avatarPath!),
                        color: Colors.white,
                        size: 32.w,
                      )
                    : Text(
                        _getInitials(),
                        style: DesignSystem.headlineLarge.copyWith(
                          color: Colors.white,
                          fontSize: 24.sp,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20.w,
        ),
      ),
    );
  }

  Widget _buildKeyMetricsRow() {
    return Row(
      children: [
        // Streak Metric
        Expanded(
          child: _buildStreakCard(),
        ),
        
        SizedBox(width: DesignSystem.space12.w),
        
        // Target Score Metric
        Expanded(
          child: _buildTargetCard(),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    final streakDays = _profile?.currentStreak ?? 0;
    return Container(
      padding: EdgeInsets.all(DesignSystem.space20.w),
      decoration: BoxDecoration(
        gradient: DesignSystem.streakGradient,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
        boxShadow: DesignSystem.amberShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          SizedBox(height: DesignSystem.space12.h),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: streakDays.toDouble()),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '${value.toInt()}',
                style: DesignSystem.metric.copyWith(
                  color: Colors.white,
                  fontSize: 36.sp,
                ),
              );
            },
          ),
          SizedBox(height: 4.h),
          Text(
            'Day Streak',
            style: DesignSystem.metricLabel.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard() {
    final targetBand = _profile?.targetBand ?? 7.0;
    return Container(
      padding: EdgeInsets.all(DesignSystem.space20.w),
      decoration: BoxDecoration(
        gradient: DesignSystem.targetGradient,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
        boxShadow: DesignSystem.purpleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.flag_rounded,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          SizedBox(height: DesignSystem.space12.h),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: targetBand),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                value.toStringAsFixed(1),
                style: DesignSystem.metric.copyWith(
                  color: Colors.white,
                  fontSize: 36.sp,
                ),
              );
            },
          ),
          SizedBox(height: 4.h),
          Text(
            'Target Score',
            style: DesignSystem.metricLabel.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildPremiumButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubscriptionPage(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: DesignSystem.space20.h,
          horizontal: DesignSystem.space24.w,
        ),
        decoration: BoxDecoration(
          gradient: DesignSystem.ctaGradient,
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
          boxShadow: DesignSystem.pinkShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 20.w,
              ),
            ),
            SizedBox(width: DesignSystem.space12.w),
            Text(
              'Upgrade to Premium',
              style: DesignSystem.headlineSmall.copyWith(
                color: Colors.white,
                fontSize: 17.sp,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    final initials = _profile?.name?.isNotEmpty == true 
        ? _profile!.name!.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';
    
    // Get avatar icon and color (красно-синяя тема)
    IconData avatarIcon = Icons.person_rounded;
    Color avatarColor = const Color(0xFF3B82F6); // Синий по умолчанию
    
    if (_profile?.avatarPath != null && _profile!.avatarPath!.isNotEmpty) {
      switch (_profile!.avatarPath) {
        case 'Default':
          avatarIcon = Icons.person_rounded;
          avatarColor = const Color(0xFF3B82F6); // Синий
          break;
        case 'Student':
          avatarIcon = Icons.school_rounded;
          avatarColor = const Color(0xFF1E40AF); // Темно-синий
          break;
        case 'Professional':
          avatarIcon = Icons.work_rounded;
          avatarColor = const Color(0xFFEF4444); // Красный
          break;
        case 'Creative':
          avatarIcon = Icons.palette_rounded;
          avatarColor = const Color(0xFFDC2626); // Темно-красный
          break;
        case 'Tech':
          avatarIcon = Icons.computer_rounded;
          avatarColor = const Color(0xFF60A5FA); // Светло-синий
          break;
        case 'Nature':
          avatarIcon = Icons.eco_rounded;
          avatarColor = const Color(0xFF3B82F6); // Синий
          break;
        default:
          avatarIcon = Icons.person_rounded;
          avatarColor = const Color(0xFF3B82F6); // Синий
      }
    }
    
    return Container(
      width: 90.w,
      height: 90.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              avatarColor,
              avatarColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: _profile?.avatarPath != null && _profile!.avatarPath!.isNotEmpty
              ? Icon(
                  avatarIcon,
                  size: 38.w,
                  color: Colors.white,
                )
              : Text(
                  initials,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name with shimmer effect container
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, color: Colors.white, size: 16.w),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  _profile?.name ?? 'User',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        
        // Level badge
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.military_tech_rounded, color: Colors.white, size: 14.w),
                  SizedBox(width: 4.w),
                  Text(
                    'LVL ${_profile?.level ?? 1}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                _profile?.levelTitle ?? 'Beginner',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.95),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        if (_profile?.sessionsToNextLevel != null && _profile!.sessionsToNextLevel > 0) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: Colors.lightGreenAccent,
                  size: 14.w,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${_profile!.sessionsToNextLevel} to next level',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTargetScoreMetric() {
    final targetBand = _profile?.targetBand ?? 7.0;
    return AnimatedBuilder(
      animation: _counterAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.space12.w,
            vertical: DesignSystem.space16.h,
          ),
          decoration: DesignSystem.cardDecoration(
            color: DesignSystem.surface,
            radius: DesignSystem.radiusMedium,
            border: Border.all(color: const Color(0xFF2563EB), width: 1.5), // blue accent border
            shadow: DesignSystem.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.9 + (value * 0.1),
                    child: Container(
                      padding: EdgeInsets.all(DesignSystem.space8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(DesignSystem.radiusSmall.r),
                        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.25), width: 1),
                      ),
                      child: Icon(
                        Icons.flag_rounded,
                        color: const Color(0xFF2563EB),
                        size: 20.w,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: DesignSystem.space8.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: targetBand * _counterAnimation.value),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Band ',
                          style: DesignSystem.bodyMedium.copyWith(
                            color: DesignSystem.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          value.toStringAsFixed(1),
                          style: DesignSystem.headlineSmall.copyWith(
                            color: DesignSystem.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: DesignSystem.space4.h),
              Text(
                'Target Score',
                style: DesignSystem.caption.copyWith(
                  color: DesignSystem.textSecondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: _showSettingsMenu,
        icon: Icon(
          Icons.settings_rounded,
          color: Colors.white,
          size: 24.w,
        ),
        tooltip: 'Settings', // Accessibility
      ),
    );
  }

  Widget _buildKeyMetric({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Flexible(
      flex: 1,
      child: AnimatedBuilder(
        animation: _counterAnimation,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignSystem.space12.w,
              vertical: DesignSystem.space16.h,
            ),
            decoration: DesignSystem.glassDecoration(
              radius: DesignSystem.radiusMedium,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(DesignSystem.space8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusSmall.r),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24.w,
                  ),
                ),
                SizedBox(height: DesignSystem.space8.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: DesignSystem.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: DesignSystem.space4.h),
                Text(
                  label,
                  style: DesignSystem.caption.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: DesignSystem.space16.h,
      crossAxisSpacing: DesignSystem.space16.w,
      childAspectRatio: 1.0, // Увеличил с 1.15 до 1.0 для предотвращения overflow
      children: [
        StatCard(
          icon: Icons.analytics_rounded,
          value: '${_stats['totalSessions'] ?? 0}',
          label: 'Sessions',
          color: DesignSystem.blue600,
        ),
        StatCard(
          icon: Icons.timer_rounded,
          value: _formatDuration(_stats['totalPracticeTime'] ?? 0),
          label: 'Time',
          color: DesignSystem.purple600,
        ),
        StatCard(
          icon: Icons.trending_up_rounded,
          value: (_stats['averageBand'] ?? 0.0).toStringAsFixed(1),
          label: 'Avg Band',
          color: DesignSystem.green600,
        ),
        StatCard(
          icon: Icons.emoji_events_rounded,
          value: (_stats['bestBand'] ?? 0.0).toStringAsFixed(1),
          label: 'Best',
          color: DesignSystem.amber500,
          isHighlighted: true,
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressChart() {
    // Calculate weekly stats (support both 'sessions' and 'sessions_count' keys)
    final totalWeeklySessions = _weeklyProgress.fold<int>(
      0, (sum, day) => sum + ((day['sessions'] ?? day['sessions_count']) as int? ?? 0),
    );
    final avgBand = _weeklyProgress.isEmpty 
        ? 0.0 
        : _weeklyProgress
            .map((d) => (d['band'] ?? d['average_band']) as double? ?? 0.0)
            .reduce((a, b) => a + b) / _weeklyProgress.length;
    
    final maxSessions = _weeklyProgress.isEmpty 
        ? 1 
        : _weeklyProgress
            .map((d) => (d['sessions'] ?? d['sessions_count']) as int? ?? 0)
            .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: EdgeInsets.all(DesignSystem.space24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignSystem.green50,
            DesignSystem.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusXLarge.r),
        border: Border.all(
          color: DesignSystem.green500.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.green500.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  gradient: DesignSystem.successGradient,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.green500.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 24.w,
                ),
              ),
              SizedBox(width: DesignSystem.space16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Progress',
                      style: DesignSystem.headlineMedium.copyWith(
                        color: DesignSystem.textPrimary,
                        fontSize: 19.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        _buildMiniStat(
                          icon: Icons.timeline_rounded,
                          value: '$totalWeeklySessions',
                          label: 'sessions',
                        ),
                        SizedBox(width: 16.w),
                        _buildMiniStat(
                          icon: Icons.star_rounded,
                          value: avgBand.toStringAsFixed(1),
                          label: 'avg',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: DesignSystem.space24.h),
          
          // Chart
          if (_weeklyProgress.isEmpty)
            _buildEmptyProgressState()
          else
            _buildEnhancedProgressChart(maxSessions),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.w,
          color: DesignSystem.green600,
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: DesignSystem.bodySmall.copyWith(
            fontWeight: FontWeight.w800,
            color: DesignSystem.green600,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          label,
          style: DesignSystem.caption.copyWith(
            color: DesignSystem.textSecondary,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedProgressChart(int maxSessions) {
    return Container(
      height: 180.h,
      padding: EdgeInsets.all(DesignSystem.space16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
        border: Border.all(
          color: DesignSystem.green500.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _weeklyProgress.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final sessions = (data['sessions'] ?? data['sessions_count']) as int? ?? 0;
          // Get day name from 'day' field or parse from 'date' field
          final day = data['day'] as String? ?? 
                      (data['date'] != null 
                          ? DateFormat('EEE').format(DateTime.parse(data['date'] as String))
                          : '');
          final isToday = index == _weeklyProgress.length - 1;
          
          return Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final height = maxSessions == 0 
                    ? 0.0 
                    : (sessions / maxSessions * 100 * value);
                
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Sessions count
                      if (sessions > 0)
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Text(
                            '$sessions',
                            style: DesignSystem.caption.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: isToday 
                                  ? DesignSystem.green600 
                                  : DesignSystem.textSecondary,
                            ),
                          ),
                        ),
                      
                      // Bar
                      Container(
                        width: double.infinity,
                        height: height.h,
                        decoration: BoxDecoration(
                          gradient: isToday
                              ? DesignSystem.successGradient
                              : LinearGradient(
                                  colors: [
                                    DesignSystem.green500.withOpacity(0.7),
                                    DesignSystem.green400.withOpacity(0.5),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(8.r),
                          ),
                          boxShadow: isToday && sessions > 0
                              ? [
                                  BoxShadow(
                                    color: DesignSystem.green500.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // Day label
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 4.h,
                        ),
                        decoration: isToday
                            ? BoxDecoration(
                                gradient: DesignSystem.successGradient,
                                borderRadius: BorderRadius.circular(6.r),
                              )
                            : null,
                        child: Text(
                          day,
                          style: DesignSystem.caption.copyWith(
                            fontSize: 10.sp,
                            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                            color: isToday 
                                ? Colors.white 
                                : DesignSystem.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyProgressState() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              color: AppColors.textTertiary,
              size: 32.w,
            ),
            SizedBox(height: 8.h),
            Text(
              'Start practicing to see your progress!',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    // Generate sample data for the last 7 days
    final now = DateTime.now();
    final weeklyData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayData = _weeklyProgress.firstWhere(
        (data) => data['date'] == DateFormat('yyyy-MM-dd').format(date),
        orElse: () => {'sessions_count': 0, 'average_band': 0.0},
      );
      
      return {
        'day': _getDayName(date.weekday),
        'sessions': dayData['sessions_count'] ?? 0,
        'band': (dayData['average_band'] ?? 0.0).toDouble(),
        'date': date,
      };
    });

    final maxSessions = weeklyData.map((e) => e['sessions'] as int).reduce((a, b) => a > b ? a : b);
    final maxValue = maxSessions > 0 ? maxSessions.toDouble() : 5.0;

    return Container(
      height: 200.h,
      child: Column(
        children: [
          // Chart
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8.r,
                    tooltipPadding: EdgeInsets.all(8.w),
                    tooltipMargin: 8.w,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final data = weeklyData[group.x.toInt()];
                      return BarTooltipItem(
                        '${data['day']}\n${data['sessions']} sessions\nBand: ${data['band'].toStringAsFixed(1)}',
                        TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final data = weeklyData[value.toInt()];
                        return Text(
                          data['day'] as String,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final sessions = data['sessions'] as int;
                  final band = data['band'] as double;
                  
                  Color barColor;
                  if (band >= 7.0) {
                    barColor = AppColors.success;
                  } else if (band >= 6.0) {
                    barColor = AppColors.warning;
                  } else if (band > 0) {
                    barColor = AppColors.error;
                  } else {
                    barColor = const Color(0xFFE2E8F0);
                  }
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: sessions.toDouble(),
                        color: barColor,
                        width: 20.w,
                        borderRadius: BorderRadius.circular(4.r),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxValue,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE2E8F0),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Legend
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildLegendItem('High Score', AppColors.success, 'Band 7.0+'),
              _buildLegendItem('Good Score', AppColors.warning, 'Band 6.0-6.9'),
              _buildLegendItem('Needs Work', AppColors.error, 'Band <6.0'),
              _buildLegendItem('No Data', const Color(0xFFE2E8F0), 'No sessions'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String description) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 8.sp,
            color: AppColors.textTertiary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildProgressBar(String day, int sessions, double averageBand) {
    final height = sessions > 0 ? (sessions * 15.0).clamp(10.0, 80.0) : 10.0;
    final color = averageBand >= 7.0 
        ? AppColors.success
        : averageBand >= 6.0 
            ? AppColors.warning
            : AppColors.error;
    
    return Container(
      width: 40.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 20.w,
            height: height,
            decoration: BoxDecoration(
              color: sessions > 0 ? color : AppColors.border,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            day,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions() {
    return Container(
      padding: EdgeInsets.all(DesignSystem.space24.w),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusXLarge.r),
        border: Border.all(
          color: DesignSystem.purple500.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: DesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignSystem.purple500.withOpacity(0.15),
                      DesignSystem.purple400.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: DesignSystem.purple600,
                  size: 24.w,
                ),
              ),
              SizedBox(width: DesignSystem.space12.w),
              Text(
                'Recent Sessions',
                style: DesignSystem.headlineMedium.copyWith(
                  color: DesignSystem.textPrimary,
                  fontSize: 19.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSystem.space20.h),
          if (_recentSessions.isEmpty)
            _buildEmptySessionsState()
          else
            ...(_recentSessions.take(5).map((session) => _buildSessionItem(session))),
        ],
      ),
    );
  }

  Widget _buildEmptySessionsState() {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              color: AppColors.textTertiary,
              size: 32.w,
            ),
            SizedBox(height: 8.h),
            Text(
              'No sessions yet. Start practicing!',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(SessionRecord session) {
    // Определяем цвет на основе балла
    Color scoreColor;
    if (session.overallBand >= 7.0) {
      scoreColor = DesignSystem.primaryBlue;
    } else if (session.overallBand >= 6.0) {
      scoreColor = DesignSystem.accentRed;
    } else {
      scoreColor = DesignSystem.red600;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: DesignSystem.space12.h),
      padding: EdgeInsets.all(DesignSystem.space16.w),
      decoration: BoxDecoration(
        color: DesignSystem.background,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium.r),
        border: Border.all(
          color: DesignSystem.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Badge с баллом
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall.r),
            ),
            child: Center(
              child: Text(
                session.overallBand.toStringAsFixed(1),
                style: DesignSystem.headlineSmall.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          SizedBox(width: DesignSystem.space12.w),
          // Информация о сессии
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.partTitle,
                  style: DesignSystem.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DesignSystem.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: DesignSystem.space4.h),
                Text(
                  '${session.formattedDuration} • ${session.formattedDate}',
                  style: DesignSystem.caption.copyWith(
                    color: DesignSystem.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Иконка стрелки
          Icon(
            Icons.chevron_right_rounded,
            color: DesignSystem.textTertiary,
            size: 20.w,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final userId = _profile?.id ?? 0;
    // Get all possible achievements
    final allPossibleAchievements = Achievement.getAllPossibleAchievements(userId);
    final unlockedTypes = _achievements.map((a) => a.achievementType).toSet();
    
    // Split into unlocked and locked
    final unlockedAchievements = _achievements.toList();
    final lockedAchievements = allPossibleAchievements
        .where((a) => !unlockedTypes.contains(a.achievementType))
        .take(3)
        .toList();
    
    final totalPossible = allPossibleAchievements.length;
    final progress = totalPossible > 0 ? _achievements.length / totalPossible : 0.0;

    return Container(
      padding: EdgeInsets.all(DesignSystem.space24.w),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusXLarge.r),
        border: Border.all(
          color: DesignSystem.amber500.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: DesignSystem.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header с прогрессом
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignSystem.amber500.withOpacity(0.2),
                      DesignSystem.amber400.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: DesignSystem.amber500,
                  size: 24.w,
                ),
              ),
              SizedBox(width: DesignSystem.space12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievements',
                      style: DesignSystem.headlineMedium.copyWith(
                        color: DesignSystem.textPrimary,
                        fontSize: 19.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${_achievements.length} / $totalPossible unlocked',
                      style: DesignSystem.caption.copyWith(
                        color: DesignSystem.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              // Circular progress indicator
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return SizedBox(
                    width: 56.w,
                    height: 56.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: value,
                          strokeWidth: 5,
                          backgroundColor: DesignSystem.amber500.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.amber500),
                        ),
                        Text(
                          '${(value * 100).toInt()}%',
                          style: DesignSystem.bodySmall.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.sp,
                            color: DesignSystem.amber500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          
          SizedBox(height: DesignSystem.space24.h),
          
          // Unlocked Achievements
          if (unlockedAchievements.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 3.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [DesignSystem.amber500, DesignSystem.orange500],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: DesignSystem.space8.w),
                Text(
                  'UNLOCKED',
                  style: DesignSystem.label.copyWith(
                    color: DesignSystem.amber500,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSystem.space12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: unlockedAchievements.take(6).map((achievement) => 
                _buildPremiumAchievementCard(achievement, isLocked: false)
              ).toList(),
            ),
          ],
          
          // Next Achievements to Unlock
          if (lockedAchievements.isNotEmpty) ...[
            SizedBox(height: DesignSystem.space24.h),
            Row(
              children: [
                Container(
                  width: 3.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: DesignSystem.textTertiary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: DesignSystem.space8.w),
                Text(
                  'COMING SOON',
                  style: DesignSystem.label.copyWith(
                    color: DesignSystem.textTertiary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSystem.space12.h),
            Column(
              children: lockedAchievements.map((achievement) => 
                _buildPremiumAchievementCard(achievement, isLocked: true)
              ).toList(),
            ),
          ],
          
          // Empty state
          if (_achievements.isEmpty)
            _buildEmptyAchievementsState(),
        ],
      ),
    );
  }

  Widget _buildPremiumAchievementCard(Achievement achievement, {required bool isLocked}) {
    final colorHex = achievement.colorHex ?? '#3B82F6';
    final color = isLocked 
        ? DesignSystem.textTertiary 
        : Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (_achievements.indexOf(achievement) * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: isLocked ? 12.h : 0),
              padding: EdgeInsets.all(DesignSystem.space16.w),
              decoration: BoxDecoration(
                color: isLocked 
                    ? DesignSystem.surfaceGray 
                    : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
                border: Border.all(
                  color: isLocked 
                      ? DesignSystem.divider 
                      : color.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      gradient: isLocked 
                          ? null 
                          : LinearGradient(
                              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                            ),
                      color: isLocked ? DesignSystem.background : null,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: achievement.iconData != null
                          ? Icon(
                              _parseIconData(achievement.iconData),
                              color: isLocked ? DesignSystem.textTertiary : color,
                              size: 24.w,
                            )
                          : Text(
                              achievement.icon,
                              style: TextStyle(
                                fontSize: 18.w,
                                color: isLocked ? DesignSystem.textTertiary : color,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(width: DesignSystem.space12.w),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: DesignSystem.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isLocked 
                                ? DesignSystem.textTertiary 
                                : DesignSystem.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          achievement.description,
                          style: DesignSystem.caption.copyWith(
                            color: isLocked 
                                ? DesignSystem.textTertiary 
                                : DesignSystem.textSecondary,
                            fontSize: 11.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Progress bar для locked achievements
                        if (isLocked) ...[
                          SizedBox(height: 8.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: LinearProgressIndicator(
                              value: 0.3, // Можно сделать динамическим
                              minHeight: 4.h,
                              backgroundColor: DesignSystem.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.amber500),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Badge for unlocked
                  if (!isLocked) ...[
                    SizedBox(width: DesignSystem.space8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.2), color.withOpacity(0.15)],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        achievement.formattedDate,
                        style: DesignSystem.label.copyWith(
                          color: color,
                          fontSize: 9.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyAchievementsState() {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: AppColors.textTertiary,
              size: 32.w,
            ),
            SizedBox(height: 8.h),
            Text(
              'Complete sessions to unlock achievements!',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(Achievement achievement) {
    // Parse color from hex
    Color achievementColor = AppColors.primary;
    if (achievement.colorHex != null) {
      try {
        achievementColor = Color(int.parse(achievement.colorHex!.replaceFirst('#', '0xFF')));
      } catch (e) {
        achievementColor = AppColors.primary;
      }
    }

    // Get icon from iconData
    IconData iconData = Icons.star_rounded;
    if (achievement.iconData != null) {
      switch (achievement.iconData) {
        case 'Icons.flag_rounded':
          iconData = Icons.flag_rounded;
          break;
        case 'Icons.star_rounded':
          iconData = Icons.star_rounded;
          break;
        case 'Icons.school_rounded':
          iconData = Icons.school_rounded;
          break;
        case 'Icons.school_outlined':
          iconData = Icons.school_outlined;
          break;
        case 'Icons.military_tech_rounded':
          iconData = Icons.military_tech_rounded;
          break;
        case 'Icons.emoji_events_rounded':
          iconData = Icons.emoji_events_rounded;
          break;
        case 'Icons.local_fire_department_rounded':
          iconData = Icons.local_fire_department_rounded;
          break;
        case 'Icons.calendar_today_rounded':
          iconData = Icons.calendar_today_rounded;
          break;
        case 'Icons.workspace_premium_rounded':
          iconData = Icons.workspace_premium_rounded;
          break;
        case 'Icons.workspace_premium_outlined':
          iconData = Icons.workspace_premium_outlined;
          break;
        case 'Icons.access_time_rounded':
          iconData = Icons.access_time_rounded;
          break;
        case 'Icons.timer_rounded':
          iconData = Icons.timer_rounded;
          break;
        case 'Icons.schedule_rounded':
          iconData = Icons.schedule_rounded;
          break;
        case 'Icons.mic_rounded':
          iconData = Icons.mic_rounded;
          break;
        case 'Icons.trending_up_rounded':
          iconData = Icons.trending_up_rounded;
          break;
        case 'Icons.diamond_rounded':
          iconData = Icons.diamond_rounded;
          break;
        default:
          iconData = Icons.star_rounded;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.space16.w,
        vertical: DesignSystem.space12.h,
      ),
      decoration: BoxDecoration(
        color: DesignSystem.background,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium.r),
        border: Border.all(
          color: achievementColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(DesignSystem.space8.w),
            decoration: BoxDecoration(
              color: achievementColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall.r),
            ),
            child: Icon(
              iconData,
              color: achievementColor,
              size: 18.w,
            ),
          ),
          SizedBox(width: DesignSystem.space12.w),
          // Title
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  achievement.title,
                  style: DesignSystem.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DesignSystem.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: DesignSystem.space4.h),
                Text(
                  achievement.formattedDate,
                  style: DesignSystem.caption.copyWith(
                    color: DesignSystem.textSecondary,
                    fontSize: 10.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            _buildSettingsItem('Edit Profile', Icons.edit_rounded, _showEditProfileDialog),
            _buildSettingsItem('Set Target Band', Icons.flag_rounded, _showTargetBandDialog),
            _buildSettingsItem('Export Data', Icons.download_rounded, () {}),
            _buildSettingsItem('Reset Progress', Icons.refresh_rounded, () {}),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon, 
          color: AppColors.primary,
          size: 20.w,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
        size: 20.w,
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _profile?.name ?? '');
    final emailController = TextEditingController(text: _profile?.email ?? '');
    String selectedAvatar = _profile?.avatarPath ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
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
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Customize your profile information',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24.w,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        // Avatar Section
                        _buildAvatarSection(selectedAvatar, (avatar) {
                          setState(() {
                            selectedAvatar = avatar;
                          });
                        }),

                        SizedBox(height: 32.h),

                        // Form Fields
                        _buildTextField(
                          controller: nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline_rounded,
                          hint: 'Enter your full name',
                        ),

                        SizedBox(height: 20.h),

                        _buildTextField(
                          controller: emailController,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          hint: 'Your email address',
                          enabled: false,
                        ),

                        SizedBox(height: 20.h),

                        // Target Band Section
                        _buildTargetBandSection(),

                        SizedBox(height: 20.h),

                        // Preferences Section
                        _buildPreferencesSection(),

                        SizedBox(height: 32.h),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  side: BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _updateProfile(
                                    name: nameController.text.trim(),
                                    avatarPath: selectedAvatar,
                                  );
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTargetBandDialog() {
    double currentTarget = _profile?.targetBand ?? 7.0;
    double selectedTarget = currentTarget;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Set Target Band',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Target: ${currentTarget.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Select Target Band:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${selectedTarget.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Slider(
                      value: selectedTarget,
                      min: 4.0,
                      max: 9.0,
                      divisions: 50,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.border,
                      onChanged: (value) {
                        setState(() {
                          selectedTarget = value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('4.0', style: TextStyle(color: AppColors.textSecondary)),
                        Text('9.0', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateTargetBand(selectedTarget);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: Text('Set Target'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(String selectedAvatar, Function(String) onAvatarSelected) {
    final avatars = [
      {'name': 'Default', 'icon': Icons.person_rounded, 'color': AppColors.primary},
      {'name': 'Student', 'icon': Icons.school_rounded, 'color': AppColors.info},
      {'name': 'Professional', 'icon': Icons.work_rounded, 'color': AppColors.success},
      {'name': 'Creative', 'icon': Icons.palette_rounded, 'color': AppColors.accent},
      {'name': 'Tech', 'icon': Icons.computer_rounded, 'color': AppColors.warning},
      {'name': 'Nature', 'icon': Icons.eco_rounded, 'color': AppColors.secondary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Avatar',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Choose an avatar that represents you',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1,
          ),
          itemCount: avatars.length,
          itemBuilder: (context, index) {
            final avatar = avatars[index];
            final isSelected = selectedAvatar == avatar['name'] as String;
            
            return GestureDetector(
              onTap: () => onAvatarSelected(avatar['name'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                    ? (avatar['color'] as Color).withOpacity(0.1)
                    : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected 
                      ? avatar['color'] as Color
                      : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: (avatar['color'] as Color).withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      avatar['icon'] as IconData,
                      color: avatar['color'] as Color,
                      size: 28.w,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      avatar['name'] as String,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTargetBandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Band Score',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Set your IELTS target band score',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: AppColors.primary,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Target',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Band ${_profile?.targetBand.toStringAsFixed(1) ?? '7.0'}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _showTargetBandDialog,
                child: Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Study Preferences',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Customize your learning experience',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildPreferenceItem(
                icon: Icons.notifications_rounded,
                title: 'Practice Reminders',
                subtitle: 'Get daily practice notifications',
                value: true,
                onChanged: (value) {},
              ),
              SizedBox(height: 16.h),
              _buildPreferenceItem(
                icon: Icons.analytics_rounded,
                title: 'Progress Tracking',
                subtitle: 'Track your improvement over time',
                value: true,
                onChanged: (value) {},
              ),
              SizedBox(height: 16.h),
              _buildPreferenceItem(
                icon: Icons.auto_awesome_rounded,
                title: 'AI Feedback',
                subtitle: 'Receive detailed AI-powered feedback',
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
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
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Future<void> _updateProfile({required String name, String? avatarPath}) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Update profile in service
      await _profileService.updateProfileFields(
        name: name,
        avatarPath: avatarPath,
      );

      // Reload profile data
      await _loadProfileData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateTargetBand(double targetBand) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Update target band in service
      await _profileService.updateTargetBand(targetBand);

      // Reload profile data
      await _loadProfileData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Target band updated to ${targetBand.toStringAsFixed(1)}!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update target band: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper methods
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  Color _getBandColor(double band) {
    if (band >= 8.0) return AppColors.success;
    if (band >= 7.0) return AppColors.primary;
    if (band >= 6.0) return AppColors.warning;
    if (band >= 5.0) return AppColors.error;
    return AppColors.textTertiary;
  }

  // Helper methods for Premium Avatar
  LinearGradient _getAvatarGradient() {
    if (_profile?.avatarPath != null && _profile!.avatarPath!.isNotEmpty) {
      switch (_profile!.avatarPath) {
        case 'Student':
          return LinearGradient(
            colors: [DesignSystem.blue600, DesignSystem.blue500],
          );
        case 'Professional':
          return LinearGradient(
            colors: [DesignSystem.purple600, DesignSystem.purple500],
          );
        case 'Creative':
          return LinearGradient(
            colors: [DesignSystem.pink500, DesignSystem.accentRed],
          );
        case 'Tech':
          return LinearGradient(
            colors: [DesignSystem.blue500, DesignSystem.purple500],
          );
        case 'Nature':
          return LinearGradient(
            colors: [DesignSystem.green600, DesignSystem.green500],
          );
        default:
          return DesignSystem.premiumGradient;
      }
    }
    return DesignSystem.premiumGradient;
  }

  IconData _getAvatarIcon(String avatarPath) {
    switch (avatarPath) {
      case 'Default':
        return Icons.person_rounded;
      case 'Student':
        return Icons.school_rounded;
      case 'Professional':
        return Icons.work_rounded;
      case 'Creative':
        return Icons.palette_rounded;
      case 'Tech':
        return Icons.computer_rounded;
      case 'Nature':
        return Icons.eco_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _getInitials() {
    final name = _profile?.name ?? 'User';
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  IconData _parseIconData(String? iconName) {
    // Map string names to Material Icons; fallback to emoji usage handled by caller
    switch (iconName) {
      case 'fire':
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'trophy':
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'flag':
        return Icons.flag_rounded;
      case 'history':
        return Icons.history_rounded;
      case 'trend':
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'medal':
      case 'military_tech':
        return Icons.military_tech_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      case 'time':
      case 'timer':
        return Icons.timer_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }
}
