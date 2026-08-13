# AfterStorm Reactive Visual Luxury System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the flat dark UI with a centralized reactive storm-to-afterglow background, adaptive real-glass surfaces, and progress-aware blue/teal/gold lighting.

**Architecture:** New reusable design primitives under `AfterStormApp/Design` consume restoration progress and `ExperiencePreferences`. Existing screens adopt those primitives without changing navigation, quest logic, persistence, commerce, or progression.

**Tech Stack:** Swift 6, SwiftUI, Observation, iOS 18+, XcodeGen, existing Azure package-only simulator build.

## Global Constraints
- Work only on `feature/afterstorm-core-slice`; keep `main` protected.
- iOS 18.0; no third-party visual dependencies.
- Preserve guest-first flow, Avatar Studio single vertical scroll, sticky CTAs, current audio/haptic controls.
- System Reduce Motion wins; Calm stays visually rich without decorative motion.
- No auth, ads, Game Center, monetization changes, or progression changes.

### Task 1: Reactive visual state
Create `AfterStormApp/Design/RestorationVisualState.swift`; modify `AfterStormTheme.swift`; extend `BuildCompatibilityTests.swift`.
- [ ] Add RED contracts for `RestorationVisualState`, `accentPrimary`, `accentSecondary`, `glassTint`, `stormIntensity`, `afterglowIntensity`, `glowIntensity`, `backgroundColors`, and theme tokens `stormTeal`, `glassSilver`, `afterglowRose`.
- [ ] Implement clamped progress-driven blue→teal→gold/rose palette values.
- [ ] Parse/typecheck and commit `feat: add reactive restoration visual state`.

### Task 2: Storm + real glass primitives
Create `AdaptiveStormBackground.swift` and `AdaptiveGlassSurface.swift`.
- [ ] Add RED contracts requiring layered gradient/glow/cloud/mist background and glass material+tint+gradient edge+highlight+layered shadows.
- [ ] Implement `AdaptiveStormBackground(restorationFraction:atmosphericOnly:)` driven by `ExperiencePreferences`.
- [ ] Implement `View.adaptiveGlass(restorationFraction:cornerRadius:prominence:)` using material, adaptive tint, top-leading reflection, gradient border, colored bloom and depth shadow.
- [ ] Parse/check contracts and commit `feat: add adaptive storm and glass primitives`.

### Task 3: Premium buttons + onboarding
Modify `PremiumButtonStyle.swift`, `LifeAreaSelectionView.swift`, `AvatarChoiceView.swift`, `AvatarStudioView.swift`, `AvatarPreviewView.swift`.
- [ ] Upgrade existing button signature to thick adaptive glass with blue→teal→gold internal light and tactile press.
- [ ] Put storm atmosphere behind onboarding and adaptive glass under sticky CTAs.
- [ ] Add luminous avatar hero staging.
- [ ] Preserve `GridItem(.adaptive` and forbid `ScrollView(.horizontal` in Avatar Studio.
- [ ] Parse and commit `feat: give onboarding adaptive storm glass`.

### Task 4: Quest + world luxury
Modify `FirstQuestView.swift`, `QuestDetailView.swift`, `QuestCompleteView.swift`, `RestorationRevealView.swift`, `WorldHomeView.swift`.
- [ ] Main World keeps diorama hero; dock becomes live adaptive glass using existing restoration fraction.
- [ ] Restoration Reveal inherits live blue/teal/gold pulse/card while preserving haptic/audio timing.
- [ ] Quest screens gain atmospheric background and dimensional glass without text/flow changes.
- [ ] Parse and commit `feat: make quest and world surfaces reactive luxury`.

### Task 5: Me + Settings
Modify `MeView.swift` and `SettingsView.swift`.
- [ ] Me gets atmospheric avatar hero + adaptive glass menu surfaces.
- [ ] Settings keeps native controls but uses atmospheric background and tasteful glass framing.
- [ ] Preserve Settings/AfterStorm+/Privacy navigation.
- [ ] Parse and commit `feat: polish me and settings glass surfaces`.

### Task 6: Verification
- [ ] Run source-contract tests and Swift parse/type checks.
- [ ] Confirm Azure remains manual-only/package-only with no simulator boot.
- [ ] Run exactly one manual Azure build on latest feature branch.
- [ ] Upload fresh ZIP to Appetize and inspect storm, clearing, afterglow, Avatar Studio compact scroll, Main World, Restoration Reveal, Cinematic vs Calm.
- [ ] Do not merge until visual acceptance is approved.
