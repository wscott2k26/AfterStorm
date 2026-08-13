# AfterStorm Reactive Visual Luxury System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn AfterStorm’s current clean dark UI into a reactive premium visual system with a realistic living storm atmosphere, restoration-driven gradients, adaptive smoked-to-clear glass, blue/teal/gold accent evolution, and tactile cinematic presentation.

**Architecture:** A single `RestorationVisualState` derived from real restoration progress is injected at the app root through SwiftUI environment. Reusable `AdaptiveStormBackground` and `AdaptiveGlassSurface` components consume that state plus existing sensory/accessibility preferences so every upgraded screen shares one visual language instead of hand-tuned colors. Existing world progression, quest logic, persistence, audio, and haptics remain intact.

**Tech Stack:** Swift 6, SwiftUI, Observation, SwiftData-backed `AppSessionModel`, existing `ExperiencePreferences`, Core Haptics/audio services, XcodeGen, Xcode 26.3 Azure package-only simulator build, Appetize visual acceptance.

## Global Constraints

- iOS deployment target remains **18.0**.
- Swift version remains **6.0**.
- Work only on `feature/afterstorm-core-slice`; do not merge `main` during this plan.
- Keep Azure `trigger: none` and `pr: none`; do not add automatic macOS CI runs.
- The visual formula is: **real storm atmosphere + reactive restoration gradients + adaptive smoked-to-clear glass + adaptive blue/teal/gold accents + cinematic depth + tactile sensory feedback**.
- The background must visibly evolve continuously from storm to clearing to afterglow; do not use a single 50% theme switch.
- Cinematic/Balanced/Calm/Follow System behavior from `ExperiencePreferences` remains authoritative.
- System Reduce Motion and Reduce Transparency must override decorative effects safely.
- The core quest loop, world progression values, authentication strategy, monetization behavior, and ad strategy are out of scope.
- No primary action may become hidden, clipped, or less readable on compact iPhone/Appetize viewports.
- Do not introduce third-party UI or graphics dependencies.
- Preserve the existing single vertical-scroll Avatar Studio fix.

---

## File Structure

### New focused design units

- `AfterStormApp/Design/AdaptiveVisualEnvironment.swift` — SwiftUI environment key for the current `RestorationVisualState`.
- `AfterStormApp/Design/AdaptiveStormBackground.swift` — reusable layered storm/clearing/afterglow atmosphere.
- `AfterStormApp/Design/AdaptiveGlassSurface.swift` — reusable real-glass surface modifier/container.

### Existing design units to extend

- `AfterStormApp/Design/AfterStormTheme.swift` — add teal, silver, halo, glass-edge, and storm-light constants only; keep it a color/animation token file.
- `AfterStormApp/Design/RestorationVisualState.swift` — become the one source of truth for continuous storm/clearing/afterglow weights, glass tint/opacity, accent mix, and glow strength.
- `AfterStormApp/Design/PremiumButtonStyle.swift` — consume adaptive visual state and render thick glass controls instead of a static gold gradient.

### App integration

- `AfterStormApp/App/AppSessionModel.swift` — expose a read-only `restorationFraction` computed from existing restoration nodes.
- `AfterStormApp/App/RootView.swift` — inject `RestorationVisualState(restorationFraction: model.restorationFraction)` once for the whole app.

### High-impact screens

- `AfterStormApp/Onboarding/LifeAreaSelectionView.swift`
- `AfterStormApp/Onboarding/AvatarChoiceView.swift`
- `AfterStormApp/Onboarding/AvatarStudioView.swift`
- `AfterStormApp/Onboarding/AvatarPreviewView.swift`
- `AfterStormApp/Quest/FirstQuestView.swift`
- `AfterStormApp/Quest/QuestDetailView.swift`
- `AfterStormApp/Quest/QuestCompleteView.swift`
- `AfterStormApp/World/RestorationRevealView.swift`
- `AfterStormApp/World/WorldHomeView.swift`
- `AfterStormApp/Main/MeView.swift`
- `AfterStormApp/Settings/SettingsView.swift`

### Regression contracts

- `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

---

### Task 1: Centralize Continuous Restoration Visual State

**Files:**
- Modify: `AfterStormApp/Design/AfterStormTheme.swift`
- Modify: `AfterStormApp/Design/RestorationVisualState.swift`
- Create: `AfterStormApp/Design/AdaptiveVisualEnvironment.swift`
- Modify: `AfterStormApp/App/AppSessionModel.swift`
- Modify: `AfterStormApp/App/RootView.swift`
- Test: `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

