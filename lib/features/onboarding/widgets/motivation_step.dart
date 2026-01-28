import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/theme_provider.dart';
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
    {'label': 'For my health', 'icon': Icons.favorite_outline, 'emoji': '❤️'},
    {'label': 'For my family', 'icon': Icons.people_outline, 'emoji': '👨‍👩‍👧‍👦'},
    {'label': 'To save money', 'icon': Icons.savings_outlined, 'emoji': '💰'},
    {'label': 'For my future', 'icon': Icons.trending_up, 'emoji': '🚀'},
    {'label': 'To feel better', 'icon': Icons.sentiment_satisfied_alt, 'emoji': '😊'},
    {'label': 'Other', 'icon': Icons.edit_outlined, 'emoji': '✏️'},
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
    });
  }

  void _handleContinue() {
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
    final themeState = ref.watch(themeProvider);
    
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
              'Why are you\nquitting?',
              style: ClearStateTypography.h1.copyWith(
                fontSize: 32,
                height: 1.2,
                color: themeState.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your personal motivation for staying sober',
              style: ClearStateTypography.bodySecondary.copyWith(
                color: themeState.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _motivationChips.map((chip) {
                final label = chip['label'] as String;
                final emoji = chip['emoji'] as String;
                final isSelected = _selectedChips.contains(label);
                return _MotivationChip(
                  label: label,
                  emoji: emoji,
                  isSelected: isSelected,
                  themeState: themeState,
                  onTap: () => _toggleChip(label),
                );
              }).toList(),
            ),
            if (_showOtherTextField) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: themeState.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: themeState.border),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  maxLength: 200,
                  textAlign: TextAlign.center,
                  style: ClearStateTypography.body.copyWith(
                    color: themeState.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your reason...',
                    hintStyle: ClearStateTypography.body.copyWith(
                      color: themeState.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                    counterStyle: ClearStateTypography.caption.copyWith(
                      color: themeState.textMuted,
                    ),
                  ),
                ),
              ),
            ],
            const Spacer(),
            ModernButton(
              label: 'Start My Journey',
              onPressed: _handleContinue,
              type: ModernButtonType.primary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    label: 'Back',
                    onPressed: widget.onBack,
                    type: ModernButtonType.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _handleSkip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text(
                      'Skip',
                      style: ClearStateTypography.button.copyWith(
                        color: themeState.textMuted,
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

class _MotivationChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final ThemeState themeState;
  final VoidCallback onTap;

  const _MotivationChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.themeState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = themeState.accent.value;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : themeState.card,
          border: Border.all(
            color: isSelected ? accentColor : themeState.border,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: ClearStateTypography.body.copyWith(
                color: isSelected 
                    ? ClearStateColors.textPrimaryLight 
                    : themeState.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
