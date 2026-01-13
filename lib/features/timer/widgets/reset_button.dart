import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';

class ResetButton extends StatefulWidget {
  final VoidCallback onReset;
  
  const ResetButton({super.key, required this.onReset});
  
  @override
  State<ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<ResetButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Heavy haptic feedback pattern for reset
        HapticService.buttonComplete();
        widget.onReset();
        _controller.reset();
        setState(() => _isPressed = false);
      }
    });
    
    // Add listener for progress-based haptics
    _controller.addListener(_onProgressUpdate);
  }
  
  // Provide subtle haptic feedback at progress milestones
  double _lastHapticProgress = 0;
  void _onProgressUpdate() {
    final progress = _controller.value;
    // Haptic at 33%, 66%, and 90%
    if (progress >= 0.33 && _lastHapticProgress < 0.33) {
      HapticService.light();
    } else if (progress >= 0.66 && _lastHapticProgress < 0.66) {
      HapticService.medium();
    } else if (progress >= 0.90 && _lastHapticProgress < 0.90) {
      HapticService.medium();
    }
    _lastHapticProgress = progress;
  }
  
  @override
  void dispose() {
    _controller.removeListener(_onProgressUpdate);
    _controller.dispose();
    super.dispose();
  }
  
  void _onPressStart() {
    if (_isPressed) return; // Already pressed
    setState(() => _isPressed = true);
    _lastHapticProgress = 0;
    HapticService.buttonDown();
    _controller.forward();
  }
  
  void _onPressEnd() {
    if (!_isPressed) return; // Not pressed
    if (_controller.status != AnimationStatus.completed) {
      _controller.reset();
      _lastHapticProgress = 0;
    }
    setState(() => _isPressed = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Use onTapDown/onTapUp for immediate response
      onTapDown: (_) => _onPressStart(),
      onTapUp: (_) => _onPressEnd(),
      onTapCancel: _onPressEnd,
      // Also support long press for accessibility
      onLongPressStart: (_) => _onPressStart(),
      onLongPressEnd: (_) => _onPressEnd(),
      onLongPressCancel: _onPressEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 200,
            height: 56,
            decoration: BoxDecoration(
              color: _isPressed 
                  ? ClearStateColors.relapse.withValues(alpha: 0.2)
                  : ClearStateColors.charcoal,
              border: Border.all(
                color: _isPressed ? ClearStateColors.relapse : ClearStateColors.ash,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Progress indicator
                if (_isPressed)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 200 * _controller.value,
                        color: ClearStateColors.relapse.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                // Label
                Center(
                  child: Text(
                    _isPressed ? 'HOLD 3 SEC...' : 'I SLIPPED UP',
                    style: ClearStateTypography.button.copyWith(
                      color: _isPressed ? ClearStateColors.relapse : ClearStateColors.smoke,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
