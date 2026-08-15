# Quests Interaction Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing Quests flow feel tactile, deliberate, and premium while preserving the approved hybrid-glass visuals and all quest behavior.

**Architecture:** Add one small reusable SwiftUI press-feedback primitive in the design layer, then apply it to quest cards, life-area tiles, and secondary glass controls. Reuse `AfterStormTheme.quickSpring`, `HapticsService`, and existing SwiftUI state rather than introducing a new animation framework. Add only one new haptic semantic for timer completion.

**Tech Stack:** Swift 6, SwiftUI, XCTest/Swift Testing source-contract tests, Core Haptics/UIKit feedback, Xcode 26.3, XcodeGen, GitHub Actions mirror build.

## Global Constraints

- Preserve the approved hybrid-glass palette and optical recipe.
- Do not change navigation architecture, quest logic, persistence, onboarding structure, monetization, accounts, or unrelated tabs.
- Respect `accessibilityReduceMotion` everywhere new motion is introduced.
- Respect `ExperiencePreferences.shared.hapticsEnabled` for all haptics.
- Do not introduce repeating shimmer or any new continuous animation system.
- No artificial navigation delays.
- Final verification must include Swift tests, asset generation, XcodeGen, Xcode 26.3 iOS Simulator app + widget build, and Appetize ZIP verification.

---

### Task 1: Shared premium press feedback primitive

**Files:**
- Create: `AfterStormApp/Design/PremiumInteractionStyle.swift`
- Create: `Tests/AfterStormCoreTests/QuestInteractionPolishTests.swift`

**Interfaces:**
- Produces: `PremiumPressButtonStyle(pressedScale:pressedBrightness:) : ButtonStyle`
- Consumes: `AfterStormTheme.quickSpring`, `accessibilityReduceMotion`

- [ ] **Step 1: Write the failing contract tests**

Create `QuestInteractionPolishTests.swift` with tests that read the relevant source files and assert the shared style exists, references `accessibilityReduceMotion`, uses `AfterStormTheme.quickSpring`, and applies `scaleEffect` plus `brightness` based on `configuration.isPressed`.

- [ ] **Step 2: Run `swift test` and verify RED**

Expected: the new source-contract tests fail because `PremiumInteractionStyle.swift` does not exist yet.

- [ ] **Step 3: Implement the minimal shared style**

```swift
import SwiftUI

struct PremiumPressButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var pressedScale: CGFloat = 0.982
    var pressedBrightness: Double = -0.018

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? pressedScale : 1))
            .brightness(configuration.isPressed ? pressedBrightness : 0)
            .animation(
                reduceMotion ? nil : AfterStormTheme.quickSpring,
                value: configuration.isPressed
            )
    }
}
```

- [ ] **Step 4: Run `swift test` and verify GREEN**

Expected: all tests pass.

- [ ] **Step 5: Commit**

Commit message: `feat: add premium quest press feedback style`

---

### Task 2: Quests discovery and filter interaction polish

**Files:**
- Modify: `AfterStormApp/Main/QuestsView.swift`
- Modify: `Tests/AfterStormCoreTests/QuestInteractionPolishTests.swift`

**Interfaces:**
- Consumes: `PremiumPressButtonStyle`, `HybridGlassChipStyle`, `HapticsService.tap()`, `AfterStormTheme.quickSpring`

- [ ] **Step 1: Add failing tests**

Assert that `QuestsView.swift`:
- applies `PremiumPressButtonStyle` to quest-card buttons;
- calls `HapticsService.tap()` when time filters change;
- calls `HapticsService.tap()` when area filters change;
- wraps time and area filter selection mutation in `withAnimation(AfterStormTheme.quickSpring)`;
- animates loading/content replacement using a Reduce Motion aware transition or animation guard.

- [ ] **Step 2: Run `swift test` and verify RED**

Expected: failures for the missing quest-card press style and missing filter haptics/animation consistency.

- [ ] **Step 3: Implement Quests interactions**

Changes:
- add `@Environment(\.accessibilityReduceMotion) private var reduceMotion`;
- change time filter actions to call `HapticsService.tap()` and mutate with `withAnimation(AfterStormTheme.quickSpring)`;
- change area filter actions the same way;
- change quest-card `.buttonStyle(.plain)` to `.buttonStyle(PremiumPressButtonStyle())`;
- animate loading/content state with a restrained opacity + scale transition when Reduce Motion is off and opacity-only when it is on;
- do not delay `onSelect` or `onGiveQuest` callbacks.

Suggested state wrapper:

```swift
Group {
    if model.isLoadingQuests {
        loadingView
    } else {
        questContent
    }
}
.animation(reduceMotion ? nil : AfterStormTheme.quickSpring, value: model.isLoadingQuests)
```

- [ ] **Step 4: Run `swift test` and verify GREEN**

- [ ] **Step 5: Commit**

Commit message: `feat: polish quests discovery interactions`

---

### Task 3: Life Area tactile selection and disabled-state polish

**Files:**
- Modify: `AfterStormApp/Onboarding/LifeAreaSelectionView.swift`
- Modify: `Tests/AfterStormCoreTests/QuestInteractionPolishTests.swift`

**Interfaces:**
- Consumes: `PremiumPressButtonStyle`, existing `hybridGlassTile`, existing selection animation, `HapticsService.tap()`

- [ ] **Step 1: Add failing tests**

