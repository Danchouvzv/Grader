import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../core/services/firestore_service.dart';
import 'main_page.dart';
import 'welcome_page.dart';
import 'registration_page.dart';
import 'signin_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations with mounted check
    if (mounted) {
      _logoController.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _textController.forward();
        }
      });
    }
    _pulseController.repeat(reverse: true);
  }


  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToWelcome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const WelcomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToRegistration({String? authMethod, User? user}) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RegistrationPage(
          authMethod: authMethod,
          user: user,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }


  // Sign In to existing account
  Future<void> _signInToExistingAccount() async {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignInPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }


  Future<void> _initializeUserData() async {
    try {
      // Initialize Firestore user data
      await FirestoreService.instance.ensureUserBootstrap();
    } catch (e) {
      print('Warning: Failed to initialize user data: $e');
      // Don't block the user from proceeding, just log the error
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFF8FAFC),
              const Color(0xFFF1F5F9),
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 80.h),
                    
                    // Creative Logo Section
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer Glow Ring
                                    Container(
                                      width: 140.w,
                                      height: 140.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.3),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Main Logo Container
                                    Container(
                                      width: 120.w,
                                      height: 120.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.9),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 30,
                                            offset: const Offset(0, 15),
                                            spreadRadius: 0,
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, -5),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Background Circle
                                          Container(
                                            width: 100.w,
                                            height: 100.h,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  const Color(0xFF1976D2),
                                                  const Color(0xFFE53935),
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          // AI Brain Icon
                                          Icon(
                                            Icons.psychology_rounded,
                                            color: Colors.white,
                                            size: 50.w,
                                          ),
                                          // Floating dots
                                          Positioned(
                                            top: 15.h,
                                            right: 15.w,
                                            child: Container(
                                              width: 8.w,
                                              height: 8.h,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.8),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 20.h,
                                            left: 10.w,
                                            child: Container(
                                              width: 6.w,
                                              height: 6.h,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.6),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 60.h),
                    
                    // Creative App Name
                    AnimatedBuilder(
                      animation: _textAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - _textAnimation.value)),
                            child: Column(
                              children: [
                                // App Name with Creative Typography
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    'Grader.AI',
                                    style: TextStyle(
                                      fontSize: 42.sp,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.0,
                                      color: const Color(0xFF1a1a2e),
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                // Creative Tagline Container
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(25.r),
                                    border: Border.all(
                                      color: const Color(0xFF1976D2).withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'AI-Powered IELTS Speaking',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: const Color(0xFF1976D2),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: 8.h),
                                
                                // Subtitle
                                Text(
                                  'Master English with AI',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: const Color(0xFF64748b),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 80.h),
                    
                    // Creative Auth Buttons
                    Column(
                      children: [
                        // Email Registration - Creative Button
                        Container(
                          width: double.infinity,
                          height: 64.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.95),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading ? null : _navigateToRegistration,
                              borderRadius: BorderRadius.circular(32.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 24.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40.w,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1976D2).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20.r),
                                      ),
                                      child: Icon(
                                        Icons.email_outlined,
                                        color: const Color(0xFF1976D2),
                                        size: 20.w,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Text(
                                      'Continue with Email',
                                      style: AppTypography.titleMedium.copyWith(
                                        color: const Color(0xFF1976D2),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: const Color(0xFF1976D2),
                                      size: 16.w,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Sign In to Existing Account - Creative Link
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: const Color(0xFFE53935).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TextButton(
                            onPressed: _isLoading ? null : _signInToExistingAccount,
                            child: Text(
                              'Already have an account? Sign In',
                              style: AppTypography.bodyMedium.copyWith(
                                color: const Color(0xFFE53935),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFFE53935),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 60.h),
                    
                    // Terms
                    Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF64748b),
                        fontSize: 12.sp,
                      ),
                    ),
                    
                    SizedBox(height: 60.h),
                    
                    // Loading Indicator
                    _isLoading ? Container(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1976D2)),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Setting up your account...',
                            style: AppTypography.bodyMedium.copyWith(
                              color: const Color(0xFF64748b),
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ) : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          side: borderColor != null ? BorderSide(color: borderColor, width: 2) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: backgroundColor == Colors.white 
                    ? const Color(0xFF1976D2).withOpacity(0.1)
                    : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24.w,
                color: textColor,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              label,
              style: AppTypography.titleMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
