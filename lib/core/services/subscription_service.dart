import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../data/models/subscription_status.dart';

/// Product identifiers configured in App Store Connect / Google Play Console
class ProductIds {
  static const monthly = 'clearstate_pro_monthly';
  static const quarterly = 'clearstate_pro_quarterly';
  static const annual = 'clearstate_pro_annual';
  static const lifetime = 'clearstate_pro_lifetime';
}

/// RevenueCat subscription service
class SubscriptionService {
  static const _apiKeyAndroid = 'goog_placeholder_api_key';
  static const _apiKeyIos = 'appl_placeholder_api_key';
  static const _entitlementId = 'pro';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    final apiKey = Platform.isAndroid ? _apiKeyAndroid : _apiKeyIos;
    await Purchases.configure(PurchasesConfiguration(apiKey));
    _initialized = true;
  }

  /// Get current offerings from RevenueCat
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return null;
    }
  }

  /// Get subscription status from RevenueCat
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _mapCustomerInfoToStatus(customerInfo);
    } catch (e) {
      debugPrint('Error fetching subscription status: $e');
      return SubscriptionStatus.free();
    }
  }

  /// Purchase a specific package
  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('Error performing purchase: $e');
      return false;
    }
  }

  /// Purchase monthly subscription
  Future<bool> purchaseMonthly() async {
    final offerings = await getOfferings();
    final package = offerings?.current?.monthly;
    if (package == null) return false;
    return purchasePackage(package);
  }

  /// Purchase quarterly subscription (custom package)
  Future<bool> purchaseQuarterly() async {
    final offerings = await getOfferings();
    final packages = offerings?.current?.availablePackages;
    
    if (packages == null) return false;

    try {
      final package = packages.firstWhere(
        (p) => p.identifier == '\$rc_three_month' || 
               p.storeProduct.identifier == ProductIds.quarterly,
      );
      return purchasePackage(package);
    } catch (e) {
      debugPrint('Quarterly package not found: $e');
      return false;
    }
  }

  /// Purchase annual subscription
  Future<bool> purchaseAnnual() async {
    final offerings = await getOfferings();
    final package = offerings?.current?.annual;
    if (package == null) return false;
    return purchasePackage(package);
  }

  /// Purchase lifetime (non-consumable)
  Future<bool> purchaseLifetime() async {
    final offerings = await getOfferings();
    final package = offerings?.current?.lifetime;
    if (package == null) return false;
    return purchasePackage(package);
  }

  /// Restore previous purchases
  Future<SubscriptionStatus> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return _mapCustomerInfoToStatus(customerInfo);
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return SubscriptionStatus.free();
    }
  }

  SubscriptionStatus _mapCustomerInfoToStatus(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[_entitlementId];

    if (entitlement == null || !entitlement.isActive) {
      return SubscriptionStatus.free();
    }

    // Determine plan type from product identifier
    final productId = entitlement.productIdentifier;
    final planType = _getPlanTypeFromProductId(productId);

    return SubscriptionStatus(
      tier: SubscriptionTier.pro,
      isActive: true,
      isTrialing: false,
      planType: planType,
      expirationDate: entitlement.expirationDate != null
          ? DateTime.parse(entitlement.expirationDate!)
          : null,
    );
  }

  PlanType _getPlanTypeFromProductId(String productId) {
    if (productId.contains('monthly')) return PlanType.monthly;
    if (productId.contains('quarterly')) return PlanType.quarterly;
    if (productId.contains('annual')) return PlanType.annual;
    if (productId.contains('lifetime')) return PlanType.lifetime;
    return PlanType.none;
  }
}
