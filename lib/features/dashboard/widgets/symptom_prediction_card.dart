import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/symptom_intelligence_service.dart';
import '../../../core/services/sobriety_orchestrator.dart';
import '../../timer/timer_provider.dart';
import '../../../core/theme/theme_provider.dart';
import 'bento_card.dart';

class SymptomPredictionCard extends ConsumerStatefulWidget {
  const SymptomPredictionCard({super.key});

  @override
  ConsumerState<SymptomPredictionCard> createState() =>
      _SymptomPredictionCardState();
}

class _SymptomPredictionCardState extends ConsumerState<SymptomPredictionCard> {
  bool _showScience = false;

  @override
  Widget build(BuildContext context) {
    final orchestrator = ref.watch(sobrietyOrchestratorProvider);
    final profile = orchestrator.repository.getUserProfile();
    final habitId = profile?.selectedHabitIds.isNotEmpty == true
        ? profile!.selectedHabitIds.first
        : null;

    final durationAsync = ref.watch(elapsedDurationProvider);
    final hoursElapsed = durationAsync.maybeWhen(
      data: (d) => d.inHours,
      orElse: () => 0,
    );

    if (habitId == null) return const SizedBox.shrink();

    final intelligenceService = ref.watch(symptomIntelligenceServiceProvider);
    final milestone = intelligenceService.getActiveMilestone(
      habitId,
      hoursElapsed,
    );

    if (milestone == null) return const SizedBox.shrink();

    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accentValue;

    return BentoCard(
      backgroundColor: TrueStateColors.deepCharcoal,
      borderColor: themeState.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT TO EXPECT TODAY',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: TrueStateColors.textSecondaryDark,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  milestone.title.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: themeState.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  milestone.status.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: TrueStateColors.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            milestone.sensation,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => setState(() => _showScience = !_showScience),
            child: Row(
              children: [
                Icon(Icons.science_outlined, size: 16, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  _showScience ? 'HIDE INSIGHT' : 'SCIENCE INSIGHT',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showScience
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: accentColor,
                ),
              ],
            ),
          ),
          if (_showScience) ...[
            const SizedBox(height: 12),
            Text(
              milestone.science,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 13,
                color: TrueStateColors.textSecondaryDark,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
