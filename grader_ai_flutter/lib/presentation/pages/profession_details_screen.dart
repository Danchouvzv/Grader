import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/profession.dart';

class ProfessionDetailsScreen extends StatefulWidget {
  final Profession profession;

  const ProfessionDetailsScreen({
    super.key,
    required this.profession,
  });

  @override
  State<ProfessionDetailsScreen> createState() => _ProfessionDetailsScreenState();
}

class _ProfessionDetailsScreenState extends State<ProfessionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController()
      ..addListener(() {
        final isScrolled = _scrollController.offset > 100;
        if (isScrolled != _isScrolled) {
          setState(() => _isScrolled = isScrolled);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            _buildSliverTabBar(),
          ];
        },
        body: _buildTabBarView(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: widget.profession.accentColor,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: _shareProfile,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero background
            widget.profession.heroImage.startsWith('http')
                ? Image.network(
                    widget.profession.heroImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallbackHero(),
                  )
                : widget.profession.heroImage.startsWith('assets')
                    ? Image.asset(
                        widget.profession.heroImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackHero(),
                      )
                    : _buildFallbackHero(),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    widget.profession.accentColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            
            // Content
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 60.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Match badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          widget.profession.matchLabel,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // Title
                  Text(
                    widget.profession.title,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Subtitle
                  Text(
                    widget.profession.subtitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.profession.accentColor.withOpacity(0.8),
            widget.profession.accentColor,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(),
          size: 80.sp,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.profession.category.toLowerCase()) {
      case 'business':
        return Icons.business_center_rounded;
      case 'creative':
        return Icons.palette_rounded;
      case 'technical':
        return Icons.code_rounded;
      case 'healthcare':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.work_rounded;
    }
  }

  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: widget.profession.accentColor,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: widget.profession.accentColor,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Skills'),
            Tab(text: 'Pros & Cons'),
            Tab(text: 'Next Steps'),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildSkillsTab(),
        _buildProsConsTab(),
        _buildNextStepsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats
          _buildQuickStats(),
          
          SizedBox(height: 24.h),
          
          // Description
          _buildSection(
            title: 'About this role',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profession.subtitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1.6,
                    color: const Color(0xFF374151),
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Key responsibilities (generated based on profession)
                Text(
                  'Key Responsibilities:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                ..._generateResponsibilities().map(
                  (responsibility) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 8.h, right: 12.w),
                          width: 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: widget.profession.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            responsibility,
                            style: TextStyle(
                              fontSize: 15.sp,
                              height: 1.5,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Career path
          _buildSection(
            title: 'Career Path',
            content: _buildCareerPath(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.school_rounded,
                  label: 'Education',
                  value: widget.profession.education,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: const Color(0xFFE5E7EB),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.attach_money_rounded,
                  label: 'Salary',
                  value: widget.profession.salaryRange,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Growth',
                  value: _getGrowthRate(),
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: const Color(0xFFE5E7EB),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.work_outline_rounded,
                  label: 'Experience',
                  value: _getExperienceLevel(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: widget.profession.accentColor,
          size: 24.sp,
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Required Skills',
            content: Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: widget.profession.skills.map((skill) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: widget.profession.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: widget.profession.accentColor.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: widget.profession.accentColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: 24.h),
          
          _buildSection(
            title: 'Skill Development Path',
            content: _buildSkillDevelopmentPath(),
          ),
        ],
      ),
    );
  }

  Widget _buildProsConsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildProsConsCard(
                  title: 'Pros',
                  items: widget.profession.pros,
                  color: const Color(0xFF10B981),
                  icon: Icons.thumb_up_rounded,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildProsConsCard(
                  title: 'Cons',
                  items: widget.profession.cons,
                  color: const Color(0xFFEF4444),
                  icon: Icons.thumb_down_rounded,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          _buildSection(
            title: 'Work-Life Balance',
            content: _buildWorkLifeBalance(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Actionable Steps',
            content: Column(
              children: widget.profession.actionableAdvice.map((advice) {
                final index = widget.profession.actionableAdvice.indexOf(advice);
                return _buildActionableStep(advice, index + 1);
              }).toList(),
            ),
          ),
          
          SizedBox(height: 24.h),
          
          _buildSection(
            title: 'Resources & Links',
            content: _buildResourcesSection(),
          ),
          
          SizedBox(height: 24.h),
          
          // CTA Buttons
          _buildCTAButtons(),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 16.h),
        content,
      ],
    );
  }

  Widget _buildProsConsCard({
    required String title,
    required List<String> items,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
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
                  color: color,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 6.h, right: 12.w),
                  width: 4.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: const Color(0xFF4B5563),
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

  Widget _buildActionableStep(String step, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: widget.profession.accentColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          
          SizedBox(width: 16.w),
          
          Expanded(
            child: Text(
              step,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.5,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButtons() {
    return Column(
      children: [
        // Primary CTA
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _launchURL(widget.profession.ctaLinks['jobs'] ?? ''),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.profession.accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 2,
            ),
            icon: Icon(Icons.work_outline_rounded, size: 20.sp),
            label: Text(
              'Find Jobs & Internships',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 12.h),
        
        // Secondary CTAs
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchURL(widget.profession.ctaLinks['courses'] ?? ''),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.profession.accentColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  side: BorderSide(
                    color: widget.profession.accentColor.withOpacity(0.3),
                  ),
                ),
                icon: Icon(Icons.school_rounded, size: 18.sp),
                label: Text(
                  'Courses',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 12.w),
            
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchURL(widget.profession.ctaLinks['mentorship'] ?? ''),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.profession.accentColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  side: BorderSide(
                    color: widget.profession.accentColor.withOpacity(0.3),
                  ),
                ),
                icon: Icon(Icons.person_outline_rounded, size: 18.sp),
                label: Text(
                  'Mentors',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods for generating dynamic content
  List<String> _generateResponsibilities() {
    // Generate responsibilities based on profession category
    switch (widget.profession.category.toLowerCase()) {
      case 'business':
        return [
          'Develop and execute strategic business plans',
          'Lead cross-functional teams and projects',
          'Analyze market trends and competitive landscape',
          'Build relationships with key stakeholders',
        ];
      case 'technical':
        return [
          'Design and develop software solutions',
          'Write clean, maintainable code',
          'Collaborate with product and design teams',
          'Debug and optimize application performance',
        ];
      case 'creative':
        return [
          'Create compelling visual designs and concepts',
          'Collaborate with clients to understand requirements',
          'Develop brand identity and marketing materials',
          'Stay updated with design trends and tools',
        ];
      default:
        return [
          'Execute core job responsibilities',
          'Collaborate with team members',
          'Maintain quality standards',
          'Contribute to organizational goals',
        ];
    }
  }

  Widget _buildCareerPath() {
    return Column(
      children: [
        _buildCareerPathItem('Entry Level', '0-2 years', true),
        _buildCareerPathItem('Mid Level', '3-5 years', false),
        _buildCareerPathItem('Senior Level', '5+ years', false),
      ],
    );
  }

  Widget _buildCareerPathItem(String level, String experience, bool isActive) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isActive 
            ? widget.profession.accentColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActive 
              ? widget.profession.accentColor.withOpacity(0.3)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: isActive ? widget.profession.accentColor : const Color(0xFF9CA3AF),
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isActive ? widget.profession.accentColor : const Color(0xFF374151),
                  ),
                ),
                Text(
                  experience,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillDevelopmentPath() {
    return Column(
      children: [
        _buildSkillLevel('Beginner', 'Learn the basics', 0.3),
        _buildSkillLevel('Intermediate', 'Build projects', 0.7),
        _buildSkillLevel('Advanced', 'Master the craft', 1.0),
      ],
    );
  }

  Widget _buildSkillLevel(String level, String description, double progress) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: widget.profession.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(widget.profession.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkLifeBalance() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBalanceItem('Work Hours', '40-45 hrs/week', 0.7),
          _buildBalanceItem('Flexibility', 'Remote friendly', 0.8),
          _buildBalanceItem('Stress Level', 'Moderate', 0.6),
          _buildBalanceItem('Travel', 'Occasional', 0.3),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value, double score) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 4.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.r),
                  child: LinearProgressIndicator(
                    value: score,
                    minHeight: 4.h,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(score),
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

  Color _getScoreColor(double score) {
    if (score >= 0.7) return const Color(0xFF10B981);
    if (score >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Widget _buildResourcesSection() {
    return Column(
      children: [
        _buildResourceItem(
          'Industry Reports',
          'Latest trends and insights',
          Icons.analytics_rounded,
          () => _launchURL('https://example.com'),
        ),
        _buildResourceItem(
          'Professional Communities',
          'Connect with peers',
          Icons.group_rounded,
          () => _launchURL('https://linkedin.com'),
        ),
        _buildResourceItem(
          'Certification Programs',
          'Boost your credentials',
          Icons.verified_rounded,
          () => _launchURL('https://coursera.org'),
        ),
      ],
    );
  }

  Widget _buildResourceItem(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: widget.profession.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: widget.profession.accentColor,
                size: 20.sp,
              ),
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
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF9CA3AF),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  String _getGrowthRate() {
    // Generate growth rate based on profession
    final rates = ['High', 'Medium', 'Steady'];
    return rates[widget.profession.id.hashCode % rates.length];
  }

  String _getExperienceLevel() {
    // Generate experience level based on profession
    final levels = ['Entry-Mid', 'All Levels', 'Mid-Senior'];
    return levels[widget.profession.id.hashCode % levels.length];
  }

  void _shareProfile() {
    HapticFeedback.lightImpact();
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${widget.profession.title}...'),
        backgroundColor: widget.profession.accentColor,
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link not available yet'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening link: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
