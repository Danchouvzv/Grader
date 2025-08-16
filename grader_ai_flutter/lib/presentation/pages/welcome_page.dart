import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/animated_background.dart';
import '../widgets/gradient_button.dart';
import 'sign_up_page.dart';
import 'sign_in_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
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
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _pulseController.repeat(reverse: true);
      _rotateController.repeat();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
                    child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 60.h),
                  _buildHeader(),
                  SizedBox(height: 80.h),
                  _buildFeatures(),
                  SizedBox(height: 60.h),
                  _buildCallToAction(),
                  SizedBox(height: 40.h),
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
      child: Column(
        children: [
          // Floating decorative elements
          Stack(
            alignment: Alignment.center,
            children: [
              // Rotating outer ring
              AnimatedBuilder(
                animation: _rotateAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value * 2 * 3.14159,
                    child: Container(
                      width: 160.w,
                      height: 160.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1976D2).withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Floating dots
                          Positioned(
                            top: 10.h,
                            left: 75.w,
                            child: Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10.h,
                            right: 75.w,
                            child: Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10.w,
                            top: 75.h,
                            child: Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Pulsing logo
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF667eea),
                            Color(0xFF764ba2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            size: 40.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 32.h),
          // App Name with gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFE53935), // Красный
                Color(0xFFFF5722), // Оранжево-красный 
                Color(0xFF1976D2), // Синий
              ],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: Text(
              'grader.ai',
              style: TextStyle(
                fontSize: 42.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 12.h),
          // Animated tagline
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(
                    color: const Color(0xFF667eea).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      size: 16.sp,
                      color: const Color(0xFF667eea),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Master Your Speaking Skills with AI',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF667eea),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          // Statistics row
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Center(child: _buildStatItem('10K+', 'Students')),
                  ),
                  Expanded(
                    child: Center(child: _buildStatItem('95%', 'Success Rate')),
                  ),
                  Expanded(
                    child: Center(child: _buildStatItem('4.9★', 'Rating')),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Section title with decorative elements
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 2.h,
                        margin: EdgeInsets.only(right: 16.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.transparent, Color(0xFF667eea)],
                          ),
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                    ),
                    Text(
                      'Why Choose Us',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3748),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: Container(
                        height: 2.h,
                        margin: EdgeInsets.only(left: 16.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Colors.transparent],
                          ),
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 8.h),
            Text(
              'Powered by cutting-edge AI technology',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            
            // Enhanced feature cards
            _buildEnhancedFeatureCard(
              icon: Icons.record_voice_over,
              title: 'AI Speaking Coach',
              description: 'Real-time IELTS assessment with personalized feedback',
              benefits: ['Band score prediction', 'Pronunciation analysis', 'Fluency tracking'],
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            SizedBox(height: 24.h),
            _buildEnhancedFeatureCard(
              icon: Icons.trending_up,
              title: 'Smart Progress Tracking',
              description: 'Detailed analytics to monitor your improvement',
              benefits: ['Performance metrics', 'Progress visualization', 'Achievement system'],
              gradient: const LinearGradient(
                colors: [Color(0xFF48BB78), Color(0xFF38A169)],
              ),
            ),
            SizedBox(height: 24.h),
            _buildEnhancedFeatureCard(
              icon: Icons.psychology,
              title: 'Personalized Learning',
              description: 'Adaptive study plans tailored to your needs',
              benefits: ['Custom study plans', 'Weakness identification', 'Targeted practice'],
              gradient: const LinearGradient(
                colors: [Color(0xFFED8936), Color(0xFFDD6B20)],
              ),
            ),
          ],
        ),
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30.sp,
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
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Get Started Button
            GradientButton(
              text: 'Get Started Free',
              icon: Icons.rocket_launch,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            // Sign In Button
            GradientButton(
              text: 'Sign In',
              icon: Icons.login,
              isOutlined: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInPage(),
                  ),
                );
              },
            ),
            SizedBox(height: 32.h),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('10K+', 'Students'),
                Container(
                  width: 1,
                  height: 40.h,
                  color: Colors.grey[300],
                ),
                _buildStatItem('95%', 'Success Rate'),
                Container(
                  width: 1,
                  height: 40.h,
                  color: Colors.grey[300],
                ),
                _buildStatItem('24/7', 'Support'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> benefits,
    required LinearGradient gradient,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28.sp,
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
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Benefits list
          ...benefits.map((benefit) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  benefit,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF4A5568),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
