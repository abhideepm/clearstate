import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/services/subscription_service.dart';
import '../../data/models/subscription_status.dart';
import '../../data/repositories/i_sobriety_repository.dart';
import '../../data/repositories/sobriety_repository.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

final subscriptionStatusProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
      final service = ref.watch(subscriptionServiceProvider);
      final repository = ref.watch(sobrietyRepositoryProvider);
      return SubscriptionNotifier(service, repository);
    });

/// Computed provider for checking if user has premium access (trial OR subscription)
final hasPremiumAccessProvider = Provider<bool>((ref) {
  final status = ref.watch(subscriptionStatusProvider);
  final repository = ref.watch(sobrietyRepositoryProvider);
  final profile = repository.getUserProfile();

  // Check RevenueCat subscription first
  if (status.hasAccess) return true;

  // Fall back to local trial check
  return profile?.hasPremiumAccess ?? false;
});

/// Offerings provider for paywall UI
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  await service.initialize();
  return service.getOfferings();
});

class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  final SubscriptionService _service;
  final ISobrietyRepository _repository;

  SubscriptionNotifier(this._service, this._repository)
    : super(SubscriptionStatus.free()) {
    _init();
  }

  Future<void> _init() async {
    await _service.initialize();
    
    // Listen for real-time updates
    _service.addCustomerInfoUpdateListener((customerInfo) {
      if (mounted) {
        state = _service.mapCustomerInfoToStatus(customerInfo);
      }
    });

    await refreshStatus();
  }

  Future<void> refreshStatus() async {
    final remoteStatus = await _service.refreshStatus();

    // If no remote subscription, check local trial
    if (!remoteStatus.isPro) {
      final profile = _repository.getUserProfile();
      if (profile != null && profile.isInTrial) {
        final trialEnd = profile.trialStartDate!.add(const Duration(days: 7));
        state = SubscriptionStatus.trial(trialEndDate: trialEnd);
        return;
      }
    }

    state = remoteStatus;
  }

  Future<bool> purchaseMonthly() async {
    final success = await _service.purchaseMonthly();
    if (success) await refreshStatus();
    return success;
  }

  Future<bool> purchaseYearly() async {
    final success = await _service.purchaseYearly();
    if (success) await refreshStatus();
    return success;
  }

  Future<bool> purchaseLifetime() async {
    final success = await _service.purchaseLifetime();
    if (success) await refreshStatus();
    return success;
  }

  Future<void> restorePurchases() async {
    final status = await _service.restorePurchases();
    state = status;
  }

  /// Present RevenueCat native paywall and refresh status after
  Future<void> presentNativePaywall() async {
    await _service.presentPaywall();
    await refreshStatus();
  }

  /// Present paywall only if user doesn't have the entitlement
  Future<void> presentPaywallIfNeeded() async {
    await _service.presentPaywallIfNeeded();
    await refreshStatus();
  }

  /// Present Customer Center for subscription management
  Future<void> presentCustomerCenter() async {
    await _service.presentCustomerCenter();
    await refreshStatus();
  }
}
