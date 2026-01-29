# Symptom Intelligence & Monetization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform TrueState into a "Recovery OS" by implementing a scientific symptom tracking system, an intelligence engine powered by neurobiological research, and a "Lifetime Unlock" monetization model.

**Architecture:** We will extend the existing `DailyLog` model and `SobrietyRepository` to handle rich symptom data. The `SymptomIntelligenceService` will use a milestone-based lookup to provide phase-specific predictions and "micro-insights" (scientific explanations). Monetization will be handled via `purchases_flutter` with a local-first gating strategy.

**Tech Stack:** Flutter, Riverpod, Hive (Encrypted), purchases_flutter (RevenueCat).

---

## Phase 1: Symptom Data Architecture

### Task 1: Define Symptom Constants & Scientific Mappings
**Files:**
- Create: `lib/core/constants/symptom_definitions.dart`
- Create: `lib/core/constants/symptom_milestones.dart`

**Step 1: Define the Symptom data structure**
Create a master list of symptoms with IDs, display names, and categories.

**Step 2: Map Scientific Milestones**
Incorporate the JSON data for Alcohol, Weed, Nicotine, NoFap, and Caffeine.
Example structure:
```dart
final alcoholMilestones = [
  SymptomMilestone(
    hourThreshold: 24,
    title: "GABA/Glutamate Storm",
    sensation: "Anxiety & Tremors",
    science: "Glutamate is flooding the brain. This is temporary 'over-wiring' while the brakes (GABA) are repaired.",
  ),
  // ... all other milestones from research
];
```

---

## Phase 2: Symptom Logging UI

### Task 2: Implement DailyLogInputSheet
**Files:**
- Create: `lib/features/dashboard/widgets/daily_log_input_sheet.dart`
- Modify: `lib/features/dashboard/dashboard_screen.dart`

**Step 1: Create the input sheet**
Follow the `DrinkInputSheet` pattern. Include:
- Mood slider (1-5)
- Multi-select chips for symptoms
- "Expected Today" section (populated by the intelligence engine)

**Step 2: Update Dashboard Trigger**
Modify the "Log Sober Day" card to open this sheet on tap. Keep long-press for the "Quick Log" (legacy) behavior.

---

## Phase 3: Symptom Intelligence Engine

### Task 3: Create SymptomIntelligenceService
**Files:**
- Create: `lib/core/services/symptom_intelligence_service.dart`
- Test: `test/unit/services/symptom_intelligence_service_test.dart`

**Step 1: Write failing tests**
Test that given a habit (e.g., 'alcohol') and a duration (e.g., 24 hours), the service returns the "GABA/Glutamate Storm" milestone.

**Step 2: Implement the service**
Create logic to find the closest milestone based on elapsed hours.

---

### Task 4: Create Symptom Prediction Card
**Files:**
- Create: `lib/features/dashboard/widgets/symptom_prediction_card.dart`

**Step 1: Build the UI**
A Bento card showing today's predicted symptoms and a "Science" toggle to show the micro-insight (e.g., explaining why tremors happen at 24h).

---

## Phase 4: Monetization (The "Lifetime" Advantage)

### Task 5: Integrate RevenueCat & Feature Gating
**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/services/subscription_service.dart`
- Create: `lib/core/utils/pro_feature_gate.dart`

**Step 1: Add dependencies**
Add `purchases_flutter`.

**Step 2: Implement Gating**
Gate "Symptom Intelligence" and "Stealth Labels" behind the Pro tier.
Follow the "Lifetime Unlock" strategy: $30 one-time or $5/month.

---

## Phase 5: Polishing & "Vibe" Differentiation

### Task 6: Implement "Cozy" vs "Cyber" Themes
**Files:**
- Modify: `lib/core/theme/colors.dart`
- Modify: `lib/features/settings/settings_screen.dart`

**Step 1: Define theme variants**
- **Cozy Mode:** Warm colors, nature-inspired (accessible for Finch users).
- **Cyber/Focus Mode:** High contrast, black/neon (data-heavy for bio-hackers).

---

## Task 7: Final Verification & Integration
**Step 1: Run all tests**
`flutter test`

**Step 2: Manual walkthrough**
Verify the end-to-end flow: Onboarding -> Dashboard -> Detailed Logging -> Symptom Insight.
