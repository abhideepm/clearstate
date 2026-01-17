import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/haptic_calendar.dart';

class LastDrinkStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const LastDrinkStep({super.key, required this.onNext});

  @override
  ConsumerState<LastDrinkStep> createState() => _LastDrinkStepState();
}

class _LastDrinkStepState extends ConsumerState<LastDrinkStep> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    HapticService.light();
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: HapticCalendar(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            Navigator.of(context).pop();
            setState(() => _selectedDate = date);
            ref.read(onboardingProvider.notifier).setLastDrinkDate(date);
          },
          shouldDisableDate: (date) =>
              date.isAfter(DateTime.now()) ? true : false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'WHEN WAS YOUR\nLAST DRINK?',
            style: ClearStateTypography.h1.copyWith(fontSize: 32, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'This is where your journey begins',
            style: ClearStateTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _selectDate,
            child: AnimatedDateDisplay(selectedDate: _selectedDate),
          ),
          const SizedBox(height: 16),
          Text(
            'TAP TO CHANGE',
            style: ClearStateTypography.caption.copyWith(
              color: ClearStateColors.smoke,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(onboardingProvider.notifier)
                  .setLastDrinkDate(_selectedDate);
              widget.onNext();
            },
            child: const Text('CONTINUE'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class AnimatedDateDisplay extends StatefulWidget {
  final DateTime selectedDate;

  const AnimatedDateDisplay({super.key, required this.selectedDate});

  @override
  State<AnimatedDateDisplay> createState() => _AnimatedDateDisplayState();
}

class _AnimatedDateDisplayState extends State<AnimatedDateDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  DateTime _previousDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(AnimatedDateDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != _previousDate) {
      _previousDate = widget.selectedDate;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _monthName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: ClearStateColors.charcoal,
          border: Border.all(color: ClearStateColors.ash),
        ),
        child: Column(
          children: [
            Text(
              '${widget.selectedDate.day}',
              style: ClearStateTypography.timerDisplay.copyWith(fontSize: 64),
            ),
            Text(
              '${_monthName(widget.selectedDate.month)} ${widget.selectedDate.year}',
              style: ClearStateTypography.statLabel,
            ),
          ],
        ),
      ),
    );
  }
}
