import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';

/// An expandable section showing how to add widgets on iOS and Android.
///
/// Provides step-by-step instructions with platform-specific guidance.
class WidgetInstallGuide extends StatefulWidget {
  const WidgetInstallGuide({super.key});

  @override
  State<WidgetInstallGuide> createState() => _WidgetInstallGuideState();
}

class _WidgetInstallGuideState extends State<WidgetInstallGuide> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ClearStateColors.charcoal,
        border: Border.all(color: ClearStateColors.ash, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        children: [
          // Header (always visible)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticService.light();
                setState(() => _isExpanded = !_isExpanded);
              },
              borderRadius: BorderRadius.circular(2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ClearStateColors.signal.withAlpha(
                          (0.15 * 255).round(),
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: ClearStateColors.signal,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to Add Widgets',
                            style: ClearStateTypography.body.copyWith(
                              color: ClearStateColors.bone,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Step-by-step instructions',
                            style: ClearStateTypography.caption.copyWith(
                              color: ClearStateColors.smoke,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.expand_more,
                        color: ClearStateColors.ash,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: ClearStateColors.ash),
          const SizedBox(height: 16),

          // Platform tabs
          if (Platform.isIOS)
            _IOSInstructions()
          else if (Platform.isAndroid)
            _AndroidInstructions()
          else
            _BothPlatformInstructions(),
        ],
      ),
    );
  }
}

/// iOS-specific widget installation instructions.
class _IOSInstructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlatformHeader(platform: 'iOS', icon: Icons.apple),
        const SizedBox(height: 16),
        const _InstructionStep(
          number: 1,
          text: 'Long-press on your home screen until apps start jiggling',
        ),
        const _InstructionStep(
          number: 2,
          text: 'Tap the + button in the top-left corner',
        ),
        const _InstructionStep(
          number: 3,
          text: 'Search for "ClearState" in the widget gallery',
        ),
        const _InstructionStep(
          number: 4,
          text: 'Choose a widget size and tap "Add Widget"',
        ),
        const _InstructionStep(
          number: 5,
          text: 'Drag the widget to your preferred location',
        ),
        const _InstructionStep(
          number: 6,
          text: 'Tap "Done" to save your changes',
        ),
      ],
    );
  }
}

/// Android-specific widget installation instructions.
class _AndroidInstructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlatformHeader(platform: 'Android', icon: Icons.android),
        const SizedBox(height: 16),
        const _InstructionStep(
          number: 1,
          text: 'Long-press on an empty area of your home screen',
        ),
        const _InstructionStep(
          number: 2,
          text: 'Tap "Widgets" from the menu that appears',
        ),
        const _InstructionStep(
          number: 3,
          text: 'Scroll down to find "ClearState" widgets',
        ),
        const _InstructionStep(
          number: 4,
          text:
              'Long-press the widget you want and drag it to your home screen',
        ),
        const _InstructionStep(number: 5, text: 'Release to place the widget'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ClearStateColors.signal.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: ClearStateColors.signal.withAlpha((0.3 * 255).round()),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: ClearStateColors.signal,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'On Android 8.0+, you can also use the "Add to Home Screen" button in the widget settings above.',
                  style: ClearStateTypography.caption.copyWith(
                    color: ClearStateColors.bone,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Instructions for both platforms (shown in simulators/unsupported platforms).
class _BothPlatformInstructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IOSInstructions(),
        const SizedBox(height: 24),
        Container(height: 1, color: ClearStateColors.ash),
        const SizedBox(height: 24),
        _AndroidInstructions(),
      ],
    );
  }
}

/// Platform header with icon.
class _PlatformHeader extends StatelessWidget {
  final String platform;
  final IconData icon;

  const _PlatformHeader({required this.platform, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ClearStateColors.smoke, size: 18),
        const SizedBox(width: 8),
        Text(
          platform.toUpperCase(),
          style: ClearStateTypography.caption.copyWith(
            color: ClearStateColors.smoke,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

/// A single instruction step with number.
class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ClearStateColors.ash,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: Text(
                '$number',
                style: ClearStateTypography.caption.copyWith(
                  color: ClearStateColors.bone,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: ClearStateTypography.body.copyWith(
                  color: ClearStateColors.bone,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
