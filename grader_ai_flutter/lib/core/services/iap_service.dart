import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Product IDs for subscription plans
  static const String monthlyPremiumId = 'monthly_premium';
  static const String yearlyPremiumId = 'yearly_premium';
  static const String lifetimePremiumId = 'lifetime_premium';
  
  final Set<String> _productIds = {
    monthlyPremiumId,
    yearlyPremiumId,
    lifetimePremiumId,
  };

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  String? _queryProductError;

  // Getters
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  String? get queryProductError => _queryProductError;
  bool get isMockMode => !_isAvailable || _products.isEmpty;
  List<String> get mockProductIds => [
        monthlyPremiumId,
        yearlyPremiumId,
        lifetimePremiumId,
      ];

  /// Initialize IAP service
  Future<void> initialize() async {
    try {
      // Check if running on web - IAP is not supported on web
      if (kIsWeb) {
        debugPrint('IAP not supported on web platform');
        return;
      }

      // Check if IAP is available
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        debugPrint('IAP not available on this device');
        return;
      }

      // Set up purchase updates listener
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: _onPurchaseDone,
        onError: _onPurchaseError,
      );

      // Load products
      await _loadProducts();

      // Restore previous purchases
      await _restorePurchases();

      debugPrint('IAP Service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize IAP Service: $e');
    }
  }

  /// Load available products from store
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
        // In development/testing, products may not be available
        // The UI will show a message to use mobile device
      }
      
      if (response.error != null) {
        _queryProductError = response.error!.message;
        debugPrint('Error querying products: ${response.error}');
        return;
      }

      _products = response.productDetails;
      debugPrint('Loaded ${_products.length} products');
      
      // For testing: If no products loaded, set available to false
      // This will show appropriate UI message
      if (_products.isEmpty) {
        _isAvailable = false;
        debugPrint('No products available - IAP functionality disabled');
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      _queryProductError = e.toString();
    }
  }

  /// Purchase a product
  Future<bool> purchaseProduct(ProductDetails productDetails) async {
    if (!_isAvailable) {
      debugPrint('IAP not available');
      return false;
    }

    if (_purchasePending) {
      debugPrint('Purchase already pending');
      return false;
    }

    try {
      _purchasePending = true;
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (!success) {
        _purchasePending = false;
        debugPrint('Failed to initiate purchase');
        return false;
      }

      debugPrint('Purchase initiated for ${productDetails.id}');
      return true;
    } catch (e) {
      _purchasePending = false;
      debugPrint('Error purchasing product: $e');
      return false;
    }
  }

  /// Restore previous purchases
  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('Restore purchases initiated');
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchaseUpdate(purchaseDetails);
    }
  }

  /// Handle individual purchase update
  void _handlePurchaseUpdate(PurchaseDetails purchaseDetails) {
    debugPrint('Purchase update: ${purchaseDetails.status} for ${purchaseDetails.productID}');

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        _purchasePending = true;
        break;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        _purchasePending = false;
        _handleSuccessfulPurchase(purchaseDetails);
        break;
      case PurchaseStatus.error:
        _purchasePending = false;
        debugPrint('Purchase error: ${purchaseDetails.error}');
        break;
      case PurchaseStatus.canceled:
        _purchasePending = false;
        debugPrint('Purchase canceled');
        break;
    }

    // Complete the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  /// Handle successful purchase
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    debugPrint('Purchase successful: ${purchaseDetails.productID}');
    
    // TODO: Verify purchase with your backend
    // TODO: Update user's premium status in your app
    // TODO: Save purchase details to local storage
    
    // For now, just log the purchase
    _logPurchase(purchaseDetails);
  }

  /// Log purchase details
  void _logPurchase(PurchaseDetails purchaseDetails) {
    debugPrint('=== PURCHASE DETAILS ===');
    debugPrint('Product ID: ${purchaseDetails.productID}');
    debugPrint('Purchase ID: ${purchaseDetails.purchaseID}');
    debugPrint('Transaction Date: ${purchaseDetails.transactionDate}');
    debugPrint('Verification Data: ${purchaseDetails.verificationData.localVerificationData}');
    debugPrint('========================');
  }

  /// Handle purchase stream done
  void _onPurchaseDone() {
    debugPrint('Purchase stream done');
  }

  /// Handle purchase stream error
  void _onPurchaseError(dynamic error) {
    debugPrint('Purchase stream error: $error');
    _purchasePending = false;
  }

  /// Get product by ID
  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    // TODO: Implement subscription status check
    // This would typically involve checking with your backend
    // or using the purchase details to determine if subscription is active
    return false;
  }

  /// Get subscription plan info
  Map<String, dynamic> getSubscriptionPlanInfo(String productId) {
    switch (productId) {
      case monthlyPremiumId:
        return {
          'name': 'Monthly Premium',
          'price': '9.99',
          'currency': 'USD',
          'interval': 'month',
          'features': [
            'Unlimited IELTS Speaking Practice',
            'Advanced AI Feedback',
            'Detailed Performance Analytics',
            'Personalized Study Plans',
            'Priority Support',
          ],
          'isPopular': false,
        };
      case yearlyPremiumId:
        return {
          'name': 'Yearly Premium',
          'price': '79.99',
          'currency': 'USD',
          'interval': 'year',
          'features': [
            'Unlimited IELTS Speaking Practice',
            'Advanced AI Feedback',
            'Detailed Performance Analytics',
            'Personalized Study Plans',
            'Priority Support',
            'Exclusive Content Access',
            'Offline Mode',
          ],
          'isPopular': true,
        };
      case lifetimePremiumId:
        return {
          'name': 'Lifetime Premium',
          'price': '199.99',
          'currency': 'USD',
          'interval': 'lifetime',
          'features': [
            'Unlimited IELTS Speaking Practice',
            'Advanced AI Feedback',
            'Detailed Performance Analytics',
            'Personalized Study Plans',
            'Priority Support',
            'Exclusive Content Access',
            'Offline Mode',
            'All Future Updates',
            'Premium Badge',
          ],
          'isPopular': false,
        };
      default:
        return {
          'name': 'Unknown Plan',
          'price': '0.00',
          'currency': 'USD',
          'interval': 'unknown',
          'features': [],
          'isPopular': false,
        };
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription.cancel();
  }
}

/// IAP Service Exception
class IAPServiceException implements Exception {
  final String message;
  IAPServiceException(this.message);
  
  @override
  String toString() => 'IAPServiceException: $message';
}
