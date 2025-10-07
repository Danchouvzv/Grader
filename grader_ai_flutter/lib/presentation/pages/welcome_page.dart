import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/animated_background.dart';
import '../widgets/gradient_button.dart';
import 'sign_up_page.dart';
import 'sign_in_page.dart';
import 'main_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active && snapshot.data != null) {
          return const MainPage();
        }
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
                    _buildCallToAction(context),
                    SizedBox(height: 40.h),
                    SizedBox(height: 20.h), // Bottom padding for safe area
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
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
                return Container(
                  width: 120.w + (value * 20),
                  height: 120.h + (value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE53935).withOpacity(0.3 - (value * 0.2)),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
            
            // Inner gradient circle
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE53935),
                    const Color(0xFF1976D2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53935).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 50.w,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 40.h),
        
        // Professional title
        Text(
          'Grader.AI',
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        // Subtitle
        Text(
          'AI-Powered Career & IELTS Assessment',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        
        SizedBox(height: 30.h),
        
        // Clean stats
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCleanStatItem('10K+', 'Users'),
              Container(
                width: 1,
                height: 30.h,
                color: const Color(0xFFe2e8f0),
              ),
              _buildCleanStatItem('4.9★', 'Rating'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCleanStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Clean section title
          Text(
            'Why Professionals Choose Grader.AI',
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 40.h),
          
          // Feature cards
          _buildFeatureCard(
            icon: Icons.psychology_rounded,
            title: 'AI-Powered Assessment',
            description: 'Advanced AI analyzes your speaking patterns, vocabulary, and fluency with precision.',
            gradient: [const Color(0xFFE53935), const Color(0xFF1976D2)],
          ),
          
          SizedBox(height: 24.h),
          
          _buildFeatureCard(
            icon: Icons.work_rounded,
            title: 'Career Guidance',
            description: 'Discover your ideal career path through intelligent matching and personalized recommendations.',
            gradient: [const Color(0xFF1976D2), const Color(0xFF4CAF50)],
          ),
          
          SizedBox(height: 24.h),
          
          _buildFeatureCard(
            icon: Icons.trending_up_rounded,
            title: 'Real Progress Tracking',
            description: 'Monitor your improvement with detailed analytics and actionable insights.',
            gradient: [const Color(0xFF4CAF50), const Color(0xFFE53935)],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28.w,
            ),
          ),
          
          SizedBox(width: 20.w),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.8),
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

  Widget _buildCallToAction(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Professional CTA section
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // CTA title
                Text(
                  'Ready to Transform Your Future?',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 12.h),
                
                // CTA subtitle
                Text(
                  'Join thousands of professionals who trust Grader.AI for their career and language development.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 32.h),
                
                // CTA buttons
                Column(
                  children: [
                    // Primary CTA Button
                    Container(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const SignUpPage(),
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
                          'Get Started Free',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
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
                              builder: (ctx) => const SignInPage(),
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
                            letterSpacing: 0.5,
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
      ),
    );
  }
}