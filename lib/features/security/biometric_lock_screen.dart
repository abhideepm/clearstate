import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/services/haptic_service.dart';
import '../../shared/widgets/noise_background.dart';
import 'security_provider.dart';

/// Full-screen biometric lock screen.
/// Displays app branding and unlock button for biometric authentication.
class BiometricLockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;

  const BiometricLockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Attempt authentication on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);
    await HapticService.light();

    try {
      final success = await ref
          .read(securityProvider.notifier)
          .checkBiometric();

      if (success) {
        await HapticService.success();
        widget.onUnlocked();
      } else {
        await HapticService.error();
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoiseBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // App icon/logo
                _buildLogo(),
                const SizedBox(height: 32),
                // Title
                Text(
                  'CLEARSTATE',
                  style: ClearStateTypography.timerLabel.copyWith(
                    fontSize: 14,
                    letterSpacing: 4,
                    color: ClearStateColors.smoke,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Unlock', style: ClearStateTypography.h1),
                const Spacer(flex: 2),
                // Unlock button
                _buildUnlockButton(),
                const SizedBox(height: 16),
                // Helper text
                Text(
                  'Tap to authenticate',
                  style: ClearStateTypography.caption,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: ClearStateColors.void_,
        border: Border.all(color: ClearStateColors.ash, width: 1),
      ),
      child: Stack(
        children: [
          // Signal accent bar at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 18,
            child: Container(color: ClearStateColors.signal),
          ),
          // CS letters
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CS',
                  style: ClearStateTypography.timerDisplay.copyWith(
                    fontSize: 54,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'CLEAR',
                  style: ClearStateTypography.timerLabel.copyWith(
                    fontSize: 10,
                    letterSpacing: 2.4,
                    color: ClearStateColors.smoke,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockButton() {
    return GestureDetector(
      onTap: _isAuthenticating ? null : _authenticate,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: ClearStateColors.charcoal,
          border: Border.all(color: ClearStateColors.signal, width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: _isAuthenticating
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ClearStateColors.signal,
                  ),
                )
              : const Icon(
                  Icons.fingerprint,
                  size: 40,
                  color: ClearStateColors.signal,
                ),
        ),
      ),
    );
  }
}
