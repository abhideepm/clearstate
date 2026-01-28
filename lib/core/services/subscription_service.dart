import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../data/models/subscription_status.dart';

class SubscriptionService {
  static const _apiKeyAndroid = 'goog_placeholder_api_key';
  static const _apiKeyIos = 'appl_placeholder_api_key';
  static const _entitlementId = 'pro';

  Future<void> initialize() async {
    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    String apiKey = Platform.isAndroid ? _apiKeyAndroid : _apiKeyIos;

    // In a real app, you would use a configuration object
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return _mapCustomerInfoToStatus(customerInfo);
    } catch (e) {
      debugPrint('Error fetching subscription status: $e');
      return SubscriptionStatus.free();
    }
  }

  Future<bool> purchasePro() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        CustomerInfo customerInfo = await Purchases.purchasePackage(
          offerings.current!.availablePackages.first,
        );
        return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      }
    } catch (e) {
      debugPrint('Error performing purchase: $e');
    }
    return false;
  }

  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  SubscriptionStatus _mapCustomerInfoToStatus(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[_entitlementId];
    if (entitlement != null && entitlement.isActive) {
      return SubscriptionStatus(
        tier: SubscriptionTier.pro,
        isActive: true,
        expirationDate: entitlement.expirationDate != null
            ? DateTime.parse(entitlement.expirationDate!)
            : null,
      );
    }
    return SubscriptionStatus.free();
  }
}
