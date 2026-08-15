# Quests Glass Consistency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every key surface in the AfterStorm Quests flow read as one coherent premium hybrid-glass system: smoky translucent body, crystal reflections/rims, environmental storm influence, and strong readability.

**Architecture:** Strengthen the existing shared adaptive-glass modifiers and button styles rather than introduce a parallel design system. Add one reusable icon-well modifier so Quest discovery cards, first-quest cards, and Life Area tiles share the same optical language. Use source-contract XCTest coverage because the Swift package tests cannot instantiate the app's SwiftUI views directly; final correctness is gated by the existing macOS-15 / Xcode 26.3 mirror workflow, which builds the full app and widget and packages the Appetize ZIP.

**Tech Stack:** Swift 6, SwiftUI, XCTest, XcodeGen, Xcode 26.3, iOS Simulator, GitHub Actions.

## Global Constraints

- Work only on `feature/afterstorm-core-slice`.
- Do not redesign app structure or navigation.
- Do not change quest logic, onboarding flow behavior, persistence, monetization, or unrelated tabs.
- Preserve `AdaptiveStormBackground` throughout the Quests-related flow.
- Preserve `accessibilityReduceTransparency` and `accessibilityReduceMotion` behavior.
- Keep large surfaces dark/smoky and translucent; never milky white, opaque gray, or neon.
- Keep text, reward/time rows, icons, filters, and CTAs readable.
- Verification must include `swift test`, asset generation, XcodeGen, full Xcode 26.3 simulator build, widget verification, Appetize ZIP creation, and ZIP-content verification.

---

### Task 1: Add failing visual-consistency contracts

**Files:**
- Create: `Tests/AfterStormCoreTests/HybridGlassConsistencyTests.swift`

**Interfaces:**
- Consumes: existing source-file inspection helper pattern used by `VisualLuxuryTests` and `HybridGlassLifeAreaTests`.
- Produces: source contracts requiring one shared icon-well modifier, stronger shared reflection layers, glass CTAs, and consistent Quest-flow usage.

- [ ] **Step 1: Write the failing tests**

```swift
import Foundation
import XCTest

final class HybridGlassConsistencyTests: XCTestCase {
    func testCoreGlassHasBroadReflectionAndReusableIconWell() throws {
        let glass = try source("AfterStormApp/Design/AdaptiveGlassSurface.swift")
        for token in [
            "HybridGlassIconWellModifier",
            "hybridGlassIconWell",
            "RadialGradient",
            "specularBand",
            "crystalRim"
        ] {
            XCTAssertTrue(glass.contains(token), "Missing shared glass-depth token: \(token)")
        }
    }

    func testQuestSurfacesUseSharedGlassLanguage() throws {
        let quests = try source("AfterStormApp/Main/QuestsView.swift")
        let first = try source("AfterStormApp/Onboarding/FirstQuestView.swift")
        let life = try source("AfterStormApp/Onboarding/LifeAreaSelectionView.swift")

        XCTAssertTrue(quests.contains(".hybridGlassIconWell("))
        XCTAssertTrue(first.contains(".hybridGlassIconWell("))
        XCTAssertTrue(life.contains(".hybridGlassIconWell("))
        XCTAssertTrue(first.contains("PremiumButtonStyle(prominent: true)"))
        XCTAssertTrue(life.contains(".adaptiveGlassSurface(cornerRadius: 26, prominence: .control)"))
    }

    func testPremiumButtonCarriesCrystalSpecularTreatment() throws {
        let button = try source("AfterStormApp/Design/PremiumButtonStyle.swift")
        XCTAssertTrue(button.contains("RadialGradient"))
        XCTAssertTrue(button.contains("specularBand"))
        XCTAssertTrue(button.contains("accessibilityReduceTransparency"))
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(_ relativePath: String) throws -> String {
        try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
```

- [ ] **Step 2: Commit only the test file and allow the Xcode 26.3 mirror push workflow to run**

Expected: `swift test` fails because the shared icon-well modifier and `specularBand` tokens do not exist yet.

---

### Task 2: Strengthen the shared adaptive-glass optics

**Files:**
- Modify: `AfterStormApp/Design/AdaptiveGlassSurface.swift`

**Interfaces:**
- Consumes: `RestorationVisualState` through `afterStormVisualState`, existing `AdaptiveGlassProminence`, `adaptiveGlass`, and `hybridGlassTile` APIs.
- Produces: stronger base optics plus `hybridGlassIconWell(cornerRadius:selected:)` for reusable Quest-flow icon wells.

- [ ] **Step 1: Reduce tint density and strengthen broad environmental reflection**

Tune `AdaptiveGlassProminence.tintMultiplier` downward for `.standard`, `.tile`, `.hero`, and `.control` while retaining higher opacity for reduced-transparency mode. Add a broad top-left radial reflection and a diagonal `specularBand` overlay inside `AdaptiveGlassSurfaceModifier` so large surfaces receive visible environmental light, not only a thin perimeter highlight.

- [ ] **Step 2: Preserve and reinforce inner/outer crystal rims**

