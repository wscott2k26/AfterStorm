# Quests Hybrid Glass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Quests screen unmistakably read as dark luxury glass with crystal highlights while preserving quest behavior, readability, accessibility, and the existing storm atmosphere.

**Architecture:** Keep `AdaptiveGlassSurface.swift` as the centralized optical glass primitive and add one reusable compact glass-chip button style there. Make `QuestsView.swift` consume the centralized glass system for cards and filters, switch its backdrop to `AdaptiveStormBackground`, and keep `PremiumButtonStyle` as the CTA foundation unless a targeted prominence adjustment is required. Add source-contract regression tests before production changes and verify the exact macOS 15/Xcode 26.3 simulator pipeline.

**Tech Stack:** SwiftUI, XCTest source-contract tests, Xcode 26.3, XcodeGen, GitHub Actions macOS-15 mirror build.

## Global Constraints

- Branch: `feature/afterstorm-core-slice`.
- Do not change quest logic, persistence, AI/network behavior, onboarding, monetization, accounts, or unrelated tabs.
- Preserve `accessibilityReduceTransparency` and `accessibilityReduceMotion` behavior.
- Use `afterStormVisualState`; do not hard-code the entire glass language to one static blue.
- No continuous shimmer loops or distracting animation refactors.
- Completion requires Swift tests, full Xcode 26.3 simulator build, widget verification, and verified Appetize ZIP.

---

### Task 1: Add Quests Glass Regression Contracts

**Files:**
- Modify: `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

**Interfaces:**
- Consumes: source files `AfterStormApp/Main/QuestsView.swift` and `AfterStormApp/Design/AdaptiveGlassSurface.swift`.
- Produces: regression contracts that require `AdaptiveStormBackground`, `adaptiveGlass`, `HybridGlassChipStyle`, `crystalHighlight`, and the absence of default `.buttonStyle(.bordered)` use on Quests filters.

- [ ] **Step 1: Write the failing tests**

Add:

```swift
func testQuestsScreenUsesHybridGlassSystem() throws {
    let quests = try source("AfterStormApp/Main/QuestsView.swift")

    XCTAssertTrue(quests.contains("AdaptiveStormBackground"))
    XCTAssertTrue(quests.contains("adaptiveGlass"))
    XCTAssertTrue(quests.contains("HybridGlassChipStyle"))
    XCTAssertFalse(quests.contains(".buttonStyle(.bordered)"))
}

