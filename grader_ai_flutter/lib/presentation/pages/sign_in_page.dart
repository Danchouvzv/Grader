import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/animated_background.dart';
import '../widgets/gradient_button.dart';
import 'sign_up_page.dart';
import 'dashboard_page.dart';

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
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
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
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  _buildHeader(),
                  SizedBox(height: 50.h),
                  _buildSignInForm(),
                  SizedBox(height: 30.h),
                  _buildFooter(),
                  SizedBox(height: 20.h),
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
          // Back Button
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: const Color(0xFF1976D2),
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40.h),
          // Logo
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1976D2),
                  Color(0xFF1565C0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'G',
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 30.h),
          // Title
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Sign in to continue your journey',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email address',
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
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
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
                _buildRememberMeAndForgotPassword(),
                SizedBox(height: 32.h),
                _buildSignInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: 10.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !isPasswordVisible,
          validator: validator,
          style: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF2C3E50),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15.sp,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(12.w),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1976D2),
                size: 20.sp,
              ),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[400],
                      size: 22.sp,
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: Color(0xFF1976D2),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: Color(0xFFE53935),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: Color(0xFFE53935),
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12.w,
      runSpacing: 8.h,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              'Remember me',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Forgot password functionality coming soon!'),
                backgroundColor: Color(0xFF1976D2),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF1976D2),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return GradientButton(
      text: _isLoading ? 'Signing In...' : 'Sign In',
      icon: _isLoading ? null : Icons.login,
      onPressed: !_isLoading ? _handleSignIn : null,
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'or continue with',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          SizedBox(height: 24.h),
          // Social Sign In Buttons
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.g_mobiledata,
                  color: const Color(0xFFDB4437),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Sign In coming soon!'),
                        backgroundColor: Color(0xFFDB4437),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.apple,
                  color: const Color(0xFF000000),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Apple Sign In coming soon!'),
                        backgroundColor: Color(0xFF000000),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 40.h),
          // Sign Up Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account? ',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[600],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ),
                  );
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF1976D2),
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onPressed,
          child: Center(
            child: Icon(icon, color: color, size: 28.sp),
          ),
        ),
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

    // TODO: Implement actual sign in logic with Firebase Auth
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed in successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      // Navigate to dashboard (extract name from email for demo)
      String userName = _emailController.text.split('@').first;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            userName: userName.isNotEmpty ? userName : 'User',
          ),
        ),
        (route) => false, // Remove all previous routes
      );
    }
  }
}