**Interfaces:**
- Consumes: existing `restorationNodes`, `RestorationNode.stage`, `RestorationNode.maxStage`, `AfterStormTheme` colors.
- Produces: `AppSessionModel.restorationFraction: Double`, `EnvironmentValues.afterStormVisualState: RestorationVisualState`, continuous `stormWeight`, `clearingWeight`, `afterglowWeight`, `glassTint`, `glassOpacity`, `accentPrimary`, `accentSecondary`, and `glowIntensity`.

- [ ] **Step 1: Add failing source-contract tests for the adaptive visual engine**

Add this test to `BuildCompatibilityTests.swift`:

```swift
func testReactiveVisualStateIsContinuousAndInjectedAtRoot() throws {
    let visual = try source("AfterStormApp/Design/RestorationVisualState.swift")
    let environment = try source("AfterStormApp/Design/AdaptiveVisualEnvironment.swift")
    let model = try source("AfterStormApp/App/AppSessionModel.swift")
    let root = try source("AfterStormApp/App/RootView.swift")

    for token in ["stormWeight", "clearingWeight", "afterglowWeight", "glassOpacity", "accentPrimary", "accentSecondary"] {
        XCTAssertTrue(visual.contains(token), "Missing adaptive visual token: \(token)")
    }
    XCTAssertFalse(visual.contains("restorationFraction < 0.5 ?"), "Visual progression must not be one hard 50 percent switch.")
    XCTAssertTrue(environment.contains("afterStormVisualState"))
    XCTAssertTrue(model.contains("var restorationFraction: Double"))
    XCTAssertTrue(root.contains(".environment(\\.afterStormVisualState"))
}
```

- [ ] **Step 2: Run the focused regression test and confirm RED**

Run:

```bash
swift test --filter BuildCompatibilityTests/testReactiveVisualStateIsContinuousAndInjectedAtRoot
```

Expected: FAIL because the environment key and continuous tokens are not all present yet.

- [ ] **Step 3: Extend theme tokens without moving view logic into the theme**

Add these constants to `AfterStormTheme.swift`:

```swift
static let electricBlue = Color(red: 0.24, green: 0.62, blue: 0.94)
static let stormTeal = Color(red: 0.18, green: 0.70, blue: 0.72)
static let silverMist = Color(red: 0.72, green: 0.82, blue: 0.88)
static let glassEdge = Color.white.opacity(0.62)
static let stormViolet = Color(red: 0.24, green: 0.22, blue: 0.40)
static let warmRose = Color(red: 0.80, green: 0.43, blue: 0.45)
```

Do not replace existing tokens because the world scene already consumes them.

- [ ] **Step 4: Replace the hard visual switch with continuous state weights**

Update `RestorationVisualState.swift` around this API:

```swift
struct RestorationVisualState: Equatable {
    let restorationFraction: Double

    init(restorationFraction: Double) {
        self.restorationFraction = min(1, max(0, restorationFraction))
    }

    private func clamp(_ value: Double) -> Double { min(1, max(0, value)) }

    var stormWeight: Double { clamp(1.0 - restorationFraction * 1.35) }
    var clearingWeight: Double { clamp(1.0 - abs(restorationFraction - 0.5) * 2.0) }
    var afterglowWeight: Double { clamp((restorationFraction - 0.42) / 0.58) }
    var glowIntensity: Double { 0.28 + clearingWeight * 0.16 + afterglowWeight * 0.30 }
    var glassOpacity: Double { 0.46 - afterglowWeight * 0.13 }

    var accentPrimary: Color {
        restorationFraction < 0.45
            ? AfterStormTheme.electricBlue
            : restorationFraction < 0.78
                ? AfterStormTheme.stormTeal
                : AfterStormTheme.spark
    }

    var accentSecondary: Color {
        restorationFraction < 0.45
            ? AfterStormTheme.rainBlue
            : restorationFraction < 0.78
                ? AfterStormTheme.silverMist
                : AfterStormTheme.afterglow
    }

    var glassTint: Color {
        AfterStormTheme.deepSky.opacity(stormWeight * 0.62)
            .mix(with: AfterStormTheme.clearingSky, amount: clearingWeight * 0.45)
            .mix(with: AfterStormTheme.afterglowSky, amount: afterglowWeight * 0.38)
    }
}
```

Implement the `Color.mix(with:amount:)` helper locally using explicit RGB tuples defined in this file so it remains deterministic. The accent can move through discrete anchor colors while the background/glass/glow progression remains continuous; do not retain the current single 50% visual split.

- [ ] **Step 5: Add the SwiftUI environment key**

Create `AdaptiveVisualEnvironment.swift`:

