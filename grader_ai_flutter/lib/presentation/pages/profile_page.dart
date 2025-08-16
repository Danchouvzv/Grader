import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/profile/models/user_profile.dart';
import '../../features/profile/services/profile_service.dart';
import '../../features/profile/widgets/profile_header.dart';
import '../../features/profile/widgets/progress_chart.dart';
import '../../features/profile/widgets/achievements_section.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/profile/pages/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  late UserProfile _profile;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfile();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
  }

  Future<void> _loadProfile() async {
    try {
      _profile = await _profileService.getUserProfile('user_001');
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF667eea),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Loading your profile...',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Profile Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: ProfileHeader(
                  profile: _profile,
                  onEditPressed: _showEditProfileBottomSheet,
                  onAvatarTap: _showAvatarOptions,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Progress motivational message
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildMotivationalCard(),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Progress Chart
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ProgressChart(profile: _profile),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Achievements Section
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: AchievementsSection(
                    achievements: _profile.achievements,
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Quick Actions
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildQuickActions(),
                ),
              ),
              
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationalCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF48BB78), Color(0xFF38A169)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF48BB78).withOpacity(0.3),
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
              Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Your Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Text(
                            _getProgressMessage(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Progress bar to target
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                                            'Progress to Score ${_profile.stats.averageScore.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                                            '${(_getOverallProgress() * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                                        widthFactor: _getOverallProgress(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Text(
                            _getNextMilestone(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Settings',
                  'Customize your experience',
                  Icons.settings,
                  const Color(0xFF667eea),
                  () => _navigateToSettings(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionCard(
                  'Statistics',
                  'View detailed analytics',
                  Icons.analytics,
                  const Color(0xFF48BB78),
                  () => _showDetailedStats(),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Share',
                  'Share your progress',
                  Icons.share,
                  const Color(0xFFED8936),
                  () => _shareProgress(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionCard(
                  'Support',
                  'Get help & feedback',
                  Icons.help_outline,
                  const Color(0xFF9F7AEA),
                  () => _showSupport(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileBottomSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          profile: _profile,
          onProfileUpdated: (updatedProfile) {
            setState(() {
              _profile = updatedProfile;
            });
          },
        ),
      ),
    );
  }

  void _showAvatarOptions() {
    _showEditProfileBottomSheet();
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          userSettings: _profile.settings,
          onSettingsChanged: (newSettings) {
            setState(() {
              _profile = _profile.copyWith(settings: newSettings);
            });
          },
        ),
      ),
    );
  }

  void _showDetailedStats() {
    // Implement detailed statistics modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detailed Statistics'),
        content: const Text('Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareProgress() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _showSupport() {
    // Implement support modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support & Help'),
        content: const Text('Need help? Contact our support team!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper methods for UI
  String _getProgressMessage() {
    final stats = _profile.stats;
    final target = 8.0; // Target score
    final current = stats.averageScore;
    
    if (current >= target) {
      return "🎉 Congratulations! You've reached your target score!";
    } else if (current >= target - 0.5) {
      return "🔥 You're so close to your target! Keep pushing!";
    } else if (stats.currentStreak >= 7) {
      return "💪 Amazing streak! Your consistency is paying off!";
    } else {
      return "📈 Keep practicing to reach your Score ${target.toString()} goal!";
    }
  }

  String _getNextMilestone() {
    final stats = _profile.stats;
    
    if (stats.totalSessions < 10) {
      return "Complete ${10 - stats.totalSessions} more sessions to unlock 'Dedicated Learner'";
    } else if (stats.currentStreak < 14) {
      return "Practice for ${14 - stats.currentStreak} more days to unlock 'Two Week Warrior'";
    } else if (stats.averageScore < 8.0) {
      return "Achieve Score 8.0 to unlock 'Excellence Award'";
    } else {
      return "You're doing amazing! Keep up the great work!";
    }
  }

  double _getOverallProgress() {
    final stats = _profile.stats;
    final target = 8.0;
    return (stats.averageScore / target).clamp(0.0, 1.0);
  }
}
