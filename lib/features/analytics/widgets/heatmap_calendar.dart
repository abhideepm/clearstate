import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../timer/timer_provider.dart';

class HeatmapCalendar extends ConsumerWidget {
  const HeatmapCalendar({super.key});

  // Fixed cell dimensions for compact view
  static const double _cellSize = 14.0;
  static const double _cellSpacing = 3.0;
  static const int _weeksToShow = 26; // 6 months of history

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = ref.watch(sobrietyStartDateProvider);
    final themeState = ref.watch(themeProvider);
    final now = DateTime.now();

    // Generate weeks data (most recent on the right)
    final weeks = _generateWeeksData(now, _weeksToShow);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClearStateColors.charcoal,
        border: Border.all(color: ClearStateColors.ash),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrollable calendar grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // Start scrolled to the right (most recent)
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day labels column (fixed on left conceptually, but scrolls with content)
                _buildDayLabels(),
                const SizedBox(width: 8),
                // Weeks grid
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month labels row
                    _buildMonthLabels(weeks),
                    const SizedBox(height: 4),
                    // Calendar grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: weeks.asMap().entries.map((entry) {
                        final week = entry.value;
                        return _buildWeekColumn(
                          week,
                          startDate,
                          now,
                          themeState,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<List<DateTime?>> _generateWeeksData(DateTime now, int weeksCount) {
    final weeks = <List<DateTime?>>[];

    // Find the start of the current week (Sunday)
    final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));

    for (int w = weeksCount - 1; w >= 0; w--) {
      final week = <DateTime?>[];
      for (int d = 0; d < 7; d++) {
        final date = currentWeekStart.subtract(Duration(days: w * 7 - d));
        if (date.isAfter(now)) {
          week.add(null); // Future date
        } else {
          week.add(date);
        }
      }
      weeks.add(week);
    }

    return weeks;
  }

  Widget _buildDayLabels() {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Column(
      children: [
        // Empty space for month label row
        SizedBox(height: _cellSize + 4),
        // Day labels
        ...days.map(
          (day) => SizedBox(
            width: 16,
            height: _cellSize + _cellSpacing,
            child: Center(
              child: Text(
                day,
                style: ClearStateTypography.caption.copyWith(
                  fontSize: 9,
                  color: ClearStateColors.smoke,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthLabels(List<List<DateTime?>> weeks) {
    final labels = <Widget>[];
    String? lastMonth;

    for (int i = 0; i < weeks.length; i++) {
      final week = weeks[i];
      final firstValidDate = week.firstWhere(
        (d) => d != null,
        orElse: () => null,
      );

      String? monthLabel;
      if (firstValidDate != null) {
        final monthStr = _getMonthAbbr(firstValidDate.month);
        // Show label at the start of each month
        if (lastMonth != monthStr && firstValidDate.day <= 7) {
          monthLabel = monthStr;
          lastMonth = monthStr;
        }
      }

      labels.add(
        SizedBox(
          width: _cellSize + _cellSpacing,
          height: _cellSize,
          child: monthLabel != null
              ? Text(
                  monthLabel,
                  style: ClearStateTypography.caption.copyWith(
                    fontSize: 9,
                    color: ClearStateColors.smoke,
                  ),
                )
              : null,
        ),
      );
    }

    return Row(children: labels);
  }

  Widget _buildWeekColumn(
    List<DateTime?> week,
    DateTime? startDate,
    DateTime now,
    ThemeState theme,
  ) {
    return Column(
      children: week.map((date) {
        return Container(
          width: _cellSize,
          height: _cellSize,
          margin: EdgeInsets.all(_cellSpacing / 2),
          decoration: BoxDecoration(
            color: _getCellColor(date, startDate, now, theme),
            borderRadius: BorderRadius.circular(2),
            border: _isToday(date, now)
                ? Border.all(color: theme.accent.value, width: 1.5)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Color _getCellColor(
    DateTime? date,
    DateTime? startDate,
    DateTime now,
    ThemeState theme,
  ) {
    if (date == null) {
      return Colors.transparent;
    }

    final isSober =
        startDate != null &&
        (date.isAfter(startDate) ||
            (date.year == startDate.year &&
                date.month == startDate.month &&
                date.day == startDate.day));

    if (isSober) {
      return theme.accent.value.withValues(alpha: 0.8);
    }

    return theme.accent.complementary.withValues(alpha: 0.3);
  }

  bool _isToday(DateTime? date, DateTime now) {
    if (date == null) return false;
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
