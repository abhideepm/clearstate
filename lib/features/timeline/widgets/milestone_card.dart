import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/milestones.dart';

class MilestoneCard extends StatelessWidget {
  final RecoveryMilestone milestone;
  final bool isUnlocked;
  final bool isCurrent;
  final bool isLast;

  const MilestoneCard({
    super.key,
    required this.milestone,
    required this.isUnlocked,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? ClearStateColors.signal
                        : isUnlocked
                        ? ClearStateColors.sober
                        : ClearStateColors.ash,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: ClearStateColors.signal, width: 3)
                        : null,
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isUnlocked
                          ? ClearStateColors.sober.withValues(alpha: 0.3)
                          : ClearStateColors.ash,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? ClearStateColors.charcoal
                      : Colors.transparent,
                  border: Border.all(
                    color: isCurrent
                        ? ClearStateColors.signal
                        : isUnlocked
                        ? ClearStateColors.ash
                        : ClearStateColors.ash.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          milestone.title.toUpperCase(),
                          style: ClearStateTypography.caption.copyWith(
                            color: isCurrent
                                ? ClearStateColors.signal
                                : isUnlocked
                                ? ClearStateColors.bone
                                : ClearStateColors.smoke,
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(),
                        if (isUnlocked && !isCurrent)
                          Icon(
                            Icons.check,
                            size: 16,
                            color: ClearStateColors.sober,
                          ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            color: ClearStateColors.signal,
                            child: Text(
                              'NOW',
                              style: ClearStateTypography.caption.copyWith(
                                color: ClearStateColors.void_,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      milestone.status,
                      style: ClearStateTypography.h3.copyWith(
                        color: isUnlocked
                            ? ClearStateColors.bone
                            : ClearStateColors.smoke,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      milestone.description,
                      style: ClearStateTypography.body.copyWith(
                        color: isUnlocked
                            ? ClearStateColors.smoke
                            : ClearStateColors.smoke.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
