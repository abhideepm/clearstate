import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../shared/widgets/noise_background.dart';
import '../../shared/widgets/sunrise_logo.dart';
import 'security_provider.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;

  const BiometricLockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen>
    with TickerProviderStateMixin {
  bool _isAuthenticating = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool get _isIOS => Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    // Auto-authenticate on app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
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
        _shakeController
          ..reset()
          ..forward();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    return Scaffold(
      body: NoiseBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 0),
                  duration: const Duration(milliseconds: 300),
                  child: SunriseLogo(
                    size: 100,
                    accentColor: accentColor,
                    showLabel: false,
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 300),
                  child: Text('Unlock', style: ClearStateTypography.h1),
                ),
                const Spacer(flex: 2),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 450),
                  duration: const Duration(milliseconds: 300),
                  child: _buildUnlockButton(accentColor),
                ),
                const SizedBox(height: 16),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _isIOS ? 'Authenticating...' : 'Tap to authenticate',
                    style: ClearStateTypography.caption,
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockButton(Color accentColor) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _isAuthenticating ? null : _authenticate,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: ClearStateColors.charcoal,
            border: Border.all(color: accentColor, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: _isAuthenticating
                ? SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accentColor,
                    ),
                  )
                : Icon(
                    _isIOS ? Icons.face : Icons.fingerprint,
                    size: 48,
                    color: accentColor,
                  ),
          ),
        ),
      ),
    );
  }
}

class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _slideAnimation = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
