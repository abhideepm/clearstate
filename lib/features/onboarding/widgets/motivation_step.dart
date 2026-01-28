import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/brutalist_button.dart';

class MotivationStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const MotivationStep({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<MotivationStep> createState() => _MotivationStepState();
}

class _MotivationStepState extends ConsumerState<MotivationStep> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'WHY ARE YOU\nQUITTING?',
            style: ClearStateTypography.h1.copyWith(fontSize: 32, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your personal motivation for staying sober',
            style: ClearStateTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            decoration: BoxDecoration(
              color: ClearStateColors.charcoal,
              border: Border.all(color: ClearStateColors.ash),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 5,
              maxLength: 200,
              textAlign: TextAlign.center,
              style: ClearStateTypography.body.copyWith(
                color: ClearStateColors.bone,
              ),
              decoration: InputDecoration(
                hintText: 'For my health, family, future...',
                hintStyle: ClearStateTypography.body.copyWith(
                  color: ClearStateColors.smoke,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: ClearStateTypography.caption.copyWith(
                  color: ClearStateColors.smoke,
                ),
              ),
            ),
          ),
          const Spacer(),
          BrutalistButton(
            label: 'START MY JOURNEY',
            onPressed: () {
              ref
                  .read(onboardingProvider.notifier)
                  .setMotivation(_controller.text.trim());
              widget.onNext();
            },
            type: BrutalistButtonType.primary,
          ),
          const SizedBox(height: 12),
          BrutalistButton(
            label: 'BACK',
            onPressed: widget.onBack,
            type: BrutalistButtonType.secondary,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
