import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
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
  final Set<String> _selectedChips = {};

  static const List<Map<String, dynamic>> _motivationChips = [
    {'label': 'For my health', 'icon': Icons.favorite_outline},
    {'label': 'For my family', 'icon': Icons.people_outline},
    {'label': 'To save money', 'icon': Icons.savings_outlined},
    {'label': 'For my future', 'icon': Icons.trending_up},
    {'label': 'To feel better', 'icon': Icons.sentiment_satisfied_alt},
    {'label': 'Other', 'icon': Icons.edit_outlined},
  ];

  bool get _showOtherTextField => _selectedChips.contains('Other');

  void _toggleChip(String label) {
    HapticService.selection();
    setState(() {
      if (_selectedChips.contains(label)) {
        _selectedChips.remove(label);
      } else {
        _selectedChips.add(label);
      }
      _updateTextFromChips();
    });
  }

  void _updateTextFromChips() {
    // Don't auto-populate text field - let user write their own when "Other" is selected
    // The chip labels (excluding "Other") will be combined with custom text on submit
  }

  void _handleContinue() {
    // Combine selected chip labels (excluding "Other") with custom text
    final chipMotivations = _selectedChips
        .where((label) => label != 'Other')
        .toList();
    final customText = _controller.text.trim();

    String motivation;
    if (chipMotivations.isNotEmpty && customText.isNotEmpty) {
      motivation = '${chipMotivations.join('. ')}. $customText';
    } else if (chipMotivations.isNotEmpty) {
      motivation = chipMotivations.join('. ');
    } else {
      motivation = customText;
    }

    ref.read(onboardingProvider.notifier).setMotivation(motivation);
    widget.onNext();
  }

  void _handleSkip() {
    HapticService.light();
    ref.read(onboardingProvider.notifier).setMotivation('');
    widget.onNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            // Motivation chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _motivationChips.map((chip) {
                final label = chip['label'] as String;
                final icon = chip['icon'] as IconData;
                final isSelected = _selectedChips.contains(label);
                return GestureDetector(
                  onTap: () => _toggleChip(label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? ClearStateColors.signal : ClearStateColors.charcoal,
                      border: Border.all(
                        color: isSelected ? ClearStateColors.signal : ClearStateColors.ash,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: isSelected ? ClearStateColors.void_ : ClearStateColors.smoke,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: ClearStateTypography.caption.copyWith(
                            color: isSelected ? ClearStateColors.void_ : ClearStateColors.bone,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_showOtherTextField) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: ClearStateColors.charcoal,
                  border: Border.all(color: ClearStateColors.ash),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  maxLength: 200,
                  textAlign: TextAlign.center,
                  style: ClearStateTypography.body.copyWith(
                    color: ClearStateColors.bone,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your reason...',
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
            ],
            const Spacer(),
            BrutalistButton(
              label: 'START MY JOURNEY',
              onPressed: _handleContinue,
              type: BrutalistButtonType.primary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BrutalistButton(
                    label: 'BACK',
                    onPressed: widget.onBack,
                    type: BrutalistButtonType.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _handleSkip,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'SKIP',
                      style: ClearStateTypography.caption.copyWith(
                        color: ClearStateColors.smoke,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
