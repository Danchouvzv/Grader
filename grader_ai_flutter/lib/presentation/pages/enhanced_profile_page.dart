import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import '../../core/models/user_profile.dart';
import '../../core/models/session_record.dart';
import '../../core/models/achievement.dart';
import '../../core/services/profile_service.dart';
import '../../shared/themes/app_theme.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/themes/design_system.dart';
import 'subscription_page.dart';
import 'splash_screen.dart';

/// Profile page constants to avoid magic numbers
class ProfileConstants {
  // Dimensions
  static const double headerHeight = 260;
  static const double avatarSize = 90;
  static const double buttonHeight = 56;
  static const double cardPadding = 24;
  static const double sectionSpacing = 16;
  static const double bottomPadding = 100;
  
  // Typography
  static const double titleFontSize = 28;
  static const double subtitleFontSize = 16;
  static const double bodyFontSize = 14;
  static const double captionFontSize = 12;
  
  // Animation durations
  static const Duration fadeDuration = Duration(milliseconds: 800);
  static const Duration slideDuration = Duration(milliseconds: 600);
  static const Duration counterDuration = Duration(milliseconds: 1500);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration tweenDuration = Duration(milliseconds: 1000);
  static const Duration counterTweenDuration = Duration(milliseconds: 1200);
  static const Duration progressTweenDuration = Duration(milliseconds: 1500);
  static const Duration staggeredDelay = Duration(milliseconds: 100);
  static const Duration achievementDelay = Duration(milliseconds: 100);
  static const Duration offlineBannerDuration = Duration(milliseconds: 300);
  
  // Grid
  static const int statsGridCrossAxisCount = 2;
  static const double statsGridChildAspectRatio = 1.2;
  
