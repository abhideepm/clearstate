import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

/// Settings box name for storing security preferences.
const String _settingsBoxName = 'settings';
const String _biometricEnabledKey = 'biometric_enabled';

/// State for security settings.
class SecurityState {
  final bool biometricEnabled;
  final bool isUnlocked;

  const SecurityState({this.biometricEnabled = false, this.isUnlocked = false});

  SecurityState copyWith({bool? biometricEnabled, bool? isUnlocked}) {
    return SecurityState(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

/// Notifier for managing security state and biometric authentication.
class SecurityNotifier extends StateNotifier<SecurityState> {
  final LocalAuthentication _localAuth;
  Box<dynamic>? _settingsBox;

  SecurityNotifier({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication(),
      super(const SecurityState()) {
    _init();
  }

  Future<void> _init() async {
    // Open settings box if not already open
    if (Hive.isBoxOpen(_settingsBoxName)) {
      _settingsBox = Hive.box(_settingsBoxName);
    } else {
      _settingsBox = await Hive.openBox(_settingsBoxName);
    }

    // Load saved biometric preference
    final biometricEnabled =
        _settingsBox?.get(_biometricEnabledKey, defaultValue: false) ?? false;

    state = state.copyWith(
      biometricEnabled: biometricEnabled,
      // If biometric is not enabled, consider app as unlocked
      isUnlocked: !biometricEnabled,
    );
  }

  /// Check if the device supports biometric authentication.
  Future<bool> canCheckBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics || canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types on the device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Enable biometric lock. Verifies biometric first.
  Future<bool> enableBiometric() async {
    final canCheck = await canCheckBiometrics();
    if (!canCheck) return false;

    // Authenticate to confirm user wants to enable
    final authenticated = await checkBiometric();
    if (!authenticated) return false;

    // Save preference
    await _settingsBox?.put(_biometricEnabledKey, true);
    state = state.copyWith(biometricEnabled: true);
    return true;
  }

  /// Disable biometric lock. Verifies biometric first.
  Future<bool> disableBiometric() async {
    // Authenticate to confirm user wants to disable
    final authenticated = await checkBiometric();
    if (!authenticated) return false;

    // Save preference
    await _settingsBox?.put(_biometricEnabledKey, false);
    state = state.copyWith(biometricEnabled: false, isUnlocked: true);
    return true;
  }

  /// Authenticate using biometrics. Returns true on success.
  Future<bool> checkBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access ClearState',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        state = state.copyWith(isUnlocked: true);
      }

      return authenticated;
    } catch (e) {
      return false;
    }
  }

  /// Lock the app (for when app goes to background).
  void lock() {
    if (state.biometricEnabled) {
      state = state.copyWith(isUnlocked: false);
    }
  }

  /// Toggle biometric setting.
  Future<bool> toggleBiometric() async {
    if (state.biometricEnabled) {
      return await disableBiometric();
    } else {
      return await enableBiometric();
    }
  }
}

/// Provider for security state and actions.
final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>(
  (ref) {
    return SecurityNotifier();
  },
);

/// Provider to check if biometrics are available on the device.
final canUseBiometricsProvider = FutureProvider<bool>((ref) async {
  final notifier = ref.read(securityProvider.notifier);
  return await notifier.canCheckBiometrics();
});

/// Provider for available biometric types.
final availableBiometricsProvider = FutureProvider<List<BiometricType>>((
  ref,
) async {
  final notifier = ref.read(securityProvider.notifier);
  return await notifier.getAvailableBiometrics();
});