```swift
import SwiftUI

private struct AfterStormVisualStateKey: EnvironmentKey {
    static let defaultValue = RestorationVisualState(restorationFraction: 0)
}

extension EnvironmentValues {
    var afterStormVisualState: RestorationVisualState {
        get { self[AfterStormVisualStateKey.self] }
        set { self[AfterStormVisualStateKey.self] = newValue }
    }
}
```

- [ ] **Step 6: Expose real progress from `AppSessionModel`**

Add:

```swift
var restorationFraction: Double {
    let restored = restorationNodes.reduce(0) { $0 + $1.stage }
    let total = max(24, restorationNodes.reduce(0) { $0 + $1.maxStage })
    guard total > 0 else { return 0 }
    return min(1, Double(restored) / Double(total))
}
```

Do not duplicate or mutate restoration state.

- [ ] **Step 7: Inject one visual state at `RootView`**

Apply to the root ZStack/content boundary:

```swift
.environment(
    \.afterStormVisualState,
    RestorationVisualState(restorationFraction: model.restorationFraction)
)
```

- [ ] **Step 8: Run the focused test and source parser**

```bash
swift test --filter BuildCompatibilityTests/testReactiveVisualStateIsContinuousAndInjectedAtRoot
swiftc -parse AfterStormApp/Design/RestorationVisualState.swift AfterStormApp/Design/AdaptiveVisualEnvironment.swift
```

Expected: PASS / parse exit 0.

- [ ] **Step 9: Commit Task 1**

```bash
git add AfterStormApp/Design/AfterStormTheme.swift AfterStormApp/Design/RestorationVisualState.swift AfterStormApp/Design/AdaptiveVisualEnvironment.swift AfterStormApp/App/AppSessionModel.swift AfterStormApp/App/RootView.swift Tests/AfterStormCoreTests/BuildCompatibilityTests.swift
git commit -m "feat: centralize reactive restoration visuals"
```

---

### Task 2: Build the Living Storm Background

**Files:**
- Create: `AfterStormApp/Design/AdaptiveStormBackground.swift`
- Test: `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

**Interfaces:**
- Consumes: `@Environment(\.afterStormVisualState)`, `ExperiencePreferences.shared`, `accessibilityReduceMotion`, `accessibilityReduceTransparency`.
- Produces: `AdaptiveStormBackground` reusable on onboarding, quest, Me, and Settings screens.

- [ ] **Step 1: Add a failing structural contract for a layered atmospheric background**

```swift
func testAdaptiveStormBackgroundHasLayeredAtmosphereAndAccessibilityGates() throws {
    let source = try source("AfterStormApp/Design/AdaptiveStormBackground.swift")
    for token in ["afterStormVisualState", "accessibilityReduceMotion", "accessibilityReduceTransparency", "Canvas", "RadialGradient", "LinearGradient", "stormWeight", "afterglowWeight"] {
        XCTAssertTrue(source.contains(token), "Missing storm background token: \(token)")
    }
}
```

- [ ] **Step 2: Run the test and confirm RED**

```bash
swift test --filter BuildCompatibilityTests/testAdaptiveStormBackgroundHasLayeredAtmosphereAndAccessibilityGates
```

Expected: FAIL because the file does not exist.

- [ ] **Step 3: Implement a realistic layered atmosphere**

Create `AdaptiveStormBackground.swift` with this structure:

```swift
import SwiftUI

