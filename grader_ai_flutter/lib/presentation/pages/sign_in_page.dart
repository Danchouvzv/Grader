import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/animated_background.dart';
import '../widgets/gradient_button.dart';
import 'sign_up_page.dart';
import 'main_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

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
    _emailController.dispose();
    _passwordController.dispose();
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
                  SizedBox(height: 60.h),
                  _buildSignInForm(),
                  SizedBox(height: 40.h),
                  _buildSignUpLink(),
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
                        color: const Color(0xFF1976D2).withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: const Color(0xFF1976D2),
                    size: 20.w,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 40.h),
          
          // Creative mini logo
          _buildMiniLogo(),
          
          SizedBox(height: 32.h),
          
          // Title and subtitle
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1a1a2e),
              letterSpacing: -1.2,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Text(
            'Continue your AI-powered learning journey',
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
          duration: const Duration(seconds: 4),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: -value * 2 * math.pi,
              child: Container(
                width: 90.w,
                height: 90.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1976D2).withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
            );
          },
        ),
        
        // Main logo
        Container(
          width: 70.w,
          height: 70.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1976D2),
                const Color(0xFFE53935),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1976D2).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.login_rounded,
            color: Colors.white,
            size: 28.w,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInForm() {
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
              
              SizedBox(height: 24.h),
              
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
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20.h),
              
              // Remember me and Forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRememberMe(),
                  _buildForgotPassword(),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // Sign In Button
              _buildSignInButton(),
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
                      const Color(0xFF1976D2).withOpacity(0.1),
                      const Color(0xFFE53935).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF1976D2),
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
                  color: const Color(0xFF1976D2),
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

  Widget _buildRememberMe() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          child: Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: _rememberMe 
                    ? const Color(0xFF1976D2) 
                    : const Color(0xFFE2E8F0),
                width: 2,
              ),
              gradient: _rememberMe 
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF1976D2),
                        const Color(0xFFE53935),
                      ],
                    ) 
                  : null,
            ),
            child: _rememberMe
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14.w,
                  )
                : null,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'Remember me',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF64748b),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return GestureDetector(
      onTap: () {
        // Handle forgot password
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset link sent to your email!'),
            backgroundColor: const Color(0xFF1976D2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF1976D2),
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1976D2),
            const Color(0xFF1565C0),
            const Color(0xFFE53935),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFFE53935).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignIn,
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
                    Icons.login_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Sign In',
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

  Widget _buildSignUpLink() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
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
                      const SignUpPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF1976D2),
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
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
            const Text('Welcome back!'),
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