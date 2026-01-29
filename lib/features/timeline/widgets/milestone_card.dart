import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/milestones.dart';

class MilestoneCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final accentValue = themeState.accentValue;
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
                        ? accentValue
                        : isUnlocked
                        ? TrueStateColors.success
                        : themeState.border,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: accentValue, width: 3)
                        : null,
                    boxShadow: isCurrent ? [
                      BoxShadow(
                        color: accentValue.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isUnlocked
                              ? [
                                  TrueStateColors.success.withValues(alpha: 0.5),
                                  TrueStateColors.success.withValues(alpha: 0.2),
                                ]
                              : [
                                  themeState.border,
                                  themeState.border.withValues(alpha: 0.5),
                                ],
                        ),
                      ),
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
                      ? themeState.surface
                      : themeState.card.withValues(alpha: 0.3),
                  border: Border.all(
                    color: isCurrent
                        ? accentValue.withValues(alpha: 0.5)
                        : isUnlocked
                        ? themeState.border.withValues(alpha: 0.5)
                        : themeState.border.withValues(alpha: 0.3),
                    width: isCurrent ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isCurrent ? [
                    BoxShadow(
                      color: accentValue.withValues(alpha: 0.1),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ] : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          milestone.title.toUpperCase(),
                          style: TrueStateTypography.caption.copyWith(
                            color: isCurrent
                                ? accentValue
                                : isUnlocked
                                ? themeState.textPrimary
                                : themeState.textSecondary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (isUnlocked && !isCurrent)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: TrueStateColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: TrueStateColors.success,
                            ),
                          ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentValue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'NOW',
                              style: TrueStateTypography.caption.copyWith(
                              color: themeState.background,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      milestone.status,
                      style: TrueStateTypography.h3.copyWith(
                        color: isUnlocked
                            ? themeState.textPrimary
                            : themeState.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      milestone.description,
                      style: TrueStateTypography.body.copyWith(
                        color: isUnlocked
                            ? themeState.textSecondary
                            : themeState.textSecondary.withValues(alpha: 0.5),
                        fontSize: 14,
                        height: 1.5,
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