struct AdaptiveStormBackground: View {
    @Environment(\.afterStormVisualState) private var visualState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var drift = false
    @State private var breathe = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        AfterStormTheme.deepSky,
                        AfterStormTheme.stormBlue.opacity(0.78 + visualState.stormWeight * 0.18),
                        AfterStormTheme.clearingSky.opacity(0.20 + visualState.clearingWeight * 0.54),
                        AfterStormTheme.stormTeal.opacity(visualState.clearingWeight * 0.34),
                        AfterStormTheme.warmRose.opacity(visualState.afterglowWeight * 0.30),
                        AfterStormTheme.afterglow.opacity(visualState.afterglowWeight * 0.26)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [visualState.accentPrimary.opacity(visualState.glowIntensity), .clear],
                    center: UnitPoint(x: 0.72, y: 0.23),
                    startRadius: 5,
                    endRadius: proxy.size.width * 0.72
                )
                .blendMode(.screen)

                atmosphericCloudLayer(size: proxy.size)
                mistLayer
                reflectedGlow(size: proxy.size)
            }
        }
        .ignoresSafeArea()
        .task(id: reduceMotion) {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) { drift = true }
            withAnimation(.easeInOut(duration: 4.6).repeatForever(autoreverses: true)) { breathe = true }
        }
        .accessibilityHidden(true)
    }
}
```

Use `Canvas` for 6-10 broad blurred cloud masses with deterministic positions rather than dozens of small particles. Use opacity, blur, scale, and tiny offsets to create depth. Keep lightning as a restrained light bloom tied to `ExperiencePreferences.shared.lightningEffectsEnabled`, not a full-screen white flash. When Reduce Motion is on, the same layers render statically.

- [ ] **Step 4: Add Reduced Transparency fallback**

When `reduceTransparency` is true, increase the base gradient’s darkness/opacity and do not rely on translucent separation. Keep the rich gradient visible.

- [ ] **Step 5: Run focused tests and parse**

```bash
swift test --filter BuildCompatibilityTests/testAdaptiveStormBackgroundHasLayeredAtmosphereAndAccessibilityGates
swiftc -parse AfterStormApp/Design/AdaptiveStormBackground.swift
```

- [ ] **Step 6: Commit Task 2**

```bash
git add AfterStormApp/Design/AdaptiveStormBackground.swift Tests/AfterStormCoreTests/BuildCompatibilityTests.swift
git commit -m "feat: add living reactive storm background"
```

---

### Task 3: Build Adaptive Real-Glass Surfaces and Buttons

**Files:**
- Create: `AfterStormApp/Design/AdaptiveGlassSurface.swift`
- Modify: `AfterStormApp/Design/PremiumButtonStyle.swift`
- Test: `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

**Interfaces:**
- Consumes: `afterStormVisualState`, Reduce Transparency, Reduce Motion, existing `PremiumButtonStyle(prominent:)` call sites.
- Produces: `.adaptiveGlassSurface(cornerRadius:prominence:)`, `AdaptiveGlassProminence`, upgraded `PremiumButtonStyle` without changing its public initializer.

- [ ] **Step 1: Add RED contracts for optical-depth glass**

```swift
func testAdaptiveGlassUsesMaterialTintEdgeLightAndDepth() throws {
    let glass = try source("AfterStormApp/Design/AdaptiveGlassSurface.swift")
    let button = try source("AfterStormApp/Design/PremiumButtonStyle.swift")

    for token in ["ultraThinMaterial", "LinearGradient", "afterStormVisualState", "accessibilityReduceTransparency", "shadow"] {
        XCTAssertTrue(glass.contains(token), "Missing glass optical-depth token: \(token)")
    }
    XCTAssertTrue(button.contains("afterStormVisualState"))
    XCTAssertTrue(button.contains("configuration.isPressed"))
}
```

- [ ] **Step 2: Run and confirm RED**

```bash
swift test --filter BuildCompatibilityTests/testAdaptiveGlassUsesMaterialTintEdgeLightAndDepth
```

- [ ] **Step 3: Implement a reusable glass modifier**

Create:

```swift
import SwiftUI

enum AdaptiveGlassProminence {
    case subtle
    case standard
    case hero
    case control
}

private struct AdaptiveGlassSurfaceModifier: ViewModifier {
    @Environment(\.afterStormVisualState) private var visualState
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let cornerRadius: CGFloat
    let prominence: AdaptiveGlassProminence

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            .background {
                shape
                    .fill(reduceTransparency ? AnyShapeStyle(visualState.glassTint.opacity(0.92)) : AnyShapeStyle(.ultraThinMaterial))
                    .overlay { shape.fill(visualState.glassTint.opacity(reduceTransparency ? 0.18 : visualState.glassOpacity)) }
                    .overlay {
                        shape.fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(prominence == .hero ? 0.22 : 0.14),
                                    visualState.accentPrimary.opacity(prominence == .control ? 0.16 : 0.08),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    .overlay {
                        shape.stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.52), visualState.accentSecondary.opacity(0.32), .white.opacity(0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                    }
                    .shadow(color: visualState.accentPrimary.opacity(prominence == .hero ? 0.17 : 0.08), radius: 22, y: 8)
                    .shadow(color: .black.opacity(0.30), radius: 28, y: 14)
            }
    }
}

extension View {
    func adaptiveGlassSurface(cornerRadius: CGFloat = 24, prominence: AdaptiveGlassProminence = .standard) -> some View {
        modifier(AdaptiveGlassSurfaceModifier(cornerRadius: cornerRadius, prominence: prominence))
    }
}
```

- [ ] **Step 4: Upgrade `PremiumButtonStyle` while preserving its API**

