# AfterStorm Onboarding Flow + Studio Intro Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make first-run onboarding impossible to dead-end on compact iPhone/Appetize viewports while upgrading the Storm and Me Studios intro to the approved cloud-first lightning sequence and preserving the Google Three premium standard.

**Architecture:** Keep the existing onboarding flow and state model unchanged. Add one reusable sticky glass action container in the design layer, apply it to the two long scrolling onboarding screens, stage the studio intro with explicit animation state, and harden the Azure packaging verifier so updated simulator builds can be delivered to Appetize without false exit-141 failures.

**Tech Stack:** Swift 6, SwiftUI, UIKit-backed haptics through existing services, XCTest source-contract tests, Azure Pipelines YAML, Xcode 26.3 simulator build packaging.

## Global Constraints

- Preserve phase order: Studio Intro → Storm Reveal → Life Areas → Avatar Choice → Avatar Studio → First Quest.
- No authentication/sign-in in this patch.
- No quest-generation/business-logic changes.
- Use all Google Three together: Liquid Glassmorphism, Tactile Maximalism, Immersive Cinematic Pacing.
- Premium effects must remain Apple-native, readable, safe-area aware, and Reduce Motion compatible.
- Life-area Continue remains disabled until at least one category is selected.
- Avatar customization keeps all existing customization choices and unlock rules.
- Azure remains build/package-only; do not reintroduce hosted simulator booting.

---

### Task 1: Lock regression contracts for onboarding visibility, intro sequencing, and packaging

**Files:**
- Modify: `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

**Interfaces:**
- Consumes: repository source files and `azure-pipelines.yml` as text.
- Produces: regression tests that fail if sticky CTAs, staged intro markers, or non-SIGPIPE ZIP verification are removed.

- [ ] **Step 1: Add failing source-contract tests**

Add helpers that resolve the repository root from `#filePath`, then add tests with these exact assertions:

```swift
func testScrollableOnboardingScreensUseStickyBottomActions() throws {
    let lifeArea = try source("AfterStormApp/Onboarding/LifeAreaSelectionView.swift")
    let avatarStudio = try source("AfterStormApp/Onboarding/AvatarStudioView.swift")

    XCTAssertTrue(lifeArea.contains(".safeAreaInset(edge: .bottom)"))
    XCTAssertTrue(lifeArea.contains("OnboardingActionDock"))
    XCTAssertTrue(avatarStudio.contains(".safeAreaInset(edge: .bottom)"))
    XCTAssertTrue(avatarStudio.contains("OnboardingActionDock"))
}

func testStudioIntroUsesCloudFirstRetainedBoltSequence() throws {
    let intro = try source("AfterStormApp/Launch/StudioIntroView.swift")

    XCTAssertTrue(intro.contains("cloudVisible"))
    XCTAssertTrue(intro.contains("strikeVisible"))
    XCTAssertTrue(intro.contains("boltLocked"))
    XCTAssertTrue(intro.contains("wordmarkVisible"))
}

func testAzurePackagingVerificationCannotTriggerGrepSigpipe141() throws {
    let pipeline = try source("azure-pipelines.yml")

    XCTAssertTrue(pipeline.contains("unzip -Z1"))
    XCTAssertTrue(pipeline.contains("zip-contents.txt"))
    XCTAssertFalse(pipeline.contains("unzip -l \"$OUTPUT\" | grep -q"))
}
```

Add this helper inside `BuildCompatibilityTests`:

```swift
private func source(_ relativePath: String) throws -> String {
    let testFile = URL(fileURLWithPath: #filePath)
    let repositoryRoot = testFile
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    return try String(
        contentsOf: repositoryRoot.appendingPathComponent(relativePath),
        encoding: .utf8
    )
}
```

- [ ] **Step 2: Run tests and confirm RED**

Run:

```bash
swift test --filter BuildCompatibilityTests
```

Expected: the three new tests fail because the reusable action dock, intro stage markers, and safe ZIP listing are not implemented yet.

- [ ] **Step 3: Commit tests**

```bash
git add Tests/AfterStormCoreTests/BuildCompatibilityTests.swift
git commit -m "test: lock onboarding premium regression contracts"
```

---

### Task 2: Add the reusable liquid-glass onboarding action dock

**Files:**
- Create: `AfterStormApp/Design/OnboardingActionDock.swift`

**Interfaces:**
- Consumes: `AfterStormTheme`, `PremiumButtonStyle` through caller-provided content.
- Produces: `OnboardingActionDock<Content: View>` reusable safe-area action surface.

- [ ] **Step 1: Implement the dock**

Create:

