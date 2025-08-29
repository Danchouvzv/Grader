import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/animated_background.dart';
import '../widgets/gradient_button.dart';
import 'sign_up_page.dart';
import 'sign_in_page.dart';
import 'main_page.dart';

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
                SizedBox(height: 20.h), // Bottom padding for safe area
              ],
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
          SizedBox(height: 40.h),
          
          // Creative AI-powered logo
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing ring
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.1),
                    child: Container(
                      width: 140.w,
                      height: 140.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE53935).withOpacity(0.3 * (1.0 - value)),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Main logo container
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE53935),
                      const Color(0xFFD32F2F),
                      const Color(0xFF1976D2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.9),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // AI brain pattern background
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: CustomPaint(
                          painter: AIBrainPainter(),
                        ),
                      ),
                    ),
                    
                    // Microphone icon with AI elements
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // AI spark
                        Icon(
                          Icons.auto_awesome,
                          size: 16.w,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        SizedBox(height: 4.h),
                        // Main microphone
                        Icon(
                          Icons.mic_rounded,
                          size: 32.w,
                          color: Colors.white,
                        ),
                        SizedBox(height: 4.h),
                        // Sound waves
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 3.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Container(
                              width: 3.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Container(
                              width: 3.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Floating AI particles
              Positioned(
                top: 20.h,
                right: 20.w,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 3),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(
                        10 * math.sin(value * 2 * math.pi),
                        5 * math.cos(value * 2 * math.pi),
                      ),
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE53935).withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              Positioned(
                bottom: 15.h,
                left: 15.w,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 4),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(
                        -8 * math.cos(value * 2 * math.pi),
                        -6 * math.sin(value * 2 * math.pi),
                      ),
                      child: Container(
                        width: 6.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1976D2).withOpacity(0.3),
                              blurRadius: 3,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          SizedBox(height: 32.h),
          
          // App name with brand colors
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'grader',
                  style: TextStyle(
                    fontSize: 44.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE53935), // Красный
                    letterSpacing: -1.5,
                    height: 1.1,
                  ),
                ),
                TextSpan(
                  text: '.ai',
                  style: TextStyle(
                    fontSize: 44.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1976D2), // Синий
                    letterSpacing: -1.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Professional tagline
          Text(
            'AI-Powered Language Assessment',
            style: TextStyle(
              fontSize: 18.sp,
              color: const Color(0xFF64748b),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 40.h),
          
          // Clean statistics
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1a1a2e).withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCleanStatItem('50K+', 'Students'),
                Container(
                  width: 1,
                  height: 32.h,
                  color: const Color(0xFFe2e8f0),
                ),
                _buildCleanStatItem('98%', 'Success Rate'),
                Container(
                  width: 1,
                  height: 32.h,
                  color: const Color(0xFFe2e8f0),
                ),
                _buildCleanStatItem('4.9★', 'Rating'),
              ],
            ),
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
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              // Clean section title
              Text(
                'Why Professionals Choose Grader.AI',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1a1a2e),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Advanced AI technology meets professional language assessment',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF64748b),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              
              // Professional feature cards with brand colors
              _buildProfessionalFeatureCard(
                icon: Icons.mic_none_rounded,
                title: 'AI-Powered Assessment',
                description: 'Get instant, accurate IELTS Speaking scores with detailed feedback from our advanced AI system.',
                color: const Color(0xFFE53935), // Красный
              ),
              SizedBox(height: 20.h),
              _buildProfessionalFeatureCard(
                icon: Icons.analytics_outlined,
                title: 'Detailed Analytics',
                description: 'Track your progress with comprehensive performance metrics and personalized improvement insights.',
                color: const Color(0xFF1976D2), // Синий
              ),
              SizedBox(height: 20.h),
              _buildProfessionalFeatureCard(
                icon: Icons.school_outlined,
                title: 'Expert-Level Training',
                description: 'Practice with real IELTS questions and receive feedback comparable to certified examiners.',
                color: const Color(0xFFE53935), // Красный
              ),
            ],
          ),
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
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              // Professional CTA section
              Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE53935), // Красный
                      const Color(0xFFD32F2F), // Темно-красный
                      const Color(0xFF1976D2), // Синий
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
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Ready to Master IELTS Speaking?',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Join thousands of successful candidates',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    
                    // Primary CTA Button
                    Container(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1a1a2e),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Start Free Assessment',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Secondary CTA Button
                    Container(
                      width: double.infinity,
                      height: 56.h,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Trust indicators
              Text(
                'Trusted by professionals worldwide',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748b),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

  Widget _buildEnhancedStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: Colors.white.withOpacity(0.9),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCleanStatItem(String value, String label) {
    // Определяем цвет для каждой статистики
    Color valueColor;
    if (label == 'Students') {
      valueColor = const Color(0xFFE53935); // Красный
    } else if (label == 'Success Rate') {
      valueColor = const Color(0xFF1976D2); // Синий
    } else {
      valueColor = const Color(0xFFE53935); // Красный для Rating
    }
    
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: valueColor,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748b),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1a1a2e),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748b),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

// Custom painter for AI brain pattern
class AIBrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw neural network pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final startX = center.dx + (radius * 0.3) * math.cos(angle);
      final startY = center.dy + (radius * 0.3) * math.sin(angle);
      final endX = center.dx + (radius * 0.7) * math.cos(angle);
      final endY = center.dy + (radius * 0.7) * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Draw nodes
      canvas.drawCircle(
        Offset(endX, endY),
        2,
        Paint()..color = Colors.white.withOpacity(0.3),
      );
    }

    // Draw connecting arcs
    for (int i = 0; i < 8; i++) {
      final angle1 = (i * math.pi * 2) / 8;
      final angle2 = ((i + 2) * math.pi * 2) / 8;
      
      final path = Path();
      path.addArc(
        Rect.fromCircle(center: center, radius: radius * 0.5),
        angle1,
        angle2 - angle1,
      );
      
      canvas.drawPath(path, paint..color = Colors.white.withOpacity(0.05));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
