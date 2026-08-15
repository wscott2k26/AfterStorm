# AfterStorm Quests Interaction Polish Design

Date: 2026-08-15
Branch: `feature/afterstorm-core-slice`
Baseline: `652771cf763739dfbcbbf02727c4f6d004032705`

## Goal

Make the existing Quests flow feel as premium as the approved hybrid-glass visual system without redesigning layouts, changing quest logic, or adding distracting motion.

## Current State

The Quests flow already has pieces of the intended sensory language: `HapticsService`, `AfterStormTheme.quickSpring`, pressed scaling in `PremiumButtonStyle`, selected Life Area scale/check feedback, Quest Mode breathing motion, and Quest Complete burst feedback. The issue is consistency: card presses, filter changes, selection changes, disabled/loading transitions, and navigation handoffs do not yet feel like one coherent interaction system.

## Approaches Considered

### A. Per-screen bespoke animation

Add custom transitions and timing independently to each Quests screen.

Pros: maximum local control.
Cons: duplicated logic, inconsistent motion, higher regression risk.

### B. Shared sensory interaction primitives — selected

Create small reusable SwiftUI interaction styles/modifiers for press feedback and state transitions, then apply them selectively across the existing Quests flow. Reuse the current theme spring and haptic service rather than introducing a new animation engine.

Pros: consistent, testable, lower scope, easier to tune later.
Cons: requires a small shared design-layer addition.

### C. Large navigation/animation framework

Introduce coordinated matched-geometry transitions or a custom navigation motion layer.

Pros: most dramatic.
Cons: unnecessary for this pass, higher complexity, more fragile, risks changing app structure.

## Approved Direction

Use Approach B: restrained premium motion built from existing AfterStorm springs, haptics, and SwiftUI state transitions.

## Interaction Language

### Press feedback

Quest cards, Life Area tiles, glass chips, and secondary glass controls should visibly compress by a small amount while pressed, slightly reduce highlight intensity, and return with the existing quick spring. The effect must be tactile rather than bouncy.

### Selection feedback

When a Life Area or filter becomes selected:
- keep the existing glass selection treatment;
- add a short scale/brightness settle where useful;
- use soft tap haptics once per deliberate selection;
- animate checkmarks/selection affordances with scale + opacity;
- never run repeating selection animation.

### Quest-card handoff

Pressing a quest card should produce immediate press feedback and haptic response before the existing navigation callback. No artificial delay should be introduced.

### CTA hierarchy

Primary actions such as `Give Me a Quest`, `Start Quest`, `I'm Done`, and `I DID IT` keep the existing premium button look and pressed behavior. The polish pass may tune pressed scale/brightness/shadow consistency but must not redesign the approved glass recipe.

### Loading and disabled states

Loading should transition cleanly into content using restrained opacity/scale movement rather than hard replacement where practical. Disabled controls must remain visibly glass and premium while becoming quieter. Disabled controls must not fire haptics.

### Quest Mode

Keep the existing slow breathing companion animation. Add restrained state feedback for Pause/Resume and timer completion. Do not add more continuous animation.

### Completion

Keep the current completion burst and success haptic. Any enhancement must remain short, one-shot, and Reduce Motion aware.

## Accessibility

- Respect `accessibilityReduceMotion` everywhere.
- Existing `ExperiencePreferences.shared.hapticsEnabled` remains the source of truth for haptics.
- No critical state is communicated only through motion or haptics.
- No repeating shimmer or high-frequency motion.

## Scope

In scope:
- `AfterStormApp/Main/QuestsView.swift`
- `AfterStormApp/Onboarding/LifeAreaSelectionView.swift`
- `AfterStormApp/Quest/QuestDetailView.swift`
- `AfterStormApp/Quest/QuestModeView.swift`
- `AfterStormApp/Quest/QuestCompleteView.swift`
- shared design interaction helper(s) if needed
- existing `PremiumButtonStyle` only for targeted pressed-state consistency
- focused contract tests

Out of scope:
- navigation architecture changes
- quest data/model changes
- persistence changes
- onboarding structure changes
- monetization/account work
- unrelated tabs
- new continuous animation systems
- changing the approved glass palette/optical recipe

## Testing Strategy

Use TDD contract tests for the shared interaction primitives and key flow integration. Verify Reduce Motion guards and existing haptic routing remain present. After green Swift tests, run the full Xcode 26.3 mirror path: asset generation, XcodeGen, iOS Simulator app + widget build, Appetize ZIP creation, ZIP integrity verification, and independent artifact/hash confirmation.

## Acceptance Criteria

1. Quest cards have clear premium press feedback without delaying navigation.
2. Filter chips and Life Area selections feel tactile and consistent.
3. Primary and secondary CTAs share coherent pressed behavior.
4. Pause/Resume and completion state changes feel deliberate rather than abrupt.
5. Loading/disabled states transition cleanly and remain visually premium.
6. Reduce Motion and haptics preferences are preserved.
7. No quest logic or navigation architecture changes.
8. Existing approved hybrid-glass visuals remain intact.
9. Swift tests pass.
10. Full Xcode 26.3 simulator app + widget build passes.
11. Appetize ZIP is produced and verified.
