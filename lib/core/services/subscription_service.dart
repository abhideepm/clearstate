import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../data/models/subscription_status.dart';

/// Product identifiers configured in App Store Connect / Google Play Console
class ProductIds {
  static const monthly = 'monthly';
  static const yearly = 'yearly';
  static const lifetime = 'lifetime';
}

/// RevenueCat subscription service
class SubscriptionService {
  static const _apiKey = 'test_vrFuaaVwnGePwdtgQujHRacWWeE';
  static const _entitlementId = 'truestate_pro';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    await Purchases.configure(PurchasesConfiguration(_apiKey));
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
      final params = PurchaseParams.package(package);
      final purchaseResult = await Purchases.purchase(params);
      final customerInfo = purchaseResult.customerInfo;
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

  /// Purchase yearly subscription
  Future<bool> purchaseYearly() async {
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
    if (productId.contains('yearly') || productId.contains('annual')) {
      return PlanType.yearly;
    }
    if (productId.contains('lifetime')) return PlanType.lifetime;
    return PlanType.none;
  }

  /// Present RevenueCat native paywall
  Future<PaywallResult> presentPaywall() async {
    try {
      return await RevenueCatUI.presentPaywall();
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
      return PaywallResult.error;
    }
  }

  /// Present paywall only if user doesn't have the entitlement
  Future<PaywallResult> presentPaywallIfNeeded() async {
    try {
      return await RevenueCatUI.presentPaywallIfNeeded(_entitlementId);
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
      return PaywallResult.error;
    }
  }

  /// Present RevenueCat Customer Center for subscription management
  Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('Error presenting customer center: $e');
    }
  }

  /// Get entitlement ID for external use
  String get entitlementId => _entitlementId;
}