Keep `var prominent = true`. Read `@Environment(\.afterStormVisualState)` and render:
- adaptive material/tint background;
- top-left white edge highlight;
- adaptive accent inner glow;
- stronger shadow when released;
- 0.965 pressed scale when motion is allowed;
- subtle highlight compression when pressed.

Do not hard-code gold as the only prominent fill.

- [ ] **Step 5: Verify**

```bash
swift test --filter BuildCompatibilityTests/testAdaptiveGlassUsesMaterialTintEdgeLightAndDepth
swiftc -parse AfterStormApp/Design/AdaptiveGlassSurface.swift AfterStormApp/Design/PremiumButtonStyle.swift
```

- [ ] **Step 6: Commit Task 3**

```bash
git add AfterStormApp/Design/AdaptiveGlassSurface.swift AfterStormApp/Design/PremiumButtonStyle.swift Tests/AfterStormCoreTests/BuildCompatibilityTests.swift
git commit -m "feat: add adaptive real glass surfaces"
```

---

### Task 4: Apply the Luxury System to Onboarding and Avatar Hero Screens

**Files:**
- Modify: `AfterStormApp/Onboarding/LifeAreaSelectionView.swift`
- Modify: `AfterStormApp/Onboarding/AvatarChoiceView.swift`
- Modify: `AfterStormApp/Onboarding/AvatarStudioView.swift`
- Modify: `AfterStormApp/Onboarding/AvatarPreviewView.swift`
- Test: `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

**Interfaces:**
- Consumes: `AdaptiveStormBackground`, `.adaptiveGlassSurface`, `afterStormVisualState`, existing avatar animation preferences and sticky onboarding CTAs.
- Produces: storm-backed onboarding, glass cards/chips, luminous avatar hero stage, no nested horizontal scrolling.

- [ ] **Step 1: Add a regression contract that protects both luxury and the scrolling fix**

```swift
func testOnboardingUsesAdaptiveStormAndGlassWithoutNestedHorizontalScroll() throws {
    let life = try source("AfterStormApp/Onboarding/LifeAreaSelectionView.swift")
    let choice = try source("AfterStormApp/Onboarding/AvatarChoiceView.swift")
    let studio = try source("AfterStormApp/Onboarding/AvatarStudioView.swift")
    let preview = try source("AfterStormApp/Onboarding/AvatarPreviewView.swift")

    XCTAssertTrue(life.contains("AdaptiveStormBackground"))
    XCTAssertTrue(choice.contains("adaptiveGlassSurface"))
    XCTAssertTrue(studio.contains("AdaptiveStormBackground"))
    XCTAssertTrue(studio.contains("adaptiveGlassSurface"))
    XCTAssertFalse(studio.contains("ScrollView(.horizontal"))
    XCTAssertTrue(preview.contains("afterStormVisualState"))
}
```

- [ ] **Step 2: Run and confirm RED**

```bash
swift test --filter BuildCompatibilityTests/testOnboardingUsesAdaptiveStormAndGlassWithoutNestedHorizontalScroll
```

- [ ] **Step 3: Give Life Area selection a real storm stage**

Wrap the existing scroll/sticky CTA in:

```swift
ZStack {
    AdaptiveStormBackground()
    existingContent
}
```

Replace flat card backgrounds and bottom dock material with `.adaptiveGlassSurface(...)`. Selected cards use `visualState.accentPrimary`, restrained bloom, and the existing spring/haptic feedback.

- [ ] **Step 4: Upgrade Avatar Choice cards**

Keep the existing two choices and CTA. Put each avatar choice on `.adaptiveGlassSurface(prominence: .hero)`. Selected state receives adaptive accent border/glow rather than a plain tint.

- [ ] **Step 5: Upgrade Avatar Studio without changing scrolling behavior**

Keep one vertical `ScrollView` and the adaptive `LazyVGrid`. Add `AdaptiveStormBackground` behind it. Convert the sticky action dock and picker chips to adaptive glass. Add enough bottom content inset so Accessory remains visible above the dock on compact screens.

- [ ] **Step 6: Turn `AvatarPreviewView` into a hero stage**

Read:

```swift
@Environment(\.afterStormVisualState) private var visualState
```

Keep breathing/blinking behavior, but replace the plain circle halo with layered radial glow using `accentPrimary`, `accentSecondary`, and `glowIntensity`. Add a thin glass-like rim and a faint lower reflection. Calm/Reduce Motion keeps the stage static.

- [ ] **Step 7: Verify focused tests and parser**

```bash
swift test --filter BuildCompatibilityTests/testOnboardingUsesAdaptiveStormAndGlassWithoutNestedHorizontalScroll
swiftc -parse AfterStormApp/Onboarding/LifeAreaSelectionView.swift AfterStormApp/Onboarding/AvatarChoiceView.swift AfterStormApp/Onboarding/AvatarStudioView.swift AfterStormApp/Onboarding/AvatarPreviewView.swift
```

- [ ] **Step 8: Commit Task 4**

```bash
git add AfterStormApp/Onboarding Tests/AfterStormCoreTests/BuildCompatibilityTests.swift
git commit -m "feat: bring reactive glass luxury to onboarding"
```

---

### Task 5: Upgrade Quest Selection, Detail, and Completion

**Files:**
- Modify: `AfterStormApp/Quest/FirstQuestView.swift`
- Modify: `AfterStormApp/Quest/QuestDetailView.swift`
- Modify: `AfterStormApp/Quest/QuestCompleteView.swift`
- Modify: `AfterStormApp/Main/QuestsView.swift` only where it duplicates quest-card presentation used after onboarding.
- Test: `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

