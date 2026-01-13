import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../timer/timer_provider.dart';

class HeatmapCalendar extends ConsumerWidget {
  const HeatmapCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = ref.watch(sobrietyStartDateProvider);
    final now = DateTime.now();
    
    // Generate last 12 weeks of data
    final weeks = <List<DateTime?>>[];
    var currentDate = now.subtract(Duration(days: now.weekday % 7)); // Start of current week
    
    for (int w = 0; w < 12; w++) {
      final week = <DateTime?>[];
      for (int d = 0; d < 7; d++) {
        final date = currentDate.subtract(Duration(days: (11 - w) * 7 - d));
        if (date.isAfter(now)) {
          week.add(null); // Future date
        } else {
          week.add(date);
        }
      }
      weeks.add(week);
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClearStateColors.charcoal,
        border: Border.all(color: ClearStateColors.ash),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day labels
          Row(
            children: [
              const SizedBox(width: 28),
              ...['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
                Expanded(
                  child: Text(
                    day,
                    style: ClearStateTypography.caption.copyWith(
                      fontSize: 10,
                      color: ClearStateColors.smoke,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weeks
          ...weeks.asMap().entries.map((entry) {
            final weekIndex = entry.key;
            final week = entry.value;
            final showMonth = weekIndex == 0 || 
                (week.firstWhere((d) => d != null, orElse: () => now)?.day ?? 0) <= 7;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: showMonth ? Text(
                      _getMonthLabel(week),
                      style: ClearStateTypography.caption.copyWith(
                        fontSize: 10,
                        color: ClearStateColors.smoke,
                      ),
                    ) : null,
                  ),
                  ...week.map((date) {
                    if (date == null) {
                      return Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            margin: const EdgeInsets.all(1),
                            color: Colors.transparent,
                          ),
                        ),
                      );
                    }
                    
                    final isSober = startDate != null && 
                        (date.isAfter(startDate) || date.isAtSameMomentAs(startDate));
                    final isToday = date.year == now.year && 
                        date.month == now.month && 
                        date.day == now.day;
                    
                    return Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isSober 
                                ? ClearStateColors.sober.withValues(alpha: 0.8)
                                : ClearStateColors.ash.withValues(alpha: 0.3),
                            border: isToday 
                                ? Border.all(color: ClearStateColors.signal, width: 2)
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
  
  String _getMonthLabel(List<DateTime?> week) {
    final date = week.firstWhere((d) => d != null, orElse: () => DateTime.now());
    if (date == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }
}
