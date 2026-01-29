import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/symptom_intelligence_service.dart';
import '../../../core/services/sobriety_orchestrator.dart';
import '../../timer/timer_provider.dart';
import 'bento_card.dart';

class SymptomPredictionCard extends ConsumerStatefulWidget {
  const SymptomPredictionCard({super.key});

  @override
  ConsumerState<SymptomPredictionCard> createState() => _SymptomPredictionCardState();
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
    final milestone = intelligenceService.getActiveMilestone(habitId, hoursElapsed);

    if (milestone == null) return const SizedBox.shrink();

    return BentoCard(
      backgroundColor: ClearStateColors.oledBlack,
      borderColor: ClearStateColors.borderDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT TO EXPECT TODAY',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ClearStateColors.textSecondaryDark,
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
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ClearStateColors.acidGreen,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: ClearStateColors.borderDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  milestone.status.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ClearStateColors.textSecondaryDark,
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
                const Icon(
                  Icons.science_outlined,
                  size: 16,
                  color: ClearStateColors.hyperViolet,
                ),
                const SizedBox(width: 8),
                Text(
                  _showScience ? 'HIDE INSIGHT' : 'SCIENCE INSIGHT',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ClearStateColors.hyperViolet,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showScience ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: ClearStateColors.hyperViolet,
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
                color: ClearStateColors.textSecondaryDark,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
