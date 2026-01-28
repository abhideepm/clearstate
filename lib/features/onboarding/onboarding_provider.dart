import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/habit_template.dart';

class OnboardingState {
  final DateTime? lastDrinkDate;
  final String drinkType;
  final String motivation;
  final int currentStep;
  final List<HabitTemplate> selectedHabits;

  const OnboardingState({
    this.lastDrinkDate,
    this.drinkType = '',
    this.motivation = '',
    this.currentStep = 0,
    this.selectedHabits = const [],
  });

  OnboardingState copyWith({
    DateTime? lastDrinkDate,
    String? drinkType,
    String? motivation,
    int? currentStep,
    List<HabitTemplate>? selectedHabits,
  }) {
    return OnboardingState(
      lastDrinkDate: lastDrinkDate ?? this.lastDrinkDate,
      drinkType: drinkType ?? this.drinkType,
      motivation: motivation ?? this.motivation,
      currentStep: currentStep ?? this.currentStep,
      selectedHabits: selectedHabits ?? this.selectedHabits,
    );
  }

  /// Whether at least one habit is selected.
  bool get hasSelectedHabits => selectedHabits.isNotEmpty;

  /// Get selected habit IDs for repository operations.
  List<String> get selectedHabitIds =>
      selectedHabits.map((h) => h.id).toList();

  /// Whether alcohol is among the selected habits.
  bool get hasAlcoholSelected =>
      selectedHabits.any((h) => h.id == 'alcohol');

  /// Total onboarding steps: 4 if alcohol selected (Stack -> Date -> DrinkType -> Motivation), 3 otherwise.
  int get totalSteps => hasAlcoholSelected ? 4 : 3;

  /// Comma-separated display names of selected habits (e.g., "Alcohol, Weed").
  String get habitNamesDisplay =>
      selectedHabits.map((h) => h.name).join(', ');
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setLastDrinkDate(DateTime date) {
    state = state.copyWith(lastDrinkDate: date);
  }

  void setDrinkType(String type) {
    state = state.copyWith(drinkType: type);
  }

  void setMotivation(String motivation) {
    state = state.copyWith(motivation: motivation);
  }

  /// Toggle a habit in the selected habits list.
  /// Adds if not present, removes if present.
  void toggleHabit(HabitTemplate habit) {
    final current = List<HabitTemplate>.from(state.selectedHabits);
    if (current.any((h) => h.id == habit.id)) {
      current.removeWhere((h) => h.id == habit.id);
    } else {
      current.add(habit);
    }
    state = state.copyWith(selectedHabits: current);
  }

  /// Select a single habit (replacing any existing selection).
  void selectSingleHabit(HabitTemplate habit) {
    state = state.copyWith(selectedHabits: [habit]);
  }

  /// Clear all selected habits.
  void clearSelectedHabits() {
    state = state.copyWith(selectedHabits: const []);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Reset all onboarding state (used after data wipe)
  void reset() {
    state = const OnboardingState();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
      (ref) => OnboardingNotifier(),
    );