**Interfaces:**
- Consumes: same environment visual state, adaptive background/glass, existing quest data, existing sound/haptic calls.
- Produces: premium quest cards, thick glass CTAs, adaptive reward lighting.

- [ ] **Step 1: Add RED contract**

```swift
func testQuestFlowUsesAdaptiveStormGlassAndRewardLighting() throws {
    let first = try source("AfterStormApp/Quest/FirstQuestView.swift")
    let detail = try source("AfterStormApp/Quest/QuestDetailView.swift")
    let complete = try source("AfterStormApp/Quest/QuestCompleteView.swift")

    XCTAssertTrue(first.contains("AdaptiveStormBackground"))
    XCTAssertTrue(first.contains("adaptiveGlassSurface"))
    XCTAssertTrue(detail.contains("adaptiveGlassSurface"))
    XCTAssertTrue(complete.contains("afterStormVisualState"))
    XCTAssertTrue(complete.contains("AdaptiveStormBackground"))
}
```

- [ ] **Step 2: Run and confirm RED**

```bash
swift test --filter BuildCompatibilityTests/testQuestFlowUsesAdaptiveStormGlassAndRewardLighting
```

- [ ] **Step 3: Upgrade quest cards**

Use `.adaptiveGlassSurface(prominence: .standard)` for quest cards. Selected/pressed states add adaptive edge light and a small lift, not a large scale jump. Preserve all quest content and accessibility labels.

- [ ] **Step 4: Upgrade Quest Detail**

Place the metadata block on real glass. Keep `Start Quest` using `PremiumButtonStyle` so it inherits adaptive control styling and existing quest-accepted haptic semantics.

- [ ] **Step 5: Upgrade Quest Complete**

Read `visualState`; color reward particles with `accentPrimary`, `accentSecondary`, and `spark`. Add an atmospheric radial glow behind the completion bolt. Keep the optional after photo and completion action unchanged.

- [ ] **Step 6: Verify**

```bash
swift test --filter BuildCompatibilityTests/testQuestFlowUsesAdaptiveStormGlassAndRewardLighting
swiftc -parse AfterStormApp/Quest/FirstQuestView.swift AfterStormApp/Quest/QuestDetailView.swift AfterStormApp/Quest/QuestCompleteView.swift
```

- [ ] **Step 7: Commit Task 5**

```bash
git add AfterStormApp/Quest AfterStormApp/Main/QuestsView.swift Tests/AfterStormCoreTests/BuildCompatibilityTests.swift
git commit -m "feat: give quest flow adaptive premium depth"
```

---

### Task 6: Upgrade Restoration Reveal and Main World Glass Dock

