import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/network_utils.dart';
import 'main_page.dart';

class RegistrationPage extends StatefulWidget {
  final String? authMethod; // 'email'
  final User? user; // Firebase user if coming from social login
  
  const RegistrationPage({
    super.key,
    this.authMethod,
    this.user,
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // State
  bool _isLoading = false;
  String? _error;
  String? _authMethod; // 'email'
  int _retryAttempt = 0; // Track retry attempts for UI
  
  // Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getUserInfo();
  }
  
  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  void _getUserInfo() {
    if (widget.user != null) {
      _nameController.text = widget.user!.displayName ?? '';
      _emailController.text = widget.user!.email ?? '';
      _authMethod = widget.authMethod ?? 'email';
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email/Password Registration with retry mechanism
  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _retryAttempt = 0;
    });

    try {
      // Check if Firebase is properly initialized
      if (_auth.app == null) {
        throw Exception('Firebase not initialized');
      }

      print('🔍 Attempting registration with email: ${_emailController.text.trim()}');
      
      // Registration with retry mechanism
      final UserCredential userCredential = await _retryRegistration(
        maxRetries: 3,
        retryDelay: const Duration(seconds: 2),
      );
      
      print('✅ Registration successful: ${userCredential.user?.email}');

      final User? user = userCredential.user;
      if (user != null) {
        // Update user profile with retry
        await _retryOperation(
          () => user.updateDisplayName(_nameController.text.trim()),
          maxRetries: 2,
        );
        
        // Initialize Firestore user data with retry
        await _retryOperation(
          () => FirestoreService.instance.ensureUserBootstrap(),
          maxRetries: 2,
        );
        
        // Navigate to main page
        _navigateToMain();
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _error = 'This email is already registered. Please sign in instead.';
            break;
          case 'invalid-email':
            _error = 'Please enter a valid email address.';
            break;
          case 'weak-password':
            _error = 'Password should be at least 6 characters long.';
            break;
          case 'operation-not-allowed':
            _error = 'Email registration is not enabled. Please contact support.';
            break;
          case 'internal-error':
            _error = 'Server error. Please try again in a few minutes. If the problem persists, contact support.';
            break;
          case 'network-request-failed':
            _error = 'Network error. Please check your internet connection and try again.';
            break;
          case 'too-many-requests':
            _error = 'Too many attempts. Please try again later.';
            break;
          default:
            _error = 'Registration failed: ${e.message ?? 'Unknown error occurred'}';
        }
      });
    } catch (e) {
      print('❌ General Error: $e');
      setState(() {
        if (e.toString().contains('network') || e.toString().contains('connection')) {
          _error = 'Network error. Please check your internet connection and try again.';
        } else if (e.toString().contains('timeout')) {
          _error = 'Registration timed out. Please check your internet connection and try again.';
        } else {
          _error = 'Registration failed. Please try again later.';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Retry registration with exponential backoff
  Future<UserCredential> _retryRegistration({
    required int maxRetries,
    required Duration retryDelay,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        attempts++;
        print('🔄 Registration attempt $attempts/$maxRetries');
        
        // Update UI with retry attempt
        if (mounted) {
          setState(() {
            _retryAttempt = attempts;
          });
        }
        
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ).timeout(
          const Duration(seconds: 15), // Reduced timeout for faster retry
          onTimeout: () {
            throw Exception('Registration timeout. Please try again.');
          },
        );
        
        print('✅ Registration successful on attempt $attempts');
        return userCredential;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        print('❌ Registration attempt $attempts failed: $e');
        
        if (attempts < maxRetries) {
          // Wait before retry with exponential backoff
          final delay = Duration(
            milliseconds: retryDelay.inMilliseconds * attempts,
          );
          print('⏳ Waiting ${delay.inSeconds}s before retry...');
          await Future.delayed(delay);
        }
      }
    }
    
    // All retries failed
    throw lastException ?? Exception('Registration failed after $maxRetries attempts');
  }

  /// Generic retry operation for Firebase operations
  Future<T> _retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        print('❌ Operation attempt $attempts failed: $e');
        
        if (attempts < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempts));
        }
      }
    }
    
    throw lastException ?? Exception('Operation failed after $maxRetries attempts');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  
                  // Header
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Creative Logo Container
                            Container(
                              width: 80.w,
                              height: 80.h,
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
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Background Circle
                                  Container(
                                    width: 70.w,
                                    height: 70.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  // Icon
                                  Icon(
                                    Icons.person_add_rounded,
                                    color: const Color(0xFF1976D2),
                                    size: 32.w,
                                  ),
                                  // Floating dots
                                  Positioned(
                                    top: 10.h,
                                    right: 10.w,
                                    child: Container(
                                      width: 6.w,
                                      height: 6.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1976D2).withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // Creative Title
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  const Color(0xFF1976D2),
                                  const Color(0xFFE53935),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            // Creative Subtitle Container
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFF1976D2).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Join thousands of IELTS learners',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: const Color(0xFF1976D2),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Form Card
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Form Title
                                Text(
                                  'Personal Information',
                                  style: AppTypography.titleLarge.copyWith(
                                    color: const Color(0xFF1a1a2e),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Fill in your details to get started',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: const Color(0xFF64748b),
                                    fontSize: 13.sp,
                                  ),
                                ),
                                
                                SizedBox(height: 24.h),
                                
                                // Name Field
                                _buildModernTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  hint: 'Enter your full name',
                                  icon: Icons.person_outline_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'Name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                // Username Field
                                _buildModernTextField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  hint: 'Choose a username (optional)',
                                  icon: Icons.alternate_email_rounded,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (value.trim().length < 3) {
                                        return 'Username must be at least 3 characters';
                                      }
                                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                                        return 'Username can only contain letters, numbers, and underscores';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                // Email Field
                                _buildModernTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  hint: 'Enter your email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                // Password Field
                                _buildModernTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'Create a secure password',
                                  icon: Icons.lock_outline_rounded,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 24.h),
                                
                                // Creative Registration Button
                                Container(
                                  width: double.infinity,
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF1976D2),
                                        const Color(0xFFE53935),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1976D2).withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFFE53935).withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _isLoading ? null : _signUpWithEmail,
                                      borderRadius: BorderRadius.circular(30.r),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        child: Center(
                                          child: _isLoading
                                              ? Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: 24.w,
                                                      height: 24.h,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                          Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    if (_retryAttempt > 0) ...[
                                                      SizedBox(height: 8.h),
                                                      Text(
                                                        'Attempt $_retryAttempt/3',
                                                        style: TextStyle(
                                                          color: Colors.white.withOpacity(0.8),
                                                          fontSize: 12.sp,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 32.w,
                                                      height: 32.h,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(16.r),
                                                      ),
                                                      child: Icon(
                                                        Icons.rocket_launch_rounded,
                                                        color: Colors.white,
                                                        size: 18.w,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Text(
                                                      'Create Account',
                                                      style: AppTypography.titleMedium.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 16.sp,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Icon(
                                                      Icons.arrow_forward_ios_rounded,
                                                      color: Colors.white,
                                                      size: 16.w,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: 16.h),
                                
                                // Error Display
                                if (_error != null) ...[
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.red,
                                          size: 18.w,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            _error!,
                                            style: AppTypography.bodySmall.copyWith(
                                              color: Colors.red,
                                              fontSize: 13.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Footer
                  Text(
                    'By creating an account, you agree to our Terms of Service',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF64748b),
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF374151),
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            enabled: true,
            style: AppTypography.bodyLarge.copyWith(
              color: const Color(0xFF1a1a2e),
              fontSize: 15.sp,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: const Color(0xFF9CA3AF),
                fontSize: 14.sp,
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
                  size: 18.w,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: const Color(0xFF1976D2),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
