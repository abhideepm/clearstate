import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/sobriety_orchestrator.dart';
import '../../../core/constants/symptom_definitions.dart';
import '../../../data/repositories/sobriety_repository.dart';

/// Sheet for detailed daily logging of mood and symptoms.
class DailyLogInputSheet extends ConsumerStatefulWidget {
  const DailyLogInputSheet({super.key});

  @override
  ConsumerState<DailyLogInputSheet> createState() => _DailyLogInputSheetState();
}

class _DailyLogInputSheetState extends ConsumerState<DailyLogInputSheet> {
  double _mood = 3.0;
  final Set<String> _selectedSymptoms = {};
  bool _isLogging = false;

  final Map<int, String> _moodEmojis = {
    1: '😫',
    2: '😕',
    3: '😐',
    4: '🙂',
    5: '😎',
  };

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;
    final orchestrator = ref.watch(sobrietyOrchestratorProvider);
    final repo = orchestrator.repository;
    final profile = repo.getUserProfile();
    final habitId = profile?.selectedHabitIds.isNotEmpty == true
        ? profile!.selectedHabitIds.first
        : null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ClearStateColors.ash,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'DAILY CHECK-IN',
              style: ClearStateTypography.h2.copyWith(
                color: accentColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Mood Selector
            Text(
              'MOOD',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.smoke,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _moodEmojis[_mood.round()] ?? '😐',
                style: const TextStyle(fontSize: 48),
              ),
            ),
            Slider(
              value: _mood,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              activeColor: accentColor,
              inactiveColor: ClearStateColors.charcoal,
              onChanged: (value) {
                if (value != _mood) {
                  HapticService.light();
                  setState(() => _mood = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Symptoms Selector
            Text(
              'SYMPTOMS',
              style: ClearStateTypography.caption.copyWith(
                color: ClearStateColors.smoke,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SymptomDefinitions.all.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom.id);
                return FilterChip(
                  label: Text(symptom.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    HapticService.light();
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom.id);
                      } else {
                        _selectedSymptoms.remove(symptom.id);
                      }
                    });
                  },
                  backgroundColor: ClearStateColors.void_,
                  selectedColor: accentColor.withValues(alpha: 0.2),
                  checkmarkColor: accentColor,
                  labelStyle: ClearStateTypography.caption.copyWith(
                    color: isSelected ? accentColor : ClearStateColors.smoke,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                    side: BorderSide(
                      color: isSelected ? accentColor : ClearStateColors.ash,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Expected Today / Milestones
            if (habitId != null) ...[
              Text(
                'EXPECTED TODAY',
                style: ClearStateTypography.caption.copyWith(
                  color: ClearStateColors.smoke,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ClearStateColors.void_,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: ClearStateColors.ash),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, color: accentColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keep your streak alive. Focus on hydration and rest.',
                        style: ClearStateTypography.caption.copyWith(
                          color: ClearStateColors.bone,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Submit Button
            ElevatedButton(
              onPressed: _isLogging ? null : () => _handleConfirm(habitId),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
              ),
              child: _isLogging
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ClearStateColors.void_,
                      ),
                    )
                  : const Text('SUBMIT LOG'),
            ),
            const SizedBox(height: 12),

            // Cancel
            TextButton(
              onPressed: () {
                HapticService.light();
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: ClearStateTypography.button.copyWith(
                  color: ClearStateColors.smoke,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConfirm(String? habitId) async {
    if (habitId == null) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLogging = true);
    HapticService.medium();

    try {
      final orchestrator = ref.read(sobrietyOrchestratorProvider);
      await orchestrator.repository.logDay(
        date: DateTime.now(),
        habitId: habitId,
        isSober: true,
        moodScore: _mood.round(),
        symptoms: _selectedSymptoms.toList(),
      );

      HapticService.success();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily log saved!'),
            backgroundColor: ClearStateColors.charcoal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLogging = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ClearStateColors.relapse,
          ),
        );
      }
    }
  }
}
