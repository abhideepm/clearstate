import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/milestones.dart';
import '../../core/providers/navigation_provider.dart';
import '../../shared/widgets/noise_background.dart';
import '../../shared/widgets/scroll_reveal.dart';
import '../../shared/widgets/haptic_scroll_view.dart';
import '../timer/timer_provider.dart';
import '../timer/habit_provider.dart';
import '../timer/widgets/habit_dropdown.dart';
import 'widgets/milestone_card.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final ScrollController _scrollController = ScrollController();

  // Approximate height of each milestone card including padding
  static const double _milestoneCardHeight = 140.0;
  // Height of the header section
  static const double _headerHeight = 150.0;

  // Track the last scroll version we handled to avoid duplicate scrolls
  int _lastHandledScrollVersion = 0;
  bool _initialScrollDone = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we need to scroll on initial mount (when navigating from StatusIndicator)
    if (!_initialScrollDone) {
      _initialScrollDone = true;
      final currentScrollVersion = ref.read(scrollToCurrentMilestoneProvider);
      if (currentScrollVersion > 0 &&
          currentScrollVersion != _lastHandledScrollVersion) {
        _lastHandledScrollVersion = currentScrollVersion;
        _performScrollToCurrentMilestone();
      }
    }
  }

  void _performScrollToCurrentMilestone() {
    final durationAsync = ref.read(elapsedDurationProvider);
    final selectedHabit = ref.read(selectedHabitProvider);
    final milestones = RecoveryMilestones.getMilestonesForHabit(
      selectedHabit?.id ?? 'alcohol',
    );

    final duration = durationAsync.valueOrNull;
    if (duration != null) {
      final currentDays = duration.inDays;
      final currentMilestoneIndex = milestones.indexWhere(
        (m) =>
            m ==
            RecoveryMilestones.getCurrentMilestoneFromList(
              currentDays,
              milestones,
            ),
      );
      if (currentMilestoneIndex != -1) {
        _scrollToCurrentMilestone(currentMilestoneIndex);
      }
    }
  }

  void _scrollToCurrentMilestone(int currentMilestoneIndex) {
    // Calculate the scroll offset to bring the current milestone into view
    final targetOffset =
        _headerHeight + (currentMilestoneIndex * _milestoneCardHeight);

    // Add a small delay to allow the tab switch animation to complete
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) {
        return;
      }

      final currentScroll = _scrollController.offset;
      final viewportHeight = _scrollController.position.viewportDimension;

      // Calculate the visible range
      final visibleTop = currentScroll;
      final visibleBottom = currentScroll + viewportHeight;

      // Calculate the milestone's position (top and bottom of the card)
      final milestoneTop = targetOffset;
      final milestoneBottom = targetOffset + _milestoneCardHeight;

      // Only scroll if the milestone is not fully visible
      final isVisible =
          milestoneTop >= visibleTop && milestoneBottom <= visibleBottom;

      if (!isVisible) {
        _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final durationAsync = ref.watch(elapsedDurationProvider);
    final themeState = ref.watch(themeProvider);
    final selectedHabit = ref.watch(selectedHabitProvider);

    // Get habit-specific milestones (habit is always selected after onboarding)
    final milestones = RecoveryMilestones.getMilestonesForHabit(
      selectedHabit?.id ?? 'alcohol',
    );

    // Listen for scroll-to-current-milestone signals
    ref.listen<int>(scrollToCurrentMilestoneProvider, (previous, next) {
      if (next != _lastHandledScrollVersion) {
        _lastHandledScrollVersion = next;
        _performScrollToCurrentMilestone();
      }
    });

    return Scaffold(
      backgroundColor: themeState.background,
      body: DawnBackground(
        opacity: 0.025,
        child: SafeArea(
          child: durationAsync.when(
            data: (duration) {
              final currentDays = duration.inDays;

              return HapticCustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Timeline',
                                style: TrueStateTypography.h1.copyWith(
                                  color: themeState.textPrimary,
                                  fontSize: 28,
                                ),
                              ),
                              const HabitDropdown(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your recovery milestones',
                            style: TrueStateTypography.bodySecondary.copyWith(
                              color: themeState.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your body is healing',
                            style: TrueStateTypography.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final milestone = milestones[index];
                        final isUnlocked =
                            currentDays >= milestone.dayThreshold;
                        final isCurrent =
                            milestone ==
                            RecoveryMilestones.getCurrentMilestoneFromList(
                              currentDays,
                              milestones,
                            );
                        final isLast = index == milestones.length - 1;

                        return ScrollRevealItem(
                          delay: Duration(milliseconds: index * 50),
                          child: MilestoneCard(
                            milestone: milestone,
                            isUnlocked: isUnlocked,
                            isCurrent: isCurrent,
                            isLast: isLast,
                          ),
                        );
                      }, childCount: milestones.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: themeState.accent.value),
            ),
            error: (error, stack) =>
                const Center(child: Text('Error loading timeline')),
          ),
        ),
      ),
    );
  }
}
