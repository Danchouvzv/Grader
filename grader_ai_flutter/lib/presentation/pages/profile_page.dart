import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/models/user_profile.dart';
import '../../core/models/session_record.dart';
import '../../core/models/achievement.dart';
import '../../core/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  
  UserProfile? _profile;
  List<SessionRecord> _recentSessions = [];
  List<Achievement> _achievements = [];
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _insights = {};
  List<Map<String, dynamic>> _weeklyProgress = [];
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfileData();
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
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    ));
    
    _animationController.forward();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    
    try {
      // Initialize profile if doesn't exist
      _profile = await _profileService.getCurrentProfile();
      _profile ??= await _profileService.initializeProfile('User');
      
      if (_profile != null) {
        // Load all profile data
        final futures = await Future.wait([
          _profileService.getRecentSessions(_profile!.id!),
          _profileService.getAchievements(_profile!.id!),
          _profileService.getUserStats(_profile!.id!),
          _profileService.getPerformanceInsights(_profile!.id!),
          _profileService.getWeeklyProgress(_profile!.id!),
        ]);
        
        _recentSessions = futures[0] as List<SessionRecord>;
        _achievements = futures[1] as List<Achievement>;
        _stats = futures[2] as Map<String, dynamic>;
        _insights = futures[3] as Map<String, dynamic>;
        _weeklyProgress = futures[4] as List<Map<String, dynamic>>;
      }
    } catch (e) {
      print('Error loading profile data: $e');
    } finally {
      setState(() => _isLoading = false);
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF8FAFC),
                Colors.white,
                const Color(0xFFF8FAFC),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8FAFC),
              Colors.white,
              const Color(0xFFF8FAFC),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header
                    Container(
                      margin: EdgeInsets.all(20.w),
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFE53935),
                            const Color(0xFF1976D2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _buildHeaderContent(),
                    ),
                    
                    // Main content
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          _buildStatsGrid(),
                          SizedBox(height: 24.h),
                          _buildProgressChart(),
                          SizedBox(height: 24.h),
                          _buildInsightsCard(),
                          SizedBox(height: 24.h),
                          _buildRecentSessions(),
                          SizedBox(height: 24.h),
                          _buildAchievements(),
                          SizedBox(height: 80.h), // Увеличили bottom padding
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Column(
      children: [
        // Profile Avatar and Name
        Row(
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 40.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profile?.name ?? 'User',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.military_tech_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Level ${_profile?.level ?? 1} • ${_profile?.levelTitle ?? 'Beginner'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (_profile?.sessionsToNextLevel != null && _profile!.sessionsToNextLevel > 0) ...[
                    SizedBox(height: 4.h),
                    Text(
                      '${_profile!.sessionsToNextLevel} sessions to next level',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: _showSettingsMenu,
              icon: Icon(
                Icons.settings_rounded,
                color: Colors.white,
                size: 24.w,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20.h),
        
        // Current Streak and Target
        Row(
          children: [
            Expanded(
              child: _buildHeaderStat(
                '🔥',
                _profile?.streakText ?? 'No streak',
                'Current Streak',
              ),
            ),
            Container(
              width: 1,
              height: 40.h,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildHeaderStat(
                '🎯',
                'Band ${_profile?.targetBand.toStringAsFixed(1) ?? '7.0'}',
                'Target Score',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE53935),
              const Color(0xFF1976D2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Avatar and Name
            Row(
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 40.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile?.name ?? 'User',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.military_tech_rounded,
                            color: Colors.white.withOpacity(0.9),
                            size: 16.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Level ${_profile?.level ?? 1} • ${_profile?.levelTitle ?? 'Beginner'}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (_profile?.sessionsToNextLevel != null && _profile!.sessionsToNextLevel > 0) ...[
                        SizedBox(height: 4.h),
                        Text(
                          '${_profile!.sessionsToNextLevel} sessions to next level',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _showSettingsMenu,
                  icon: Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 24.w,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            // Current Streak and Target
            Row(
              children: [
                Expanded(
                  child: _buildHeaderStat(
                    '🔥',
                    _profile?.streakText ?? 'No streak',
                    'Current Streak',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40.h,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildHeaderStat(
                    '🎯',
                    'Band ${_profile?.targetBand.toStringAsFixed(1) ?? '7.0'}',
                    'Target Score',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String icon, String value, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: 20.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20.h, // Увеличили отступы
      crossAxisSpacing: 20.w,
      childAspectRatio: 1.5, // Увеличили aspect ratio для лучшего размещения
      children: [
        _buildStatCard(
          '📊',
          '${_stats['totalSessions'] ?? 0}',
          'Total Sessions',
          const Color(0xFFE53935),
        ),
        _buildStatCard(
          '⏱️',
          _formatDuration(_stats['totalPracticeTime'] ?? 0),
          'Practice Time',
          const Color(0xFF1976D2),
        ),
        _buildStatCard(
          '📈',
          (_stats['averageBand'] ?? 0.0).toStringAsFixed(1),
          'Average Band',
          const Color(0xFF10B981),
        ),
        _buildStatCard(
          '🏆',
          (_stats['bestBand'] ?? 0.0).toStringAsFixed(1),
          'Best Score',
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildStatCard(String icon, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 22.sp), // Уменьшили размер иконки
          ),
          SizedBox(height: 6.h), // Уменьшили отступ
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp, // Уменьшили размер значения
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp, // Уменьшили размер лейбла
              color: const Color(0xFF64748b),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1a1a2e).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1a1a2e),
            ),
          ),
          SizedBox(height: 16.h),
          if (_weeklyProgress.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Text(
                  'Start practicing to see your progress!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748b),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final date = DateTime.now().subtract(Duration(days: 6 - index));
                  final dayData = _weeklyProgress.firstWhere(
                    (data) => data['date'] == date.toIso8601String().split('T')[0],
                    orElse: () => {'sessions_count': 0, 'average_band': 0.0},
                  );
                  
                  return _buildProgressBar(
                    _getDayName(date.weekday),
                    dayData['sessions_count'] ?? 0,
                    (dayData['average_band'] ?? 0.0).toDouble(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String day, int sessions, double averageBand) {
    final height = sessions > 0 ? (sessions * 20.0).clamp(10.0, 80.0) : 10.0;
    final color = averageBand >= 7.0 
        ? const Color(0xFF10B981)
        : averageBand >= 6.0 
            ? const Color(0xFFF59E0B)
            : const Color(0xFFE53935);
    
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
              color: sessions > 0 ? color : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            day,
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF64748b),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    if (_insights.isEmpty) return const SizedBox();
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1a1a2e).withOpacity(0.05),
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
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE53935).withOpacity(0.1),
                      const Color(0xFF1976D2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: const Color(0xFFE53935),
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Performance Insights',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Text(
            _insights['recommendation'] ?? 'Keep practicing!',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF374151),
              height: 1.5,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  'Strongest Skill',
                  _insights['strongestSkill'] ?? 'N/A',
                  const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildInsightItem(
                  'Focus Area',
                  _insights['weakestSkill'] ?? 'N/A',
                  const Color(0xFFE53935),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF64748b),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSessions() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1a1a2e).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Sessions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1a1a2e),
            ),
          ),
          SizedBox(height: 16.h),
          if (_recentSessions.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Text(
                  'No sessions yet. Start practicing!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748b),
                  ),
                ),
              ),
            )
          else
            ...(_recentSessions.take(5).map((session) => _buildSessionItem(session))),
        ],
      ),
    );
  }

  Widget _buildSessionItem(SessionRecord session) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: _getBandColor(session.overallBand),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                session.overallBand.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.partTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1a1a2e),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${session.formattedDuration} • ${session.formattedDate}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748b),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF64748b),
            size: 20.w,
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
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1a1a2e).withOpacity(0.05),
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
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1a1a2e),
                ),
              ),
              const Spacer(),
              Text(
                '${_achievements.length}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE53935),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (_achievements.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Text(
                  'Complete sessions to unlock achievements!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748b),
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: _achievements.take(6).map((achievement) => _buildAchievementBadge(achievement)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(Achievement achievement) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE53935).withOpacity(0.1),
            const Color(0xFF1976D2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE53935).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(width: 6.w),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1a1a2e),
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
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
            SizedBox(height: 20.h),
            _buildSettingsItem('Edit Profile', Icons.edit_rounded, () {}),
            _buildSettingsItem('Set Target Band', Icons.flag_rounded, () {}),
            _buildSettingsItem('Export Data', Icons.download_rounded, () {}),
            _buildSettingsItem('Reset Progress', Icons.refresh_rounded, () {}),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748b)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1a1a2e),
        ),
      ),
      onTap: onTap,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: const Color(0xFF64748b),
        size: 20.w,
      ),
    );
  }

  // Helper methods
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
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
    if (band >= 8.0) return const Color(0xFF10B981);
    if (band >= 7.0) return const Color(0xFF3B82F6);
    if (band >= 6.0) return const Color(0xFFF59E0B);
    if (band >= 5.0) return const Color(0xFFEF4444);
    return const Color(0xFF6B7280);
  }
}