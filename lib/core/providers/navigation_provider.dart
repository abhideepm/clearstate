import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the current navigation tab index.
/// 0 = Timer, 1 = Timeline, 2 = Stats, 3 = Settings
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

/// Provider to signal that the timeline should scroll to the current milestone.
/// Incremented each time a scroll is requested.
final scrollToCurrentMilestoneProvider = StateProvider<int>((ref) => 0);