**Files:**
- Modify: `AfterStormApp/World/RestorationRevealView.swift`
- Modify: `AfterStormApp/World/WorldHomeView.swift`
- Modify: `AfterStormApp/World/WorldDioramaView.swift` only for atmosphere/light values that directly consume `RestorationVisualState`; do not restructure existing buildings/trees/lights.
- Test: `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

**Interfaces:**
- Consumes: current world scene, real restoration fraction/environment, adaptive glass and accent, existing motion transaction gate, existing audio/haptics.
- Produces: world remains hero, glass dock visibly reflects progress, restoration reveal uses adaptive light.

- [ ] **Step 1: Add RED world contract**

```swift
func testWorldKeepsDioramaHeroAndUsesAdaptiveGlassLighting() throws {
    let home = try source("AfterStormApp/World/WorldHomeView.swift")
    let reveal = try source("AfterStormApp/World/RestorationRevealView.swift")

    XCTAssertTrue(home.contains("adaptiveGlassSurface"))
    XCTAssertTrue(home.contains("afterStormVisualState"))
    XCTAssertTrue(home.contains("transaction.disablesAnimations"), "Keep the app-level motion gate introduced for accessibility/settings.")
    XCTAssertFalse(home.contains(".environment(\\.accessibilityReduceMotion"), "System Reduce Motion is read-only and must never be overridden.")
    XCTAssertTrue(reveal.contains("adaptiveGlassSurface"))
    XCTAssertTrue(reveal.contains("afterStormVisualState"))
}
```

- [ ] **Step 2: Run and confirm RED**

```bash
swift test --filter BuildCompatibilityTests/testWorldKeepsDioramaHeroAndUsesAdaptiveGlassLighting
```

- [ ] **Step 3: Make the Main World control dock real glass**

Read the environment visual state in `WorldHomeView`. Replace the current static `.ultraThinMaterial` dock background/white stroke with `.adaptiveGlassSurface(cornerRadius: 26, prominence: .hero)`. Use the adaptive accent for the restoration percentage badge and selected/important light.

- [ ] **Step 4: Preserve the diorama as the hero**

Do not add a full-screen opaque background over `WorldDioramaView`. If additional glow is needed, layer a low-opacity radial atmosphere behind or around the diorama. Keep the current buildings, road reflections, trees, residents, lamps, and progress behavior.

- [ ] **Step 5: Make Restoration Reveal inherit the world’s current light**

Read `visualState`; drive pulse/halo colors from adaptive accent and use `.adaptiveGlassSurface(prominence: .hero)` for the bottom reveal card. Keep `AudioService.shared.playRestoration()` and `HapticsService.majorRestoration()` semantics intact.

- [ ] **Step 6: Verify**

```bash
swift test --filter BuildCompatibilityTests/testWorldKeepsDioramaHeroAndUsesAdaptiveGlassLighting
swiftc -parse AfterStormApp/World/WorldHomeView.swift AfterStormApp/World/RestorationRevealView.swift
```

- [ ] **Step 7: Commit Task 6**

```bash
git add AfterStormApp/World Tests/AfterStormCoreTests/BuildCompatibilityTests.swift
git commit -m "feat: make world restoration glass react to progress"
```

---

### Task 7: Upgrade Me and Settings Without Hiding the Storm

**Files:**
- Modify: `AfterStormApp/Main/MeView.swift`
- Modify: `AfterStormApp/Settings/SettingsView.swift`
- Test: `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

**Interfaces:**
- Consumes: `AdaptiveStormBackground`, adaptive glass modifier, existing Settings controls and sheets.
- Produces: premium profile/settings surfaces while all sensory controls remain intact.

- [ ] **Step 1: Add RED contract**

```swift
func testMeAndSettingsUseLuxurySystemWithoutRemovingControls() throws {
    let me = try source("AfterStormApp/Main/MeView.swift")
    let settings = try source("AfterStormApp/Settings/SettingsView.swift")

    XCTAssertTrue(me.contains("AdaptiveStormBackground"))
    XCTAssertTrue(me.contains("adaptiveGlassSurface"))
    XCTAssertTrue(settings.contains("AdaptiveStormBackground"))
    XCTAssertTrue(settings.contains("Sound & Haptics"))
    XCTAssertTrue(settings.contains("Lightning & Flash"))
    XCTAssertTrue(settings.contains("Avatar Animation"))
}
```

- [ ] **Step 2: Run and confirm RED**

```bash
swift test --filter BuildCompatibilityTests/testMeAndSettingsUseLuxurySystemWithoutRemovingControls
```

- [ ] **Step 3: Upgrade Me**

Place `AdaptiveStormBackground` behind the scroll view. Keep `AvatarPreviewView` as the profile hero. Replace each menu row’s flat material background with adaptive glass and keep the exact destinations/actions.

- [ ] **Step 4: Upgrade Settings**

Keep `Form`, `.scrollContentBackground(.hidden)`, and all current toggles. Put `AdaptiveStormBackground` behind the form. Where SwiftUI `Form` row chrome remains too opaque, use clear list-row backgrounds and group sections visually with restrained adaptive tint. Do not create a custom settings framework in this pass.

- [ ] **Step 5: Verify**

```bash
swift test --filter BuildCompatibilityTests/testMeAndSettingsUseLuxurySystemWithoutRemovingControls
swiftc -parse AfterStormApp/Main/MeView.swift AfterStormApp/Settings/SettingsView.swift
```

- [ ] **Step 6: Commit Task 7**

