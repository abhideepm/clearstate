# Plan: Fix Breathing UI Alignment

The breathing exercise screen (`UrgeSurfingScreen`) has alignment issues where all elements are left-aligned. This plan addresses the issue by centering the layout and text.

## Proposed Changes

### 1. `lib/features/urge_surfing/urge_surfing_screen.dart`

- Wrap the main `Column` in a `SizedBox(width: double.infinity)` to ensure it takes up the full width of the screen.
- Set `crossAxisAlignment: CrossAxisAlignment.center` on the `Column`.
- Add `textAlign: TextAlign.center` to all `Text` widgets:
    - "BREATHE" (Header)
    - `state.phaseText` (Breathing instruction)
    - `state.formattedTime` (Timer)
    - "REMAINING" (Label)

## Verification
- Run `flutter analyze` to check for static analysis issues.
- The UI should now be horizontally centered as intended.
