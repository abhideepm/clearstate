import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/haptic_calendar.dart';
import '../../../shared/widgets/brutalist_button.dart';

class StartDateStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StartDateStep({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<StartDateStep> createState() => _StartDateStepState();
}

class _StartDateStepState extends ConsumerState<StartDateStep> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    HapticService.light();
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: ClearStateColors.charcoal,
            border: Border.all(color: ClearStateColors.ash, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HapticCalendar(
                selectedDate: _selectedDate,
                showModal: false, // Don't use internal modal wrapper
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                },
                shouldDisableDate: (date) =>
                    date.isAfter(DateTime.now()) ? true : false,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(onboardingProvider.notifier)
                          .setLastDrinkDate(_selectedDate);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ClearStateColors.signal,
                      foregroundColor: ClearStateColors.void_,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    child: const Text('CONFIRM DATE'),
                  ),
                ),
              ),
            ],
          ),
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
            'WHEN DID YOU\nSTART?',
            style: ClearStateTypography.h1.copyWith(fontSize: 32, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'The first day of your new chapter',
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
          BrutalistButton(
            label: 'CONTINUE',
            onPressed: () {
              ref
                  .read(onboardingProvider.notifier)
                  .setLastDrinkDate(_selectedDate);
              widget.onNext();
            },
            type: BrutalistButtonType.primary,
          ),
          const SizedBox(height: 12),
          BrutalistButton(
            label: 'BACK',
            onPressed: widget.onBack,
            type: BrutalistButtonType.secondary,
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