```swift
import SwiftUI

struct OnboardingActionDock<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, AfterStormTheme.spark.opacity(0.28), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)

            content()
                .padding(.horizontal, 22)
                .padding(.top, 12)
                .padding(.bottom, 10)
        }
        .background(.ultraThinMaterial)
        .background(AfterStormTheme.deepSky.opacity(0.34))
        .shadow(color: .black.opacity(0.22), radius: 20, y: -8)
    }
}
```

- [ ] **Step 2: Parse the new Swift file**

Run:

```bash
xcrun swiftc -parse AfterStormApp/Design/OnboardingActionDock.swift
```

Expected: exit 0.

- [ ] **Step 3: Commit**

```bash
git add AfterStormApp/Design/OnboardingActionDock.swift
git commit -m "feat: add liquid glass onboarding action dock"
```

---

### Task 3: Make Life Areas and Avatar Studio impossible to dead-end

**Files:**
- Modify: `AfterStormApp/Onboarding/LifeAreaSelectionView.swift`
- Modify: `AfterStormApp/Onboarding/AvatarStudioView.swift`

**Interfaces:**
- Consumes: `OnboardingActionDock`, existing `onContinue` closures, existing local selection/style state.
- Produces: always-visible sticky primary actions with unchanged navigation callbacks.

- [ ] **Step 1: Refactor LifeAreaSelectionView**

Keep the header, grid, and “Honestly… everything” inside the existing `ScrollView`. Remove the in-scroll `Button("Continue")` and add bottom spacing:

```swift
Color.clear.frame(height: 88)
```

Then attach:

```swift
.safeAreaInset(edge: .bottom) {
    OnboardingActionDock {
        Button("Continue") {
            HapticsService.tap()
            onContinue(selection)
        }
        .buttonStyle(PremiumButtonStyle())
        .disabled(selection.isEmpty)
        .opacity(selection.isEmpty ? 0.45 : 1)
        .accessibilityHint(selection.isEmpty ? "Choose at least one area first." : "Continue to choose who you are in AfterStorm.")
    }
}
```

Preserve the tactile category cards and selection styling.

- [ ] **Step 2: Refactor AvatarStudioView**

Remove the in-scroll `Button("That’s Me")`, add `Color.clear.frame(height: 88)` at the end of scroll content, then attach:

```swift
.safeAreaInset(edge: .bottom) {
    OnboardingActionDock {
        Button("That’s Me") {
            HapticsService.unlock()
            onContinue(style)
        }
        .buttonStyle(PremiumButtonStyle())
        .accessibilityHint("Save this look and continue to your first quest.")
    }
}
```

Do not change any picker or unlock filtering behavior.

- [ ] **Step 3: Parse both changed views**

Run:

```bash
xcrun swiftc -parse AfterStormApp/Onboarding/LifeAreaSelectionView.swift
xcrun swiftc -parse AfterStormApp/Onboarding/AvatarStudioView.swift
```

Expected: both exit 0.

- [ ] **Step 4: Run the sticky-action regression test**

Run:

```bash
swift test --filter BuildCompatibilityTests/testScrollableOnboardingScreensUseStickyBottomActions
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add AfterStormApp/Onboarding/LifeAreaSelectionView.swift AfterStormApp/Onboarding/AvatarStudioView.swift
git commit -m "fix: keep onboarding actions visible on compact iPhones"
```

---

### Task 4: Rebuild the Storm and Me Studios intro with cinematic cloud-first pacing

**Files:**
- Modify: `AfterStormApp/Launch/StudioIntroView.swift`

**Interfaces:**
- Consumes: `AudioService.shared.playIntroThunder()`, `HapticsService.restorationImpact()`, `AfterStormTheme`, Reduce Motion environment.
- Produces: cloud-first → strike → retained bolt → wordmark sequence with unchanged `onFinished` callback.

- [ ] **Step 1: Replace single reveal state with explicit stages**

Use these view states:

```swift
@State private var cloudVisible = false
@State private var strikeVisible = false
@State private var boltLocked = false
@State private var wordmarkVisible = false
@State private var studiosVisible = false
@State private var drift = false
```

- [ ] **Step 2: Build the layered mark**

The mark ZStack must contain:
- cloud shown when `cloudVisible`;
- a narrow tapered/rounded lightning strike shown briefly when `strikeVisible`;
- the existing gold `bolt.fill` shown only after `boltLocked`, positioned so it reads as embedded in the cloud rather than hanging below it;
- a soft spark-colored radial/glow layer strongest during strike and settling after lock.

The wordmark must be separate from the mark and resolve only after `wordmarkVisible`, with `STUDIOS` following on `studiosVisible`.

- [ ] **Step 3: Implement the timing sequence**

For normal motion:

