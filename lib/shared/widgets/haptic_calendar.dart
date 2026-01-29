import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';

final calendarControllerProvider = StateProvider.family<DateTime, DateTime>(
  (ref, initialDate) => initialDate,
);

class HapticCalendar extends ConsumerStatefulWidget {
  final DateTime? selectedDate;
  final bool Function(DateTime date)? shouldDisableDate;
  final void Function(DateTime date) onDateSelected;
  final bool showModal;

  const HapticCalendar({
    super.key,
    this.selectedDate,
    this.shouldDisableDate,
    required this.onDateSelected,
    this.showModal = true,
  });

  @override
  ConsumerState<HapticCalendar> createState() => _HapticCalendarState();
}

class _HapticCalendarState extends ConsumerState<HapticCalendar> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  static const List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedDate ?? DateTime.now();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  void _goToPreviousMonth() {
    HapticService.light();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    HapticService.light();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _onDateTapped(DateTime date) {
    final shouldDisable = widget.shouldDisableDate?.call(date) ?? false;
    if (shouldDisable) return;
    HapticService.selection();
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected(date);
  }

  List<DateTime> _getCalendarDays() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );

    final days = <DateTime>[];
    final startWeekday = firstDayOfMonth.weekday % 7;

    for (int i = startWeekday - 1; i >= 0; i--) {
      days.add(firstDayOfMonth.subtract(Duration(days: i + 1)));
    }

    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, day));
    }

    final remainingDays = 42 - days.length;
    for (int i = 1; i <= remainingDays; i++) {
      days.add(lastDayOfMonth.add(Duration(days: i)));
    }

    return days;
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  bool _isCurrentMonth(DateTime date) {
    return date.month == _currentMonth.month;
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  Widget _buildCalendarContent() {
    final days = _getCalendarDays();
    final today = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: ClearStateColors.darkSurface,
        border: Border.all(color: ClearStateColors.borderDark, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthHeader(),
          const SizedBox(height: 16),
          _buildWeekdayHeader(),
          const SizedBox(height: 8),
          _buildCalendarGrid(days, today),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _goToPreviousMonth,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.chevron_left,
              color: ClearStateColors.textPrimaryDark,
              size: 24,
            ),
          ),
        ),
        Text(_formatMonthYear(_currentMonth), style: ClearStateTypography.h3),
        GestureDetector(
          onTap: _goToNextMonth,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.chevron_right,
              color: ClearStateColors.textPrimaryDark,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    return Row(
      children: _weekDays.map((day) {
        return Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                day,
                style: ClearStateTypography.caption.copyWith(
                  color: ClearStateColors.textSecondaryDark,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(List<DateTime> days, DateTime today) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: LayoutBuilder(
        key: ValueKey(_currentMonth),
        builder: (context, constraints) {
          final cellSize = (constraints.maxWidth - 16) / 7;

          return Wrap(
            spacing: 4,
            runSpacing: 4,
            children: days.map((date) {
              final isCurrentMonth = _isCurrentMonth(date);
              final isSelected =
                  _selectedDate.year == date.year &&
                  _selectedDate.month == date.month &&
                  _selectedDate.day == date.day;
              final isToday = _isToday(date);
              final isDisabled = widget.shouldDisableDate?.call(date) ?? false;

              return _CalendarCell(
                date: date,
                isCurrentMonth: isCurrentMonth,
                isSelected: isSelected,
                isToday: isToday,
                isDisabled: isDisabled,
                size: cellSize,
                accentColor: accentColor,
                onTap: () => _onDateTapped(date),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showModal) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black.withValues(alpha: 0.8),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: _buildCalendarContent(),
            ),
          ),
        ),
      );
    }

    return _buildCalendarContent();
  }
}

class _CalendarCell extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;
  final double size;
  final Color accentColor;
  final VoidCallback onTap;

  const _CalendarCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.size,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: ClearStateMotion.duration(const Duration(milliseconds: 150)),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected
            ? accentColor
            : isToday
            ? Colors.transparent
            : ClearStateColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: isToday && !isSelected
            ? Border.all(color: accentColor, width: 1.5)
            : Border.all(
                color: ClearStateColors.borderDark.withValues(alpha: 0.3),
                width: 1,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              date.day.toString(),
              style: isSelected
                  ? ClearStateTypography.body.copyWith(
                      color: ClearStateColors.darkBackground,
                      fontWeight: FontWeight.w600,
                    )
                  : isCurrentMonth
                  ? ClearStateTypography.body.copyWith(
                      color: isDisabled
                          ? ClearStateColors.textSecondaryDark.withValues(alpha: 0.5)
                          : ClearStateColors.textPrimaryDark,
                    )
                  : ClearStateTypography.body.copyWith(
                      color: ClearStateColors.textSecondaryDark.withValues(alpha: 0.5),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