Keep the current outer `crystalHighlight` and add/strengthen the inset rim so card centers remain dark while their thickness is perceptible.

- [ ] **Step 3: Create one reusable icon-well modifier**

```swift
private struct HybridGlassIconWellModifier: ViewModifier {
    @Environment(\.afterStormVisualState) private var visualState
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let cornerRadius: CGFloat
    let selected: Bool

    func body(content: Content) -> some View {
        // ultraThinMaterial + restrained tint + radial crystal bloom + dual rim + adaptive glow
    }
}

extension View {
    func hybridGlassIconWell(cornerRadius: CGFloat = 15, selected: Bool = false) -> some View {
        modifier(HybridGlassIconWellModifier(cornerRadius: cornerRadius, selected: selected))
    }
}
```

The modifier must respect `accessibilityReduceTransparency` and must remain compact enough for 43-58 pt icon wells.

- [ ] **Step 4: Run the relevant source-contract tests conceptually through CI after the implementation commit**

Expected: Task 1 core-glass test turns green.

---

### Task 3: Apply the shared glass language across Quests surfaces

**Files:**
- Modify: `AfterStormApp/Main/QuestsView.swift`
- Modify: `AfterStormApp/Onboarding/FirstQuestView.swift`
- Modify: `AfterStormApp/Onboarding/LifeAreaSelectionView.swift`
- Modify: `AfterStormApp/Design/PremiumButtonStyle.swift`

**Interfaces:**
- Consumes: `adaptiveGlass`, `hybridGlassTile`, `hybridGlassIconWell`, `HybridGlassChipStyle`, and the existing `afterStormVisualState` environment.
- Produces: consistent cards, icon wells, filter controls, CTAs, Life Area tiles, and bottom dock visuals without changing their actions/data flow.

- [ ] **Step 1: Upgrade Main Quests discovery cards**

Change `QuestDiscoveryCard` from `.adaptiveGlass(... prominence: .standard)` to the stronger shared glass treatment while retaining layout and content. Replace its hand-built icon-well background with `.hybridGlassIconWell(cornerRadius: 15)`.

- [ ] **Step 2: Upgrade First Quest cards and CTA**

Replace the hand-built bolt well with `.hybridGlassIconWell(cornerRadius: 18)`. Use the stronger card surface and set the `Give Me a Quest` CTA to `PremiumButtonStyle(prominent: true)` so the hero action is visually above passive cards.

- [ ] **Step 3: Upgrade Life Area icon wells and dock consistency**

Replace the Life Area icon's hand-built glass recipe with `.hybridGlassIconWell(cornerRadius: 14, selected: selected)`. Keep the tile's `.hybridGlassTile` treatment and the bottom dock's `.adaptiveGlassSurface(cornerRadius: 26, prominence: .control)` so enabled and disabled states remain recognizably glass.

- [ ] **Step 4: Strengthen PremiumButtonStyle optics**

Add a broad `RadialGradient` reflection plus a reusable local `specularBand` view/overlay, retain dual rims and adaptive shadows, and lower the opaque tint slightly when transparency is allowed. Disabled appearance remains controlled by the calling view's opacity but must still visibly retain material/rims.

- [ ] **Step 5: Re-run all Swift tests**

Expected: all source-contract and existing core tests pass.

---

### Task 4: Full simulator/build/package verification

**Files:**
- No production-file changes unless verification exposes a real build defect.

**Interfaces:**
- Consumes: existing `.github/workflows/swift-core-diagnostic.yml` push workflow.
- Produces: verified Appetize-ready simulator ZIP and evidence logs.

- [ ] **Step 1: Confirm asset generation succeeds**

Workflow commands:

```bash
python3 scripts/generate-assets.py
python3 scripts/generate-storm-atmosphere.py
```

Expected: `StormAtmosphere.imageset/storm-atmosphere.png` exists and is non-empty.

- [ ] **Step 2: Confirm XcodeGen succeeds**

```bash
xcodegen generate
```

Expected: `AfterStorm.xcodeproj` exists.

- [ ] **Step 3: Confirm full Xcode 26.3 simulator build succeeds**

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

- [ ] **Step 4: Verify app and widget artifacts**

Required paths:
- `DerivedData/Build/Products/Debug-iphonesimulator/AfterStorm.app/Info.plist`
- `DerivedData/Build/Products/Debug-iphonesimulator/AfterStorm.app/PlugIns/AfterStormWidget.appex/Info.plist`

- [ ] **Step 5: Verify Appetize ZIP**

Use the existing workflow packaging step with `/usr/bin/ditto`, then confirm the archive contains:

```text
AfterStorm.app/Info.plist
AfterStorm.app/PlugIns/AfterStormWidget.appex/Info.plist
```

Record the SHA-256 emitted by the workflow.

- [ ] **Step 6: Download the successful workflow artifact and independently inspect the packaged simulator ZIP**

Final report must include files changed, visual changes, exact test result, exact Xcode result, ZIP verification result, final commit SHA, and Appetize-ready ZIP name/path.