  // Chart
  static const double chartHeight = 180;
  static const double miniChartHeight = 120;
  static const int weeklyDaysCount = 7;
}

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
  final Connectivity _connectivity = Connectivity();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Connectivity
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOffline = false;
  
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
  bool _isRetrying = false;
  String? _error;
  
  // Animation listeners to prevent memory leaks
  VoidCallback? _fadeListener;
  VoidCallback? _slideListener;
  VoidCallback? _counterListener;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkConnectivity();
    _loadProfileData();
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    setState(() {
      _isOffline = result == ConnectivityResult.none;
    });
    
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = _isOffline;
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
      
      // Auto-reload when coming back online
      if (wasOffline && !_isOffline) {
        _loadProfileData();
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: ProfileConstants.fadeDuration,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: ProfileConstants.slideDuration,
      vsync: this,
    );
    
    _counterController = AnimationController(
      duration: ProfileConstants.counterDuration,
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
    
    // Add safety listeners to prevent memory leaks
    _fadeListener = () {
      if (mounted) setState(() {});
    };
    _slideListener = () {
      if (mounted) setState(() {});
    };
    _counterListener = () {
      if (mounted) setState(() {});
    };
    
    _fadeAnimation.addListener(_fadeListener!);
    _slideAnimation.addListener(_slideListener!);
    _counterAnimation.addListener(_counterListener!);
    
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
        
        print('🏆 Profile loaded:');
        print('   Achievements: ${_achievements.length}');
        print('   Types: ${_achievements.map((a) => a.achievementType).toList()}');
        
        // Track analytics
        await _analytics.logEvent(
          name: 'profile_viewed',
          parameters: {
            'user_id': _profile?.id ?? 0,
            'level': _profile?.level ?? 0,
            'streak': _profile?.currentStreak ?? 0,
            'achievements_count': _achievements.length,
            'sessions_count': _recentSessions.length,
          },
        );
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


  @override
  void dispose() {
    // Cancel connectivity subscription
    _connectivitySubscription?.cancel();
    
    // Remove listeners to prevent memory leaks
    if (_fadeListener != null) {
      _fadeAnimation.removeListener(_fadeListener!);
    }
    if (_slideListener != null) {
      _slideAnimation.removeListener(_slideListener!);
    }
    if (_counterListener != null) {
      _counterAnimation.removeListener(_counterListener!);
    }
    
    // Dispose controllers
    _fadeController.dispose();
    _slideController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildOfflineBanner(),
          Expanded(
            child: SafeArea(
              child: Semantics(
                label: 'User Profile Page',
                child: RefreshIndicator(
                  onRefresh: _loadProfileData,
                  color: DesignSystem.blue500,
                  backgroundColor: Colors.white,
                  child: _isLoading 
                      ? _buildLoadingState()
                      : _error != null 
                          ? _buildErrorState()
                          : _buildProfileContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return AnimatedContainer(
      duration: ProfileConstants.offlineBannerDuration,
      height: _isOffline ? 40.h : 0,
      color: Colors.orange.shade600,
      child: _isOffline
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16.w),
                SizedBox(width: 8.w),
                Text(
                  'No internet connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: DesignSystem.backgroundGradient,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 100.h), // Add bottom padding to prevent overflow
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
              duration: ProfileConstants.shimmerDuration,
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _isRetrying ? null : () async {
                    setState(() => _isRetrying = true);
                    await _loadProfileData();
                    if (mounted) setState(() => _isRetrying = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isRetrying 
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Try Again',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                ),
                SizedBox(width: 12.w),
                OutlinedButton(
                  onPressed: _showErrorDetails,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Details',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
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

  void _showErrorDetails() {
    showDialog(
      context: context,
      builder: (context) => Semantics(
        label: 'Error details dialog',
        child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Error Details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error Message:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: DesignSystem.surfaceGray,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _error ?? 'No error message available',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Troubleshooting:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '• Check your internet connection\n• Try refreshing the page\n• Restart the app if the problem persists',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadProfileData();
            },
            child: Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
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
              
              // Logout Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    DesignSystem.space20.w,
                    DesignSystem.space24.h,
                    DesignSystem.space20.w,
                    0,
                  ),
                  child: _buildLogoutButton(),
                ),
              ),
              
              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: ProfileConstants.bottomPadding.h),
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
      duration: ProfileConstants.tweenDuration,
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
            duration: ProfileConstants.counterTweenDuration,
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
            duration: ProfileConstants.counterTweenDuration,
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
        _showPremiumActivationDialog();
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
                duration: ProfileConstants.counterTweenDuration,
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
                  duration: ProfileConstants.counterTweenDuration,
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
          label: 'Total Sessions',
          color: DesignSystem.blue600,
        ),
        StatCard(
          icon: Icons.timer_rounded,
          value: _formatDuration(_stats['totalPracticeTime'] ?? 0),
          label: 'Practice Time',
          color: DesignSystem.purple600,
        ),
        StatCard(
          icon: Icons.trending_up_rounded,
          value: (_stats['averageBand'] ?? 0.0).toStringAsFixed(1),
          label: 'Average Band',
          color: DesignSystem.green600,
        ),
        StatCard(
          icon: Icons.emoji_events_rounded,
          value: (_stats['bestBand'] ?? 0.0).toStringAsFixed(1),
          label: 'Best Score',
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
                        Expanded(
                          child: _buildMiniStat(
                            icon: Icons.timeline_rounded,
                            value: '$totalWeeklySessions',
                            label: 'sessions',
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildMiniStat(
                            icon: Icons.star_rounded,
                            value: avgBand.toStringAsFixed(1),
                            label: 'avg band',
                          ),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: DesignSystem.green50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: DesignSystem.green500.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.w,
            color: DesignSystem.green600,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: DesignSystem.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: DesignSystem.green600,
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  label,
                  style: DesignSystem.caption.copyWith(
                    color: DesignSystem.textSecondary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
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

  Widget _buildEnhancedProgressChart(int maxSessions) {
    // Generate 7 days of data (Mon-Sun)
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(
      height: 200.h,
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
        border: Border.all(
          color: DesignSystem.green500.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.green500.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Chart bars
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final dayName = weekDays[index];
                final dayData = _weeklyProgress.firstWhere(
                  (data) => data['day'] == dayName,
                  orElse: () => {'sessions': 0, 'sessions_count': 0},
                );
                final sessions = (dayData['sessions'] ?? dayData['sessions_count']) as int? ?? 0;
                final isToday = dayName == DateFormat('EEE').format(now);
                
                return Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(
                      milliseconds: 800 + (index * 100),
                    ),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      final height = maxSessions == 0 
                          ? 0.0 
                          : (sessions / maxSessions * 120 * value);
                      
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Sessions count above bar
                            if (sessions > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isToday 
                                      ? DesignSystem.green600 
                                      : DesignSystem.textSecondary,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  '$sessions',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            
                            SizedBox(height: 4.h),
                            
                            // Bar
                            Container(
                              width: double.infinity,
                              height: height.h,
                              decoration: BoxDecoration(
                                gradient: isToday
                                    ? DesignSystem.successGradient
                                    : LinearGradient(
                                        colors: [
                                          DesignSystem.green500.withOpacity(0.8),
                                          DesignSystem.green400.withOpacity(0.6),
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(6.r),
                                ),
                                boxShadow: isToday && sessions > 0
                                    ? [
                                        BoxShadow(
                                          color: DesignSystem.green500.withOpacity(0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weekDays.map((dayName) {
              final isToday = dayName == DateFormat('EEE').format(now);
              
              return Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 6.h,
                  ),
                  decoration: isToday
                      ? BoxDecoration(
                          gradient: DesignSystem.successGradient,
                          borderRadius: BorderRadius.circular(6.r),
                          boxShadow: [
                            BoxShadow(
                              color: DesignSystem.green500.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        )
                      : BoxDecoration(
                          color: DesignSystem.surfaceGray.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: DesignSystem.border.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                  child: Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      color: isToday 
                          ? Colors.white 
                          : DesignSystem.textPrimary,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProgressState() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge.r),
        border: Border.all(
          color: DesignSystem.green500.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.green500.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: DesignSystem.successGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DesignSystem.green500.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.trending_up_rounded,
                color: Colors.white,
                size: 32.w,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Progress Yet',
              style: DesignSystem.headlineSmall.copyWith(
                color: DesignSystem.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start practicing to see your weekly\nprogress chart here',
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.textSecondary,
                fontSize: 13.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to practice
              },
              icon: Icon(Icons.play_arrow_rounded, size: 18.w),
              label: Text(
                'Start Practice',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.green500,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 10.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 2,
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
                duration: ProfileConstants.shimmerDuration,
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
                  'Premium Feature',
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
      duration: Duration(
        milliseconds: ProfileConstants.offlineBannerDuration.inMilliseconds + (_achievements.indexOf(achievement) * ProfileConstants.achievementDelay.inMilliseconds),
      ),
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
            width: MediaQuery.of(context).size.width * 0.95,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  const Color(0xFFFAFBFC),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Header
                Container(
                  padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 20.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DesignSystem.blue600,
                        DesignSystem.blue500,
                        DesignSystem.purple500,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28.r),
                      topRight: Radius.circular(28.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
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
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Customize your personal information',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(28.w),
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
                              child: Container(
                                height: 56.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: DesignSystem.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: DesignSystem.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 56.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      DesignSystem.blue500,
                                      DesignSystem.purple500,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DesignSystem.blue500.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _updateProfile(
                                      name: nameController.text.trim(),
                                      avatarPath: selectedAvatar,
                                    );
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save_rounded,
                                        color: Colors.white,
                                        size: 20.w,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: DesignSystem.blue500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: DesignSystem.blue500,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Set Target Band',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: DesignSystem.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Target Display
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignSystem.blue500.withOpacity(0.1),
                      DesignSystem.purple500.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: DesignSystem.blue500.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Target',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: DesignSystem.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Band ${currentTarget.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: DesignSystem.blue500,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Band Selection
              Text(
                'Select Target Band:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: DesignSystem.textPrimary,
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Quick Selection Buttons (0.5 steps)
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (double band = 4.0; band <= 9.0; band += 0.5)
                    _buildBandButton(
                      band: band,
                      isSelected: selectedTarget == band,
                      onTap: () {
                        setState(() {
                          selectedTarget = band;
                        });
                      },
                    ),
                ],
              ),
              
              SizedBox(height: 20.h),
              
              // Slider for fine adjustment
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: DesignSystem.surfaceGray,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: DesignSystem.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Fine Adjustment',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Band ${selectedTarget.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        color: DesignSystem.blue500,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Slider(
                      value: selectedTarget,
                      min: 4.0,
                      max: 9.0,
                      divisions: 10, // 0.5 steps: 4.0, 4.5, 5.0, ..., 9.0
                      activeColor: DesignSystem.blue500,
                      inactiveColor: DesignSystem.border,
                      onChanged: (value) {
                        setState(() {
                          selectedTarget = value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '4.0',
                          style: TextStyle(
                            color: DesignSystem.textSecondary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '9.0',
                          style: TextStyle(
                            color: DesignSystem.textSecondary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: DesignSystem.textSecondary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateTargetBand(selectedTarget);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.blue500,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save Target',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBandButton({
    required double band,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? DesignSystem.blue500 : DesignSystem.surfaceGray,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? DesignSystem.blue500 : DesignSystem.border,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: DesignSystem.blue500.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          band.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : DesignSystem.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(String selectedAvatar, Function(String) onAvatarSelected) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: DesignSystem.purple500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                color: DesignSystem.purple500,
                size: 18.w,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: DesignSystem.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: DesignSystem.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Current Avatar Display
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      DesignSystem.blue500.withOpacity(0.1),
                      DesignSystem.purple500.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: DesignSystem.blue500.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: DesignSystem.blue500,
                    size: 50.w,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Upload Your Photo',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: DesignSystem.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Choose a photo from your gallery or take a new one',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: DesignSystem.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              // Upload Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: DesignSystem.border,
                          width: 1.5,
                        ),
                      ),
                      child: TextButton.icon(
                        onPressed: () => _pickImageFromGallery(),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: Icon(
                          Icons.photo_library_rounded,
                          color: DesignSystem.blue500,
                          size: 20.w,
                        ),
                        label: Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: DesignSystem.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            DesignSystem.blue500,
                            DesignSystem.purple500,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: DesignSystem.blue500.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextButton.icon(
                        onPressed: () => _pickImageFromCamera(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 20.w,
                        ),
                        label: Text(
                          'Camera',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        // Handle the selected image
        print('📸 Image selected from gallery: ${image.path}');
        // You can add logic here to update the avatar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo selected from gallery'),
            backgroundColor: DesignSystem.green500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error picking image from gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting photo: $e'),
          backgroundColor: DesignSystem.red500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        // Handle the selected image
        print('📸 Image captured from camera: ${image.path}');
        // You can add logic here to update the avatar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo captured from camera'),
            backgroundColor: DesignSystem.green500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error capturing image from camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing photo: $e'),
          backgroundColor: DesignSystem.red500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
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
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: DesignSystem.blue500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                icon,
                color: DesignSystem.blue500,
                size: 16.w,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: DesignSystem.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            style: TextStyle(
              fontSize: 16.sp,
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: DesignSystem.textTertiary,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: enabled 
                      ? DesignSystem.blue500.withOpacity(0.1)
                      : DesignSystem.surfaceGray,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: enabled ? DesignSystem.blue500 : DesignSystem.textTertiary,
                  size: 20.w,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: DesignSystem.blue500,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: enabled ? Colors.white : DesignSystem.surfaceGray,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
            ),
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

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade500,
            Colors.red.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _performHapticFeedback();
            _logout();
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: DesignSystem.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 16.sp,
            color: DesignSystem.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: DesignSystem.textSecondary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Store the current context before any async operations
      final currentContext = context;
      
      try {
        // Show loading indicator
        showDialog(
          context: currentContext,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: DesignSystem.blue500,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Logging out...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: DesignSystem.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();
        
        // Track logout analytics
        await _analytics.logEvent(name: 'user_logout');
        
        // Close loading dialog using the stored context
        if (mounted && currentContext.mounted) {
          Navigator.of(currentContext).pop();
        }

        // Navigate to splash screen
        if (mounted && currentContext.mounted) {
          Navigator.pushAndRemoveUntil(
            currentContext,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
          );
        }

        print('✅ User logged out successfully');
      } catch (e) {
        // Close loading dialog using the stored context
        if (mounted && currentContext.mounted) {
          Navigator.of(currentContext).pop();
        }
        
        // Show error message
        if (mounted && currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        }

        print('❌ Logout error: $e');
      }
    }
  }

  /// Safe haptic feedback that doesn't crash on unsupported devices
  void _performHapticFeedback() {
    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      // Ignore haptic feedback errors on unsupported devices
      print('⚠️ Haptic feedback not supported on this device');
    }
  }

  /// Show premium activation dialog
  void _showPremiumActivationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚀 Upgrade to Premium'),
        content: const Text(
          'Unlock unlimited IELTS speaking practice with Premium!\n\n'
          '📱 Contact us via Telegram to activate Premium:\n@your_telegram_username\n\n'
          'After payment, your premium will be activated within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open Telegram
              // You can add url_launcher here if needed
            },
            child: const Text('Open Telegram'),
          ),
        ],
      ),
    );
  }
}