Assert that life-area buttons use `PremiumPressButtonStyle`, selected checkmark transitions remain scale + opacity, and the Continue action cannot haptically fire while disabled because the button remains disabled when `selection.isEmpty`.

- [ ] **Step 2: Run `swift test` and verify RED**

Expected: missing premium press style on life-area tiles.

- [ ] **Step 3: Implement the polish**

- replace `.buttonStyle(.plain)` on area tiles with `.buttonStyle(PremiumPressButtonStyle(pressedScale: 0.975, pressedBrightness: -0.014))`;
- preserve the existing selected scale and checkmark transition;
- keep the Continue button `.disabled(selection.isEmpty)` and existing muted opacity so disabled controls remain visually glassy rather than disappearing;
- do not change selected-area data behavior.

- [ ] **Step 4: Run `swift test` and verify GREEN**

- [ ] **Step 5: Commit**

Commit message: `feat: polish life area selection feedback`

---

### Task 4: Quest detail, mode, and completion feedback

**Files:**
- Modify: `AfterStormApp/Quest/QuestModeView.swift`
- Modify: `AfterStormApp/Quest/QuestCompleteView.swift`
- Modify: `AfterStormApp/Services/HapticsService.swift`
- Modify: `Tests/AfterStormCoreTests/QuestInteractionPolishTests.swift`

**Interfaces:**
- Produces: `HapticsService.timerFinished()`
- Consumes: `HybridGlassChipStyle`, `PremiumPressButtonStyle`, existing completion haptic/burst, `ExperiencePreferences.shared.hapticsEnabled`

- [ ] **Step 1: Add failing tests**

Assert:
- `HapticsService` contains `timerFinished()` and guards `ExperiencePreferences.shared.hapticsEnabled`;
- Quest Mode uses `HybridGlassChipStyle(selected: isPaused)` for Pause/Resume instead of stock `.bordered`;
- Quest Mode calls `HapticsService.timerFinished()` exactly when the countdown crosses from positive to zero using `onChange(of: remainingSeconds)`;
- Quest Complete applies `PremiumPressButtonStyle` to the glass PhotosPicker control;
- the existing Reduce Motion guard for the completion burst remains present.

- [ ] **Step 2: Run `swift test` and verify RED**

Expected: failures for missing `timerFinished`, stock pause/resume style, and missing PhotosPicker press feedback.

- [ ] **Step 3: Implement timer haptic**

In `HapticsService.swift`:

```swift
static func timerFinished() {
    guard ExperiencePreferences.shared.hapticsEnabled else { return }
    #if canImport(UIKit)
    UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.58)
    #endif
}
```

- [ ] **Step 4: Implement Quest Mode feedback**

- replace `.buttonStyle(.bordered)` on Pause/Resume with `.buttonStyle(HybridGlassChipStyle(selected: isPaused))`;
- keep the existing `HapticsService.tap()` for Pause/Resume;
- add:

```swift
.onChange(of: remainingSeconds) { oldValue, newValue in
    if oldValue > 0 && newValue == 0 {
        HapticsService.timerFinished()
    }
}
```

Do not alter countdown logic.

- [ ] **Step 5: Implement Quest Complete press feedback**

Replace PhotosPicker `.buttonStyle(.plain)` with:

```swift
.buttonStyle(PremiumPressButtonStyle(pressedScale: 0.985, pressedBrightness: -0.012))
```

Keep the existing one-shot burst, success haptic, and Reduce Motion guard unchanged.

- [ ] **Step 6: Run `swift test` and verify GREEN**

- [ ] **Step 7: Commit**

Commit message: `feat: polish quest mode and completion feedback`

---

### Task 5: Full regression and Appetize package verification

**Files:**
- No production changes unless verification exposes a regression.
- The existing `.github/workflows/swift-core-diagnostic.yml` is the Xcode 26.3 mirror gate.

**Interfaces:**
- Consumes the complete feature branch.

- [ ] **Step 1: Run the full Swift suite**

Run: `swift test`
Expected: 0 failures.

- [ ] **Step 2: Generate assets**

Run:

```bash
python3 scripts/generate-assets.py
python3 scripts/generate-storm-atmosphere.py
```

Expected: both complete successfully and the current storm JPEG exists.

- [ ] **Step 3: Generate the Xcode project**

Run the repo's XcodeGen path (`scripts/generate-xcode.sh` or workflow equivalent).
Expected: `AfterStorm.xcodeproj` generated successfully.

- [ ] **Step 4: Build with Xcode 26.3**

Run:

```bash
xcodebuild \
  -project AfterStorm.xcodeproj \
  -scheme AfterStorm \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Expected: `BUILD SUCCEEDED`.

- [ ] **Step 5: Verify app + widget**

Verify:
- `DerivedData/Build/Products/Debug-iphonesimulator/AfterStorm.app/Info.plist`
- `DerivedData/Build/Products/Debug-iphonesimulator/AfterStorm.app/PlugIns/AfterStormWidget.appex/Info.plist`

- [ ] **Step 6: Package Appetize ZIP and verify contents**

Use the existing workflow packaging commands and `ditto`; verify both `Info.plist` paths exist in the archive.

- [ ] **Step 7: Independently compare artifact digest/hash**

Download the GitHub Actions artifact from the successful run and compare its reported digest to the downloaded archive.

- [ ] **Step 8: Report only verified evidence**

Final report must include changed files, exact Swift test count/failures, Xcode result, widget verification, ZIP verification, commit SHA, workflow run ID, artifact digest, and downloadable Appetize ZIP.
