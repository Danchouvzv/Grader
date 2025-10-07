import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../shared/themes/design_system.dart';
import '../../core/services/iap_service.dart';
import 'dart:math' as math;

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _selectedPlan;
  final IAPService _iapService = IAPService();
  late AnimationController _floatingController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _loadSubscriptionPlans();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptionPlans() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _iapService.initialize();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load subscription plans: $e'),
            backgroundColor: DesignSystem.red500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignSystem.blue600,
              DesignSystem.purple600,
              DesignSystem.pink500,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading 
                    ? _buildLoadingState()
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20.w,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Loading Premium Plans...',
            style: DesignSystem.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 32.h),
          _buildFeatures(),
          SizedBox(height: 32.h),
          _buildPlans(),
          SizedBox(height: 24.h),
          _buildFooter(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Floating crown icon
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(_floatingController.value * math.pi) * 10),
                child: child,
              );
            },
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade400,
                    Colors.yellow.shade600,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 48.w,
                color: Colors.white,
              ),
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Title with shimmer effect
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.8),
                  Colors.white,
                ],
                stops: const [0.0, 0.5, 1.0],
                transform: GradientRotation(_shimmerController.value * 2 * math.pi),
              ).createShader(bounds);
            },
            child: Text(
              'Unlock Premium',
              style: DesignSystem.displayLarge.copyWith(
                fontSize: 36.sp,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          Text(
            'Get unlimited access to all features',
            style: DesignSystem.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {'icon': Icons.all_inclusive_rounded, 'title': 'Unlimited Sessions', 'subtitle': 'Practice as much as you want'},
      {'icon': Icons.analytics_rounded, 'title': 'Advanced Analytics', 'subtitle': 'Track your progress in detail'},
      {'icon': Icons.psychology_rounded, 'title': 'AI Insights', 'subtitle': 'Get personalized recommendations'},
      {'icon': Icons.workspace_premium_rounded, 'title': 'Premium Topics', 'subtitle': 'Access exclusive content'},
      {'icon': Icons.download_rounded, 'title': 'Offline Access', 'subtitle': 'Download and practice anywhere'},
      {'icon': Icons.support_agent_rounded, 'title': 'Priority Support', 'subtitle': '24/7 dedicated assistance'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s Included',
              style: DesignSystem.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 20.h),
            ...features.map((feature) => _buildFeatureItem(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              subtitle: feature['subtitle'] as String,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignSystem.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: DesignSystem.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlans() {
    // Use mock data if no products available
    final hasProducts = _iapService.products.isNotEmpty;
    
    if (!hasProducts && _iapService.isAvailable) {
      return _buildMockPlans();
    }
    
    if (!_iapService.isAvailable) {
      return _buildUnavailableMessage();
    }

    return Column(
      children: _iapService.products.map((product) {
        final planInfo = _iapService.getSubscriptionPlanInfo(product.id);
        return _buildPlanCard(
          productId: product.id,
          title: planInfo['name'] as String,
          price: product.price,
          interval: planInfo['interval'] as String,
          features: planInfo['features'] as List<String>,
          isPopular: planInfo['isPopular'] as bool,
          isMock: false,
        );
      }).toList(),
    );
  }

  Widget _buildMockPlans() {
    final mockPlans = [
      {
        'id': 'monthly_premium',
        'name': 'Monthly Premium',
        'price': '\$9.99',
        'interval': 'month',
        'features': ['Full AI Analysis', 'Unlimited Sessions', 'Advanced Stats'],
        'isPopular': false,
      },
      {
        'id': 'yearly_premium',
        'name': 'Yearly Premium',
        'price': '\$79.99',
        'interval': 'year',
        'features': ['Everything in Monthly', '33% Discount', 'Priority Support'],
        'isPopular': true,
      },
      {
        'id': 'lifetime_premium',
        'name': 'Lifetime Access',
        'price': '\$199.99',
        'interval': 'lifetime',
        'features': ['All Premium Features', 'One-time Payment', 'Lifetime Updates'],
        'isPopular': false,
      },
    ];

    return Column(
      children: mockPlans.map((plan) {
        return _buildPlanCard(
          productId: plan['id'] as String,
          title: plan['name'] as String,
          price: plan['price'] as String,
          interval: plan['interval'] as String,
          features: plan['features'] as List<String>,
          isPopular: plan['isPopular'] as bool,
          isMock: true,
        );
      }).toList(),
    );
  }

  Widget _buildPlanCard({
    required String productId,
    required String title,
    required String price,
    required String interval,
    required List<String> features,
    required bool isPopular,
    required bool isMock,
  }) {
    final isSelected = _selectedPlan == productId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = productId;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.95),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected 
                ? Colors.amber.shade400
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: DesignSystem.headlineMedium.copyWith(
                              fontSize: 20.sp,
                              color: isSelected 
                                  ? DesignSystem.textPrimary
                                  : Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                price,
                                style: DesignSystem.displayLarge.copyWith(
                                  fontSize: 32.sp,
                                  color: isSelected
                                      ? DesignSystem.blue600
                                      : Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Padding(
                                padding: EdgeInsets.only(bottom: 4.h),
                                child: Text(
                                  '/$interval',
                                  style: DesignSystem.bodyMedium.copyWith(
                                    color: isSelected
                                        ? DesignSystem.textSecondary
                                        : Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isSelected)
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            gradient: DesignSystem.successGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ...features.map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: isSelected
                              ? DesignSystem.green600
                              : Colors.white.withOpacity(0.9),
                          size: 18.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          feature,
                          style: DesignSystem.bodyMedium.copyWith(
                            color: isSelected
                                ? DesignSystem.textPrimary
                                : Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade400,
                        Colors.orange.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.r),
                      bottomLeft: Radius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 14.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'MOST POPULAR',
                        style: DesignSystem.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailableMessage() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 48.w,
            ),
            SizedBox(height: 16.h),
            Text(
              'In-App Purchases Not Available',
              style: DesignSystem.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'This feature is not available on web platform. Please use the mobile app.',
              style: DesignSystem.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final isMock = _iapService.products.isEmpty && _iapService.isAvailable;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              gradient: _selectedPlan != null
                  ? LinearGradient(
                      colors: [
                        Colors.amber.shade400,
                        Colors.orange.shade500,
                      ],
                    )
                  : null,
              color: _selectedPlan == null
                  ? Colors.white.withOpacity(0.3)
                  : null,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: _selectedPlan != null
                  ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _selectedPlan != null
                    ? () => _handleSubscription(_selectedPlan!, isMock)
                    : null,
                borderRadius: BorderRadius.circular(16.r),
                child: Center(
                  child: Text(
                    _selectedPlan != null
                        ? 'Continue to Payment'
                        : 'Select a Plan',
                    style: DesignSystem.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Cancel anytime. Terms apply.',
            style: DesignSystem.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscription(String productId, bool isMock) async {
    if (isMock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mock mode: Real products not configured in stores'),
          backgroundColor: DesignSystem.amber500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = _iapService.products.firstWhere(
        (p) => p.id == productId,
      );

      final success = await _iapService.purchaseProduct(product);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Premium activated successfully!'),
            backgroundColor: DesignSystem.green600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: DesignSystem.red500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