```swift
withAnimation(.spring(response: 0.62, dampingFraction: 0.82)) { cloudVisible = true }
withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { drift = true }
try? await Task.sleep(for: .milliseconds(430))
AudioService.shared.playIntroThunder()
withAnimation(.easeOut(duration: 0.06)) { strikeVisible = true }
HapticsService.restorationImpact()
try? await Task.sleep(for: .milliseconds(100))
withAnimation(.easeOut(duration: 0.22)) {
    strikeVisible = false
    boltLocked = true
}
try? await Task.sleep(for: .milliseconds(260))
withAnimation(.spring(response: 0.48, dampingFraction: 0.84)) { wordmarkVisible = true }
try? await Task.sleep(for: .milliseconds(150))
withAnimation(.easeOut(duration: 0.32)) { studiosVisible = true }
try? await Task.sleep(for: .milliseconds(850))
onFinished()
```

For Reduce Motion, set all final states true immediately, play no strike animation, hold roughly 900 ms, then call `onFinished()`.

- [ ] **Step 4: Parse and run intro regression test**

Run:

```bash
xcrun swiftc -parse AfterStormApp/Launch/StudioIntroView.swift
swift test --filter BuildCompatibilityTests/testStudioIntroUsesCloudFirstRetainedBoltSequence
```

Expected: parse exit 0 and test PASS.

- [ ] **Step 5: Commit**

```bash
git add AfterStormApp/Launch/StudioIntroView.swift
git commit -m "feat: give Storm and Me intro cinematic lightning lockup"
```

---

### Task 5: Remove Azure package false-failure exit 141

**Files:**
- Modify: `azure-pipelines.yml`

**Interfaces:**
- Consumes: generated `AfterStorm-simulator.app.zip`.
- Produces: deterministic `zip-contents.txt`, verified simulator package, SHA-256 artifact without `grep -q` SIGPIPE behavior.

- [ ] **Step 1: Replace piped ZIP checks**

Replace:

```bash
/usr/bin/unzip -l "$OUTPUT" | grep -q 'AfterStorm.app/Info.plist'
/usr/bin/unzip -l "$OUTPUT" | grep -q 'AfterStorm.app/PlugIns/AfterStormWidget.appex/Info.plist'
```

with:

```bash
ZIP_CONTENTS="$(artifactDir)/zip-contents.txt"
/usr/bin/unzip -Z1 "$OUTPUT" > "$ZIP_CONTENTS"
grep -Fx 'AfterStorm.app/Info.plist' "$ZIP_CONTENTS"
grep -Fx 'AfterStorm.app/PlugIns/AfterStormWidget.appex/Info.plist' "$ZIP_CONTENTS"
```

This makes `unzip` finish normally before `grep` runs, eliminating the SIGPIPE/141 false failure under `pipefail`.

- [ ] **Step 2: Validate YAML and packaging regression test**

Run:

```bash
python3 - <<'PY'
import yaml
with open('azure-pipelines.yml', encoding='utf-8') as f:
    yaml.safe_load(f)
print('azure-pipelines.yml: valid')
PY
swift test --filter BuildCompatibilityTests/testAzurePackagingVerificationCannotTriggerGrepSigpipe141
```

Expected: YAML parses and test PASS.

- [ ] **Step 3: Commit**

```bash
git add azure-pipelines.yml
git commit -m "fix: prevent Azure package verification SIGPIPE"
```

---

### Task 6: Full verification and Appetize handoff

**Files:**
- Verify only; no source change unless a failure identifies a real defect.

**Interfaces:**
- Consumes: all previous tasks.
- Produces: fresh green test/build/package evidence and a new `AfterStorm-simulator.app.zip` suitable for Appetize.

- [ ] **Step 1: Run full core test suite**

```bash
swift test
```

Expected: all tests PASS.

- [ ] **Step 2: Parse all native Swift files**

```bash
find AfterStormApp AfterStormWidget Shared -name '*.swift' -print0 | while IFS= read -r -d '' file; do
  xcrun swiftc -parse "$file"
done
```

Expected: exit 0.

- [ ] **Step 3: Run Azure package-only pipeline**

Use branch `feature/afterstorm-core-slice`. Expected final steps:
- `Build AfterStorm and widget for iOS Simulator` PASS.
- `Package AfterStorm simulator app for browser testing` PASS.
- artifact `afterstorm-simulator-build` contains `AfterStorm-simulator.app.zip`, `zip-contents.txt`, and `AfterStorm-simulator.sha256`.

- [ ] **Step 4: Upload fresh ZIP to Appetize and visually verify**

Verify on a compact iPhone profile:
- cloud appears before lightning;
- bolt remains embedded in cloud;
- wordmark resolves after strike;
- Life Areas primary CTA is always visible;
- category selections remain tactile and obvious;
- Avatar Studio primary CTA remains visible while customization scrolls;
- flow reaches First Quest;
- no clipped or hidden primary action.

- [ ] **Step 5: Record acceptance evidence**

Update `docs/quality/v1-acceptance.md` with the fresh Azure build number and Appetize visual findings before merging to `main`.
