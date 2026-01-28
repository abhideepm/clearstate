# Bento Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor ClearState into a multi-habit sobriety tracker with a Neobrutalist Bento Grid UI, multi-habit support, and anti-shame metrics.

**Architecture:** Transition from a single-session model to a multi-habit architecture. The `SobrietyRepository` will manage `Habit` objects and `DailyLog` entries keyed by `habitId`. The `SobrietyOrchestrator` will be updated to handle habit-specific events.

**Tech Stack:** Flutter, Hive (Persistence), Riverpod (State), JetBrains Mono (Typography).

---

### Task 1: Model Refactor & Type ID Cleanup

**Files:**
- Create: `lib/data/models/daily_log.dart`
- Modify: `lib/data/models/habit.dart`
- Modify: `lib/data/models/user_profile.dart`
- Delete: `lib/data/models/sobriety_session.dart`
- Modify: `lib/core/services/hive_adapter_registry.dart`

**Step 1: Update Habit Model (Type ID 1)**
Refactor `lib/data/models/habit.dart` to fully replace `SobrietySession`.
```dart
@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final HabitType type; // Move HabitType to ID 5
  @HiveField(3) final String themeColor;
  @HiveField(4) final String motivation;
  @HiveField(5) final DateTime startDate;
  @HiveField(6) final DateTime? endDate;
}
```

**Step 2: Create DailyLog Model (Type ID 3)**
Ensure `lib/data/models/daily_log.dart` aligns with the new requirements (Slips vs Relapses).

**Step 3: Update Hive Registry**
Update `lib/core/services/hive_adapter_registry.dart` to remove `SobrietySessionAdapter` and add `HabitAdapter` and `HabitTypeAdapter(id: 5)`.

**Step 4: Commit**
`git add . && git commit -m "refactor: update models and hive registry for multi-habit support"`

---

### Task 2: Repository & Orchestrator Update

**Files:**
- Modify: `lib/data/repositories/sobriety_repository.dart`
- Modify: `lib/core/services/sobriety_orchestrator.dart`

**Step 1: Habit-Aware Repository**
Update `SobrietyRepository` to use `Box<Habit>` instead of `Box<SobrietySession>`. Add `habitId` parameter to all logging and retrieval methods.

**Step 2: Success Rate Calculation**
Implement the success rate logic: `(Total Days - Slips) / Total Days`.

**Step 3: Orchestrator Events**
Update `SobrietyOrchestrator` to accept `habitId` in `logRelapse` and `logSoberDay` to trigger habit-specific widget updates.

**Step 4: Commit**
`git add . && git commit -m "feat: implement habit-aware repository and orchestrator"`

---

### Task 3: Bento Dashboard Implementation

**Files:**
- Create: `lib/features/dashboard/widgets/bento_card.dart`
- Modify: `lib/features/dashboard/dashboard_screen.dart`
- Modify: `lib/core/theme/colors.dart`

**Step 1: Neobrutalist Theme**
Update `colors.dart` with Acid Green (#B0FF00), Hyper-Violet (#8A2BE2), and Signal Orange (#FF4500) with hard shadows.

**Step 2: Bento Card Widget**
Create a generic `BentoCard` with 12px radius and neobrutalist styling.

**Step 3: Dashboard Grid**
Refactor `DashboardScreen` to use a `GridView` or `CustomScrollView` with the 2x2 and 1x1 card layout.

**Step 4: Commit**
`git add . && git commit -m "feat: implement bento dashboard UI"`

---

### Task 4: Onboarding Flow Update

**Files:**
- Modify: `lib/features/onboarding/onboarding_flow.dart`

**Step 1: Multi-Stack Selection**
Update the flow to allow selecting multiple habits (Alcohol, Weed, Caffeine, etc.) from the "Stack".

**Step 2: Commit**
`git add . && git commit -m "feat: update onboarding for multi-habit stack selection"`
