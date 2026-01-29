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
                        ? ClearStateColors.lavender
                        : isUnlocked
                        ? ClearStateColors.success
                        : ClearStateColors.borderDark,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: ClearStateColors.lavender, width: 3)
                        : null,
                    boxShadow: isCurrent ? [
                      BoxShadow(
                        color: ClearStateColors.lavender.withValues(alpha: 0.4),
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
                                  ClearStateColors.success.withValues(alpha: 0.5),
                                  ClearStateColors.success.withValues(alpha: 0.2),
                                ]
                              : [
                                  ClearStateColors.borderDark,
                                  ClearStateColors.borderDark.withValues(alpha: 0.5),
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
                      ? ClearStateColors.darkSurface
                      : ClearStateColors.darkCard.withValues(alpha: 0.3),
                  border: Border.all(
                    color: isCurrent
                        ? ClearStateColors.lavender.withValues(alpha: 0.5)
                        : isUnlocked
                        ? ClearStateColors.borderDark.withValues(alpha: 0.5)
                        : ClearStateColors.borderDark.withValues(alpha: 0.3),
                    width: isCurrent ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isCurrent ? [
                    BoxShadow(
                      color: ClearStateColors.lavender.withValues(alpha: 0.1),
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
                          style: ClearStateTypography.caption.copyWith(
                            color: isCurrent
                                ? ClearStateColors.lavender
                                : isUnlocked
                                ? ClearStateColors.textPrimaryDark
                                : ClearStateColors.textSecondaryDark,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (isUnlocked && !isCurrent)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: ClearStateColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: ClearStateColors.success,
                            ),
                          ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ClearStateColors.lavender,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'NOW',
                              style: ClearStateTypography.caption.copyWith(
                                color: ClearStateColors.darkBackground,
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
                      style: ClearStateTypography.h3.copyWith(
                        color: isUnlocked
                            ? ClearStateColors.textPrimaryDark
                            : ClearStateColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      milestone.description,
                      style: ClearStateTypography.body.copyWith(
                        color: isUnlocked
                            ? ClearStateColors.textSecondaryDark
                            : ClearStateColors.textSecondaryDark.withValues(alpha: 0.5),
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