```bash
git add AfterStormApp/Main/MeView.swift AfterStormApp/Settings/SettingsView.swift Tests/AfterStormCoreTests/BuildCompatibilityTests.swift
git commit -m "feat: extend adaptive luxury to me and settings"
```

---

### Task 8: Full Regression, Xcode Build, and Appetize Visual Acceptance

**Files:**
- Verify: all files touched in Tasks 1-7.
- Modify only if verification exposes a concrete defect.

**Interfaces:**
- Consumes: completed luxury pass.
- Produces: evidence for code integrity and visual acceptance; no completion claim without these gates.

- [ ] **Step 1: Run all Swift package tests**

```bash
swift test
```

Expected: all tests PASS, including existing Xcode-26 multimodal gate, package verification, onboarding sticky-action contracts, sensory settings contracts, and new visual-luxury contracts.

- [ ] **Step 2: Parse all new/changed design and UI files locally**

```bash
swiftc -parse \
  AfterStormApp/Design/AfterStormTheme.swift \
  AfterStormApp/Design/RestorationVisualState.swift \
  AfterStormApp/Design/AdaptiveVisualEnvironment.swift \
  AfterStormApp/Design/AdaptiveStormBackground.swift \
  AfterStormApp/Design/AdaptiveGlassSurface.swift \
  AfterStormApp/Design/PremiumButtonStyle.swift \
  AfterStormApp/Onboarding/LifeAreaSelectionView.swift \
  AfterStormApp/Onboarding/AvatarChoiceView.swift \
  AfterStormApp/Onboarding/AvatarStudioView.swift \
  AfterStormApp/Onboarding/AvatarPreviewView.swift \
  AfterStormApp/Quest/FirstQuestView.swift \
  AfterStormApp/Quest/QuestDetailView.swift \
  AfterStormApp/Quest/QuestCompleteView.swift \
  AfterStormApp/World/WorldHomeView.swift \
  AfterStormApp/World/RestorationRevealView.swift \
  AfterStormApp/Main/MeView.swift \
  AfterStormApp/Settings/SettingsView.swift
```

Expected: exit 0.

- [ ] **Step 3: Re-check Azure remains manual/package-only**

Verify `azure-pipelines.yml` still contains:

```yaml
trigger: none
pr: none
```

and contains no `simctl boot`, `bootstatus`, or other hosted simulator boot step.

- [ ] **Step 4: Run exactly one manual Azure build on the feature branch**

Pipeline: `https://dev.azure.com/StormAndMeApps/AfterStorm/_build?definitionId=1`

Branch:

```text
feature/afterstorm-core-slice
```

Leave the commit field blank so Azure uses the latest branch head.

Expected steps:
- Swift core tests pass;
- deterministic assets generate;
- XcodeGen generates the project;
- Xcode 26.3 generic iOS Simulator build succeeds;
- `AfterStorm-simulator.app.zip` packages successfully;
- `zip-contents.txt` and SHA-256 artifact publish.

Do not blind-rerun a failure. Diagnose the exact failed step first.

- [ ] **Step 5: Replace the Appetize build with the fresh Azure ZIP**

Upload `AfterStorm-simulator.app.zip` from `afterstorm-simulator-build` to Appetize.

- [ ] **Step 6: Perform compact-iPhone visual acceptance**

Verify these states manually:

```text
1. Life Areas: layered storm visible behind content; Continue remains visible.
2. Avatar Choice: choice cards read as real glass, not gray boxes.
3. Avatar Studio: Eyes, Outfit, Accessory reachable with one vertical scroll; hero glow is visible.
4. First Quest / Quest Detail: cards and CTA have optical depth and adaptive edge light.
5. Quest Complete: reward burst and glow feel richer without obscuring text.
6. Restoration Reveal: world remains visible; reveal card looks suspended above it.
7. Main World: dock is translucent dimensional glass; diorama remains the hero.
8. Me / Settings: storm remains visible and all controls stay readable.
9. Cinematic: background/glow/motion visibly richer.
10. Calm: gradients and glass remain premium while nonessential motion is reduced.
```

- [ ] **Step 7: Check restoration color progression**

Inspect low, middle, and high restoration states:

```text
low: navy/electric blue + smoked glass
middle: visible teal/silver clearing light
high: warm gold/rose afterglow mixed with residual blue/teal
```

Reject the pass if the transition still reads as a binary theme switch or if the gradient is too subtle to notice.

- [ ] **Step 8: Final verification report**

Report separately:
- package test count and failures;
- parse result;
- Azure Xcode result and commit SHA;
- Appetize acceptance screens checked;
- any remaining visual gaps.

Only after all four evidence groups are fresh may the visual-luxury pass be called complete.
