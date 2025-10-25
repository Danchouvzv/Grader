import 'dart:async';
import 'dart:math';
import 'dart:ui'; // Для ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для SystemUiOverlayStyle
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../shared/themes/app_colors.dart';
import '../../core/services/firestore_service.dart';
import 'main_page.dart';
import 'welcome_page.dart';
import 'registration_page.dart';
import 'signin_page.dart';

// Particle data class для оптимизации
class Particle {
  final double startX;
  final double startY;
  final double size;
  final int duration;
  
  const Particle({
    required this.startX,
    required this.startY,
    required this.size,
    required this.duration,
  });
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  // Safe ScreenUtil functions to prevent NaN errors
  double safeHeight(double value) {
    final result = value.h;
    return result.isNaN ? value : result;
  }

  double safeWidth(double value) {
    final result = value.w;
    return result.isNaN ? value : result;
  }

  double safeSp(double value) {
    final result = value.sp;
    return result.isNaN ? value : result;
  }

  double safeRadius(double value) {
    final result = value.r;
    return result.isNaN ? value : result;
  }
  
  // Safe opacity function to prevent invalid values
  double safeOpacity(double value) {
    if (value.isNaN) return 0.0;
    if (value < 0.0) return 0.0;
    if (value > 1.0) return 1.0;
    return value;
  }
  late AnimationController _logoController;
  late AnimationController _particlesController;
  late AnimationController _pulseController;
  late AnimationController _buttonController;
  late AnimationController _shimmerController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late Animation<double> _buttonSlideAnimation;
  
  bool _hasNavigated = false;
  bool _isChecking = true;
  bool _showRetry = false;
  String? _lastError;
  
