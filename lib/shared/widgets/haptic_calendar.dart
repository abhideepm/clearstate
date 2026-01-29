import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
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
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    return Container(
      decoration: BoxDecoration(
        color: TrueStateColors.darkSurface,
        border: Border.all(color: TrueStateColors.borderDark, width: 1),
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
          _buildCalendarGrid(days, today, accentColor),
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
              color: TrueStateColors.textPrimaryDark,
              size: 24,
            ),
          ),
        ),
        Text(_formatMonthYear(_currentMonth), style: TrueStateTypography.h3),
        GestureDetector(
          onTap: _goToNextMonth,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.chevron_right,
              color: TrueStateColors.textPrimaryDark,
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
                style: TrueStateTypography.caption.copyWith(
                  color: TrueStateColors.textSecondaryDark,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(List<DateTime> days, DateTime today, Color accentColor) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: GridView.builder(
        key: ValueKey(_currentMonth),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
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
            accentColor: accentColor,
            onTap: () => _onDateTapped(date),
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
  final Color accentColor;
  final VoidCallback onTap;

  const _CalendarCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = isSelected
        ? TrueStateTypography.body.copyWith(
            color: TrueStateColors.darkBackground,
            fontWeight: FontWeight.w600,
          )
        : isCurrentMonth
            ? TrueStateTypography.body.copyWith(
                color: isDisabled
                    ? TrueStateColors.textSecondaryDark.withValues(alpha: 0.5)
                    : TrueStateColors.textPrimaryDark,
              )
            : TrueStateTypography.body.copyWith(
                color: TrueStateColors.textSecondaryDark.withValues(alpha: 0.5),
              );

    final decoration = BoxDecoration(
      color: isSelected
          ? accentColor
          : isToday
              ? Colors.transparent
              : TrueStateColors.darkSurface,
      borderRadius: BorderRadius.circular(12),
      border: isToday && !isSelected
          ? Border.all(color: accentColor, width: 1.5)
          : Border.all(
              color: TrueStateColors.borderDark.withValues(alpha: 0.3),
              width: 1,
            ),
    );

    // Only animate selected cells for performance
    if (isSelected) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: _buildCellContent(decoration, textStyle),
      );
    }

    return _buildCellContent(decoration, textStyle);
  }

  Widget _buildCellContent(BoxDecoration decoration, TextStyle textStyle) {
    return Container(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(date.day.toString(), style: textStyle),
          ),
        ),
      ),
    );
  }
}
