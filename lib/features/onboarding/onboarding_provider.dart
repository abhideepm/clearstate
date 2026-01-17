import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final DateTime? lastDrinkDate;
  final int drinksPerWeek;
  final String drinkType;
  final double costPerDrink;
  final String currency;
  final int currentStep;

  const OnboardingState({
    this.lastDrinkDate,
    this.drinksPerWeek = 10,
    this.drinkType = 'Beer',
    this.costPerDrink = 8.0,
    this.currency = 'USD',
    this.currentStep = 0,
  });

  OnboardingState copyWith({
    DateTime? lastDrinkDate,
    int? drinksPerWeek,
    String? drinkType,
    double? costPerDrink,
    String? currency,
    int? currentStep,
  }) {
    return OnboardingState(
      lastDrinkDate: lastDrinkDate ?? this.lastDrinkDate,
      drinksPerWeek: drinksPerWeek ?? this.drinksPerWeek,
      drinkType: drinkType ?? this.drinkType,
      costPerDrink: costPerDrink ?? this.costPerDrink,
      currency: currency ?? this.currency,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setLastDrinkDate(DateTime date) {
    state = state.copyWith(lastDrinkDate: date);
  }

  void setDrinksPerWeek(int count) {
    state = state.copyWith(drinksPerWeek: count);
  }

  void setDrinkType(String type) {
    state = state.copyWith(drinkType: type);
  }

  void setCostPerDrink(double cost) {
    state = state.copyWith(costPerDrink: cost);
  }

  void setCurrency(String currency) {
    state = state.copyWith(currency: currency);
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