  // Фиксированные частицы для стабильности
  late final List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _initializeAnimations();
    _checkAuthAndNavigate();
  }

  void _initializeParticles() {
    final random = Random(42); // Фиксированный seed
    _particles = List.generate(8, (index) { // 6-8 мягких частиц
      return Particle(
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        size: 1.4 + random.nextDouble() * 1.2, // Меньший размер
        duration: 28 + random.nextInt(18), // Медленное движение
      );
    });
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    // Add safety check for opacity values
    _logoOpacityAnimation.addListener(() {
      if (_logoOpacityAnimation.value.isNaN || 
          _logoOpacityAnimation.value < 0.0 || 
          _logoOpacityAnimation.value > 1.0) {
        print('⚠️ Invalid logo opacity: ${_logoOpacityAnimation.value}');
      }
    });
    
    _textSlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    
    _particlesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _particlesController.repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
      ),
    );

    // Button entrance animations
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
    _buttonSlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutCubic),
    );

    // Shimmer for CTA
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();


    if (mounted) {
      _logoController.forward();
      // Start buttons a bit later for staged entrance
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _buttonController.forward();
      });
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    if (_hasNavigated) return;
    
    // Даём UI время дорисоваться
    await Future.microtask(() {});
    
    try {
      if (mounted) setState(() { _isChecking = true; _showRetry = false; _lastError = null; });
      // Ждём инициализации Firebase Auth
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      
      // Минимум 2.5 секунды для UX
      await Future.delayed(const Duration(milliseconds: 2500));
      
      if (!mounted) return;
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (!mounted) return;
      
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
         // Retry logic для Firestore
         final userData = await _retryOperation(
           () => FirestoreService.instance.getUserProfile(),
           retries: 2,
         );
        
        if (!mounted) return;
        
        if (userData != null && userData['isRegistrationComplete'] == true) {
          // Инициализируем данные с retry
          await _retryOperation(
            () => FirestoreService.instance.ensureUserBootstrap(),
            retries: 2,
          );
          
          if (!mounted) return;
          if (mounted) setState(() { _isChecking = false; });
          _navigateToMain();
        } else {
          if (mounted) setState(() { _isChecking = false; });
          _navigateToRegistration(user: user);
        }
       } else {
         // Остаемся на splash screen как на welcome screen
         if (mounted) setState(() { _isChecking = false; });
       }
    } catch (e) {
      debugPrint('⚠️ Splash navigation error: $e');
      
      if (!mounted) return;
      
       // Показываем ошибку пользователю и остаемся на splash
       _lastError = 'Connection issue. Please check your internet.';
       _showErrorAndNavigate(
         _lastError!,
       );
       setState(() {
         _isChecking = false;
         _showRetry = true;
       });
    }
  }

  Future<T?> _retryOperation<T>(
    Future<T> Function() operation, {
    int retries = 2,
  }) async {
    for (var i = 0; i < retries; i++) {
      try {
        debugPrint('🔁 Retry operation attempt ${i + 1}/$retries');
        return await operation();
      } catch (e) {
        if (i == retries - 1) rethrow;
        await Future.delayed(Duration(milliseconds: 300 * (i + 1)));
      }
    }
    return null;
  }

  void _showErrorAndNavigate(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
    
    // Остаемся на splash screen как на welcome screen
    // Не переходим никуда, показываем ошибку и остаемся здесь
  }

  void _navigateToMain() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 900), // Увеличили на 300ms
      ),
    );
  }

  void _navigateToWelcome() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const WelcomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 900), // Увеличили на 300ms
      ),
    );
  }

  void _navigateToRegistration({User? user}) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RegistrationPage(user: user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 900), // Увеличили на 300ms
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

  @override
  void dispose() {
    _logoController.dispose();
    _particlesController.dispose();
    _pulseController.dispose();
    _buttonController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // белые иконки
      child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF091524), // deep navy
              Color(0xFF0E2036), // navy
              Color(0xFF171A3D), // легкий фиолет
              Color(0xFF220C2F), // красно-фиолет (низ/право)
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildParticlesBackground(),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // subtle loading ring under logo when checking
                  if (_isChecking)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ),
                  _buildAnimatedLogo(),
                  SizedBox(height: 36), // Logo → Title
                   _buildAnimatedText(),
                   SizedBox(height: 12), // Title → Tagline
                   _buildTagline(),
                   SizedBox(height: 6), // Tagline → Sub
                   _buildSubTagline(),
                   SizedBox(height: 48), // Sub → Button
                   _buildAuthButtons(),
                  if (_showRetry)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() { _showRetry = false; _isChecking = true; });
                          _checkAuthAndNavigate();
                        },
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        label: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildParticlesBackground() {
    return AnimatedBuilder(
      animation: _particlesController,
                      builder: (context, child) {
        return Stack(
          children: _particles.asMap().entries.map((entry) {
            final index = entry.key;
            final particle = entry.value;
            
            final progress = (_particlesController.value + (index / _particles.length)) % 1.0;
            final speedMultiplier = 0.7 + (index % 3) * 0.15;
            final x = particle.startX + sin(progress * pi * 2 * (0.6 + index % 3 * 0.2)) * 0.08;
            final y = (particle.startY + progress * speedMultiplier) % 1.15 - 0.075;
            
            return Positioned(
              left: MediaQuery.of(context).size.width * x.clamp(0.0, 1.0),
              top: MediaQuery.of(context).size.height * y,
              child: Transform.scale(
                scale: 1 + sin(progress * pi * 2) * 0.02, // лёгкая пульсация
                child: Opacity(
                  opacity: (0.65 - progress * 0.45).clamp(0.15, 0.65), // Успокоенная прозрачность
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                        colors: index.isEven
                            ? [
                                const Color(0xFF2196F3).withOpacity(0.25), // синие
                                Colors.transparent,
                              ]
                            : [
                                const Color(0xFFE53935).withOpacity(0.25), // красные
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value * _pulseAnimation.value,
          child: Opacity(
            opacity: safeOpacity(_logoOpacityAnimation.value),
            child: Container(
              width: 120,
              height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                gradient: const LinearGradient(
                                          colors: [
                    Color(0xFF2196F3), // яркий синий
                    Color(0xFFE53935), // яркий красный
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.22),
                    blurRadius: 34,
                    offset: const Offset(-10, -8),
                                          ),
                                          BoxShadow(
                    color: const Color(0xFFE53935).withOpacity(0.28),
                    blurRadius: 36,
                    offset: const Offset(10, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                                            color: Colors.white,
                size: 38,
              ),
            ),
                                ),
                              );
                            },
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _logoController,
                      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlideAnimation.value),
          child: Opacity(
            opacity: safeOpacity(_logoOpacityAnimation.value),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                                    colors: [
                  Color(0xFF2196F3),
                  Color(0xFFE53935),
                                    ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                                  ).createShader(bounds),
              child: const Text(
                                    'Grader.AI',
                                    style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
                                    ),
                                  ),
                                ),
        );
      },
    );
  }

  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlideAnimation.value),
          child: Opacity(
            opacity: safeOpacity(_logoOpacityAnimation.value * 0.9),
            child: Text(
              'Speak. Improve. Achieve.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
                                    ),
                                  ),
                                ),
        );
      },
    );
  }

  Widget _buildSubTagline() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlideAnimation.value * 0.5),
          child: Opacity(
            opacity: safeOpacity(_logoOpacityAnimation.value * 0.8),
            child: Text(
              'Your AI-Powered English Journey',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                fontStyle: FontStyle.italic,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
                            ),
                          ),
                        );
                      },
    );
  }

  Widget _buildAuthButtons() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacityAnimation.value,
          child: Column(
                      children: [
              // Get Started Button (premium с glow эффектами)
              Stack(
                children: [
                        Container(
                    width: 340.w, // Фиксированная ширина как на скрине
                    height: 62.h, // Высота кнопки
                          decoration: BoxDecoration(
                      // 1. ГЛАВНЫЙ ГРАДИЕНТ (синий → красный)
                      gradient: const LinearGradient(
                              colors: [
                          Color(0xFF2563EB), // Насыщенный синий
                          Color(0xFF7C3AED), // Фиолетовый (промежуточный)
                          Color(0xFFEF4444), // Насыщенный красный
                              ],
                        stops: [0.0, 0.5, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                            ),
                      borderRadius: BorderRadius.circular(31.r), // Полностью закругленная
                      
                      // 2. ВНЕШНЯЯ ТЕНЬ (glow эффект)
                            boxShadow: [
                        // Красное свечение снизу
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.5),
                          blurRadius: 24,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                        // Синее свечение сверху
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: -4,
                          offset: const Offset(0, -4),
                        ),
                        // Общий depth эффект
                              BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                    
                    // 3. ВНУТРЕННИЙ КОНТЕЙНЕР (для белой рамки)
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(31.r),
                        // Очень тонкая белая обводка
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                          borderRadius: BorderRadius.circular(31.r),
                          
                          // 4. RIPPLE ЭФФЕКТ при нажатии
                          splashColor: Colors.white.withOpacity(0.2),
                          highlightColor: Colors.white.withOpacity(0.1),
                          
                          onTap: _navigateToRegistration,
                          
                          // 5. ТЕКСТ КНОПКИ
                          child: Center(
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: Colors.white,
                                shadows: [
                                  // Тень для текста (depth)
                                  Shadow(
                                    color: Colors.black.withOpacity(0.25),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                  // Highlight линза поверх кнопки
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                          decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(31.r),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.10),
                              Colors.transparent,
                              Colors.white.withOpacity(0.08),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
              SizedBox(height: 20),
                        
              // Sign In Link
              TextButton(
                style: TextButton.styleFrom(
                  overlayColor: Colors.white.withOpacity(0.1),
                ),
                onPressed: _signInToExistingAccount,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: Color(0xFF93C5FD),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF93C5FD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
                      ],
                    ),
        );
      },
    );
  }

}
