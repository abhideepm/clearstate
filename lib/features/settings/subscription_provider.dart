import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/subscription_service.dart';
import '../../data/models/subscription_status.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

final subscriptionStatusProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionNotifier(service);
});

class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  final SubscriptionService _service;

  SubscriptionNotifier(this._service) : super(SubscriptionStatus.free()) {
    _init();
  }

  Future<void> _init() async {
    await _service.initialize();
    await refreshStatus();
  }

  Future<void> refreshStatus() async {
    state = await _service.getSubscriptionStatus();
  }

  Future<bool> purchasePro() async {
    final success = await _service.purchasePro();
    if (success) {
      await refreshStatus();
    }
    return success;
  }

  Future<void> restorePurchases() async {
    await _service.restorePurchases();
    await refreshStatus();
  }
}