func testAdaptiveGlassExposesCrystalHighlightLayer() throws {
    let glass = try source("AfterStormApp/Design/AdaptiveGlassSurface.swift")

    XCTAssertTrue(glass.contains("crystalHighlight"))
    XCTAssertTrue(glass.contains("HybridGlassChipStyle"))
    XCTAssertTrue(glass.contains("accessibilityReduceTransparency"))
    XCTAssertTrue(glass.contains("afterStormVisualState"))
}
```

- [ ] **Step 2: Run the tests and verify RED**

Run on macOS 15 / Xcode 26.3:

```bash
swift test --filter BuildCompatibilityTests
```

Expected: FAIL because `QuestsView` does not yet contain `AdaptiveStormBackground`, `adaptiveGlass`, or `HybridGlassChipStyle`, and the glass component does not yet expose `crystalHighlight` or `HybridGlassChipStyle`.

- [ ] **Step 3: Commit the RED contracts**

```bash
git add Tests/AfterStormCoreTests/BuildCompatibilityTests.swift
git commit -m "test: define quests hybrid glass contracts"
```

---

### Task 2: Strengthen the Central Adaptive Glass Primitive

**Files:**
- Modify: `AfterStormApp/Design/AdaptiveGlassSurface.swift`

**Interfaces:**
- Consumes: `RestorationVisualState` from `afterStormVisualState`, `AdaptiveGlassProminence`, accessibility transparency setting, `AfterStormTheme.quickSpring`.
- Produces: existing `adaptiveGlass(...)`, existing `adaptiveGlassSurface(...)`, private `crystalHighlight(...)`, and reusable `HybridGlassChipStyle(selected: Bool)`.

- [ ] **Step 1: Implement the crystal-highlight helper and stronger optical stack**

Inside `AdaptiveGlassSurfaceModifier`, keep the material/tint base and add a dedicated helper with the literal name required by the contract:

```swift
@ViewBuilder
private func crystalHighlight(_ shape: RoundedRectangle) -> some View {
    shape
        .stroke(
            LinearGradient(
                colors: [
                    .white.opacity(prominence == .hero ? 0.72 : 0.54),
                    visualState.accentPrimary.opacity(0.26),
                    .white.opacity(0.04),
                    visualState.accentSecondary.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: prominence == .hero ? 1.35 : 1.0
        )
        .blendMode(.screen)
}
```

Use this helper in the overlay and add an internal top-left specular wash:

```swift
shape
    .fill(
        LinearGradient(
            colors: [
                .white.opacity(prominence == .hero ? 0.20 : 0.13),
                visualState.accentPrimary.opacity(0.08),
                .clear
            ],
            startPoint: .topLeading,
            endPoint: .center
        )
    )
    .blendMode(.screen)
```

Keep Reduce Transparency on an opaque/readable fallback.

- [ ] **Step 2: Add reusable compact `HybridGlassChipStyle`**

Add a `ButtonStyle` in the same file:

```swift
struct HybridGlassChipStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.afterStormVisualState) private var visualState

    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let shape = Capsule(style: .continuous)

        return configuration.label
            .font(.subheadline.weight(selected ? .semibold : .medium))
            .foregroundStyle(selected ? Color.white : Color.white.opacity(0.80))
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background {
                ZStack {
                    if reduceTransparency {
                        shape.fill(visualState.glassTint.opacity(selected ? 0.96 : 0.90))
                    } else {
                        shape.fill(.ultraThinMaterial)
                        shape.fill(visualState.glassTint.opacity(selected ? 0.34 : 0.20))
                    }

                    shape.fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(selected ? 0.16 : 0.08),
                                visualState.accentPrimary.opacity(selected ? 0.30 : 0.08),
                                visualState.accentSecondary.opacity(selected ? 0.14 : 0.04),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
                }
            }
            .overlay {
                shape.stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(selected ? 0.62 : 0.26),
                            visualState.accentPrimary.opacity(selected ? 0.46 : 0.14),
                            visualState.accentSecondary.opacity(selected ? 0.22 : 0.08),
                            .white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: selected ? 1.1 : 0.8
                )
            }
            .shadow(
                color: visualState.accentPrimary.opacity(selected ? 0.22 : 0.06),
                radius: selected ? 11 : 5,
                y: selected ? 5 : 2
            )
            .shadow(color: .black.opacity(selected ? 0.24 : 0.16), radius: 8, y: 4)
            .scaleEffect(reduceMotion ? 1 : (pressed ? 0.965 : 1))
            .animation(reduceMotion ? nil : AfterStormTheme.quickSpring, value: pressed)
    }
}
```

- [ ] **Step 3: Run targeted tests and verify partial GREEN**

Run:

```bash
swift test --filter BuildCompatibilityTests.testAdaptiveGlassExposesCrystalHighlightLayer
```

Expected: PASS.

The Quests screen contract should still fail because `QuestsView.swift` is not yet migrated.

- [ ] **Step 4: Commit the glass primitive**

```bash
git add AfterStormApp/Design/AdaptiveGlassSurface.swift
git commit -m "feat: deepen adaptive hybrid glass optics"
```

---

### Task 3: Apply Hybrid Glass to the Quests Screen

**Files:**
- Modify: `AfterStormApp/Main/QuestsView.swift`

**Interfaces:**
- Consumes: `AdaptiveStormBackground()`, `adaptiveGlass(cornerRadius:prominence:)`, `HybridGlassChipStyle(selected:)`, `PremiumButtonStyle(prominent:)`, current quest model callbacks.
- Produces: same public `QuestsView` behavior and callbacks with upgraded presentation only.

- [ ] **Step 1: Switch the screen backdrop to the adaptive storm**

Wrap the scroll content in a `ZStack`:

```swift
ZStack {
    AdaptiveStormBackground()

    ScrollView {
        // existing content
    }
}
```

Remove the static `.background(AfterStormTheme.worldGradient.ignoresSafeArea())` from the scroll view.

- [ ] **Step 2: Migrate duration and area filters to `HybridGlassChipStyle`**

Replace each default `.buttonStyle(.bordered)` call with:

```swift
.buttonStyle(HybridGlassChipStyle(selected: timeFilter == value))
```

and for area filters:

```swift
.buttonStyle(HybridGlassChipStyle(selected: selectedArea == nil))
```

or:

```swift
.buttonStyle(HybridGlassChipStyle(selected: selectedArea == area))
```

Keep existing accessibility selected traits.

- [ ] **Step 3: Migrate `QuestDiscoveryCard` to centralized adaptive glass**

Add:

```swift
@Environment(\.afterStormVisualState) private var visualState
```

Replace the plain material background/stroke with:

```swift
.adaptiveGlass(cornerRadius: 22, prominence: .standard)
```

Strengthen the icon well with an inset optical treatment:

```swift
.background {
    RoundedRectangle(cornerRadius: 15, style: .continuous)
        .fill(.ultraThinMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(visualState.accentPrimary.opacity(0.16))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.44), visualState.accentPrimary.opacity(0.34), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        }
}
```

Make the instruction more readable:

```swift
.foregroundStyle(.white.opacity(0.72))
```

Keep reward/time adaptive and bright.

- [ ] **Step 4: Keep CTA as hero glass and make intent explicit**

Use:

```swift
.buttonStyle(PremiumButtonStyle(prominent: true))
```

Do not change the callback or button label.

- [ ] **Step 5: Run both new regression contracts**

Run:

```bash
swift test --filter BuildCompatibilityTests.testQuestsScreenUsesHybridGlassSystem
swift test --filter BuildCompatibilityTests.testAdaptiveGlassExposesCrystalHighlightLayer
```

Expected: PASS.

- [ ] **Step 6: Run all Swift tests**

Run:

```bash
swift test
```

Expected: all tests PASS with zero failures.

- [ ] **Step 7: Commit the Quests migration**

```bash
git add AfterStormApp/Main/QuestsView.swift
git commit -m "feat: apply hybrid glass to quests"
```

---

### Task 4: Full Xcode 26.3 Mirror Verification and Appetize Package

**Files:**
- No production changes expected unless verification exposes a real compiler/runtime packaging issue.
- Evidence generated by CI.

**Interfaces:**
- Consumes: repository HEAD after Tasks 1-3.
- Produces: verified `AfterStorm-simulator.app.zip` artifact and build/test logs.

- [ ] **Step 1: Generate deterministic assets**

```bash
python3 scripts/generate-assets.py
python3 scripts/generate-storm-atmosphere.py
```

Expected: exit 0.

- [ ] **Step 2: Generate Xcode project**

```bash
xcodegen generate
```

Expected: exit 0.

- [ ] **Step 3: Build the app and widget**

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

- [ ] **Step 4: Verify app and widget**

```bash
test -f DerivedData/Build/Products/Debug-iphonesimulator/AfterStorm.app/Info.plist
test -f DerivedData/Build/Products/Debug-iphonesimulator/AfterStorm.app/PlugIns/AfterStormWidget.appex/Info.plist
```

Expected: exit 0.

- [ ] **Step 5: Package and verify Appetize ZIP**

```bash
mkdir -p mirror-artifacts
APP_PATH="DerivedData/Build/Products/Debug-iphonesimulator/AfterStorm.app"
OUTPUT="mirror-artifacts/AfterStorm-simulator.app.zip"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$OUTPUT"
/usr/bin/unzip -Z1 "$OUTPUT" > mirror-artifacts/zip-contents.txt
grep -Fx 'AfterStorm.app/Info.plist' mirror-artifacts/zip-contents.txt
grep -Fx 'AfterStorm.app/PlugIns/AfterStormWidget.appex/Info.plist' mirror-artifacts/zip-contents.txt
/usr/bin/shasum -a 256 "$OUTPUT" | tee mirror-artifacts/AfterStorm-simulator.sha256
```

Expected: both paths found and SHA-256 emitted.

- [ ] **Step 6: Final evidence review**

Confirm:
- Swift tests: zero failures.
- deterministic asset generation: success.
- Xcode 26.3 simulator build: success.
- widget verification: success.
- ZIP verification: success.
- artifact belongs to the final commit SHA.

Only then hand the Appetize ZIP to the user.
