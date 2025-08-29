import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/animated_background.dart';
import '../widgets/gradient_button.dart';
import 'sign_in_page.dart';
import 'main_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFF8FAFC),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildHeader(),
                  SizedBox(height: 40.h),
                  _buildSignUpForm(),
                  SizedBox(height: 30.h),
                  _buildSignInLink(),
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
          // Back button
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: const Color(0xFFE53935),
                    size: 20.w,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 32.h),
          
          // Creative mini logo
          _buildMiniLogo(),
          
          SizedBox(height: 24.h),
          
          // Title and subtitle
          Text(
            'Join Grader.AI',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1a1a2e),
              letterSpacing: -1,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            'Start your AI-powered IELTS journey today',
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF64748b),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring with animation
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 3),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 2 * math.pi,
              child: Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE53935).withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
            );
          },
        ),
        
        // Main logo
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE53935),
                const Color(0xFF1976D2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 24.w,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1a1a2e).withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 8,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Full Name
              _buildFormField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20.h),
              
              // Email
              _buildFormField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20.h),
              
              // Password
              _buildFormField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20.h),
              
              // Confirm Password
              _buildFormField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                isPasswordVisible: _isConfirmPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 24.h),
              
              // Terms checkbox
              _buildTermsCheckbox(),
              
              SizedBox(height: 32.h),
              
              // Sign Up Button
              _buildSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1a1a2e).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1a1a2e),
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.all(12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE53935).withOpacity(0.1),
                      const Color(0xFF1976D2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFE53935),
                  size: 20.w,
                ),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: onTogglePassword,
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF64748b),
                        size: 20.w,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: const Color(0xFFE53935),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: Colors.red.shade400,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: Colors.red.shade400,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 18.h,
              ),
              hintStyle: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _agreeToTerms = !_agreeToTerms;
            });
          },
          child: Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: _agreeToTerms 
                    ? const Color(0xFFE53935) 
                    : const Color(0xFFE2E8F0),
                width: 2,
              ),
              gradient: _agreeToTerms 
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFE53935),
                        const Color(0xFF1976D2),
                      ],
                    ) 
                  : null,
            ),
            child: _agreeToTerms
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16.w,
                  )
                : null,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748b),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748b),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
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
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withOpacity(0.4),
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
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748b),
              fontWeight: FontWeight.w400,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SignInPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFFE53935),
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the Terms of Service and Privacy Policy'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20.w,
            ),
            SizedBox(width: 8.w),
            const Text('Account created successfully!'),
          ],
        ),
        backgroundColor: Colors.green.shade500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );

    // Navigate to main page
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }
}