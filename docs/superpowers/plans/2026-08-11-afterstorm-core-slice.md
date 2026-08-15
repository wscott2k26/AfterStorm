# AfterStorm Core Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first production-quality AfterStorm vertical slice: Storm and Me Studios launch, first-run personalization, local quest generation, quest completion, Sparks, and one persistent world restoration.

**Architecture:** Keep all business rules in a platform-neutral `AfterStormCore` Swift package so they can be tested on Linux/macOS without SwiftUI. The iOS app shell depends on the core package and owns SwiftUI presentation, animation, haptics, sound, and RealityKit rendering. Apple Intelligence is an optional adapter behind `QuestEngine`; the tested local engine is always available.

**Tech Stack:** Swift 6, Swift Package Manager, Swift Testing/XCTest-compatible tests for core logic, SwiftUI, SwiftData, RealityKit, AVFoundation, UIKit haptics, XcodeGen project manifest for reproducible Xcode project generation.

## Global Constraints

- Product name: **AfterStorm**.
- Studio name: **Storm and Me Studios**.
- Tagline: **Rebuild your world by rebuilding your day.**
- iPhone-first native app; no web wrapper.
- Important logic gets tests first.
- No giant files or God objects.
- AI logic stays outside UI and must fail gracefully.
- World rendering stays outside quest logic.
- Every completed quest creates a visible payoff.
- One launch currency only: **Sparks**.
- No punitive streaks, fake urgency, or destructive progress.
- Camera images are not stored by default.
- Premium polish is a product requirement, not a post-launch phase.
- V1 core loop must work with Apple Intelligence disabled or unavailable.

---

## File Map

### Core package
- `Package.swift` — platform-neutral package and test targets.
- `Sources/AfterStormCore/Domain/LifeArea.swift` — onboarding categories.
- `Sources/AfterStormCore/Domain/AvatarKind.swift` — human/Stormling selection.
- `Sources/AfterStormCore/Domain/Quest.swift` — quest value model.
- `Sources/AfterStormCore/Domain/RestorationNode.swift` — persistent world node state.
- `Sources/AfterStormCore/Domain/PlayerProgress.swift` — Sparks and completed quests.
- `Sources/AfterStormCore/Questing/QuestEngine.swift` — quest generation contract.
- `Sources/AfterStormCore/Questing/LocalQuestEngine.swift` — deterministic, always-available quest generator.
- `Sources/AfterStormCore/Progress/WorldProgression.swift` — maps quest completions to restoration state.
- `Sources/AfterStormCore/Session/AfterStormSession.swift` — coordinates profile, quests, completion, and progression.

### iOS app
- `project.yml` — XcodeGen manifest for the iOS app and local package dependency.
- `AfterStormApp/App/AfterStormApp.swift` — application entry point.
- `AfterStormApp/App/AppFlow.swift` — launch/onboarding/main flow state.
- `AfterStormApp/App/AppSessionModel.swift` — observable iOS adapter around the tested core session.
- `AfterStormApp/App/RootView.swift` — screen routing for the vertical slice.
- `AfterStormApp/Design/AfterStormTheme.swift` — spacing, typography, materials, gradients, animation constants.
- `AfterStormApp/Design/PremiumButtonStyle.swift` — tactile compression/rebound button treatment.
- `AfterStormApp/Launch/StudioIntroView.swift` — animated Storm and Me Studios intro.
- `AfterStormApp/Onboarding/StormRevealView.swift` — cinematic AfterStorm premise.
- `AfterStormApp/Onboarding/LifeAreaSelectionView.swift` — multi-select onboarding.
- `AfterStormApp/Onboarding/AvatarChoiceView.swift` — human/Stormling choice.
- `AfterStormApp/Onboarding/FirstQuestView.swift` — first 3 personalized quests.
- `AfterStormApp/World/WorldHomeView.swift` — main world shell and restoration state.
- `AfterStormApp/World/WorldDioramaView.swift` — RealityKit-backed diorama when available; premium SwiftUI atmospheric fallback for previews/simulator.
- `AfterStormApp/Quest/QuestDetailView.swift` — quest details and start action.
- `AfterStormApp/Quest/QuestModeView.swift` — focus mode and easier-quest action.
- `AfterStormApp/Quest/QuestCompleteView.swift` — completion confirmation.
- `AfterStormApp/World/RestorationRevealView.swift` — cinematic restoration payoff.
- `AfterStormApp/Services/HapticsService.swift` — semantic haptic signatures.
- `AfterStormApp/Services/AudioService.swift` — restrained intro/completion/restoration audio hooks.

### Tests
- `Tests/AfterStormCoreTests/LocalQuestEngineTests.swift`
- `Tests/AfterStormCoreTests/WorldProgressionTests.swift`
- `Tests/AfterStormCoreTests/AfterStormSessionTests.swift`

---

### Task 1: Establish the testable core package

**Files:**
- Create: `Package.swift`
- Create: `Sources/AfterStormCore/Domain/LifeArea.swift`
- Create: `Sources/AfterStormCore/Domain/AvatarKind.swift`
- Create: `Sources/AfterStormCore/Domain/Quest.swift`
- Test: `Tests/AfterStormCoreTests/LocalQuestEngineTests.swift`

**Interfaces:**
- Produces: `LifeArea`, `AvatarKind`, `Quest`, `QuestEngine` used by all later tasks.

- [ ] **Step 1: Write the failing quest-engine contract test**

```swift
import XCTest
@testable import AfterStormCore

final class LocalQuestEngineTests: XCTestCase {
    func testSuggestionsRespectSelectedLifeAreasAndReturnThreeQuests() async throws {
        let engine = LocalQuestEngine(seed: 7)
        let quests = try await engine.suggestions(for: [.home, .focus], count: 3)

        XCTAssertEqual(quests.count, 3)
        XCTAssertTrue(quests.allSatisfy { [.home, .focus].contains($0.lifeArea) })
        XCTAssertTrue(quests.allSatisfy { $0.sparkReward > 0 })
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter LocalQuestEngineTests`
Expected: FAIL because package/types do not exist.

- [ ] **Step 3: Add minimal package and domain interfaces**

```swift
public enum LifeArea: String, CaseIterable, Codable, Sendable {
    case home, work, focus, digital, movement, learning, lifeAdmin
}

public enum AvatarKind: String, Codable, Sendable { case human, stormling }

public struct Quest: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public let title: String
    public let instruction: String
    public let lifeArea: LifeArea
    public let estimatedMinutes: Int
    public let sparkReward: Int
    public let restorationNodeID: String
}

public protocol QuestEngine: Sendable {
    func suggestions(for areas: Set<LifeArea>, count: Int) async throws -> [Quest]
}
```

- [ ] **Step 4: Implement a deterministic `LocalQuestEngine` with curated templates**

Create at least three templates per launch life area, choose only from selected areas, and support `.all` behavior in the UI by expanding to all concrete areas before calling the engine.

- [ ] **Step 5: Run tests**

Run: `swift test`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add Package.swift Sources Tests
git commit -m "feat: add tested local quest engine"
```

---

### Task 2: Add persistent progression rules

**Files:**
- Create: `Sources/AfterStormCore/Domain/RestorationNode.swift`
- Create: `Sources/AfterStormCore/Domain/PlayerProgress.swift`
- Create: `Sources/AfterStormCore/Progress/WorldProgression.swift`
- Test: `Tests/AfterStormCoreTests/WorldProgressionTests.swift`

**Interfaces:**
- Consumes: `Quest`
- Produces: `RestorationNode`, `PlayerProgress`, `WorldProgression.complete(quest:progress:nodes:)`.

- [ ] **Step 1: Write failing tests for Sparks and visible restoration**

```swift
func testCompletingQuestAwardsSparksAndAdvancesTargetNode() {
    var progress = PlayerProgress()
    var nodes = [RestorationNode(id: "east-lights", title: "East Street Lights", stage: 0, maxStage: 3)]
    let quest = Quest.fixture(restorationNodeID: "east-lights", sparkReward: 15)

    WorldProgression.complete(quest: quest, progress: &progress, nodes: &nodes)

    XCTAssertEqual(progress.sparks, 15)
    XCTAssertEqual(progress.completedQuestCount, 1)
    XCTAssertEqual(nodes[0].stage, 1)
}
```

- [ ] **Step 2: Run failure**

Run: `swift test --filter WorldProgressionTests`
Expected: FAIL because progression types do not exist.

- [ ] **Step 3: Implement minimal progression**

`RestorationNode` stores stable ID, display title, current stage, max stage. `WorldProgression.complete` increments Sparks and completion count and advances only the quest's target node, clamped to max stage.

- [ ] **Step 4: Add no-regression test**

Verify already restored nodes never decrease and completing an unrelated quest does not mutate other nodes.

- [ ] **Step 5: Run full tests and commit**

```bash
swift test
git add Sources Tests
git commit -m "feat: add world restoration progression"
```

---

### Task 3: Add the core session coordinator

**Files:**
- Create: `Sources/AfterStormCore/Session/AfterStormSession.swift`
- Test: `Tests/AfterStormCoreTests/AfterStormSessionTests.swift`

**Interfaces:**
- Consumes: `QuestEngine`, `WorldProgression`.
- Produces: `AfterStormSession.configure(areas:avatarKind:)`, `refreshSuggestions()`, `complete(_:)`, `makeEasier(_:)`.

- [ ] **Step 1: Write failing end-to-end core-loop test**

```swift
func testFirstRunCanConfigureReceiveQuestAndRestoreWorld() async throws {
    let session = AfterStormSession(engine: LocalQuestEngine(seed: 1))
    session.configure(areas: [.home, .focus], avatarKind: .stormling)
    try await session.refreshSuggestions()

    XCTAssertEqual(session.suggestions.count, 3)
    let quest = try XCTUnwrap(session.suggestions.first)
    session.complete(quest)

    XCTAssertGreaterThan(session.progress.sparks, 0)
    XCTAssertEqual(session.progress.completedQuestCount, 1)
    XCTAssertTrue(session.restorationNodes.contains { $0.stage > 0 })
}
```

- [ ] **Step 2: Run failure**

Run: `swift test --filter AfterStormSessionTests`
Expected: FAIL because session does not exist.

- [ ] **Step 3: Implement minimal coordinator**

Keep session state platform-neutral and expose simple observable values for an iOS adapter to publish. `makeEasier(_:)` returns a quest with reduced duration and simpler copy without zeroing rewards.

- [ ] **Step 4: Run full tests and commit**

```bash
swift test
git add Sources Tests
git commit -m "feat: coordinate AfterStorm core loop"
```

---

### Task 4: Scaffold the native iOS app and premium design system

**Files:**
- Create: `project.yml`
- Create: `AfterStormApp/App/AfterStormApp.swift`
- Create: `AfterStormApp/App/AppFlow.swift`
- Create: `AfterStormApp/App/AppSessionModel.swift`
- Create: `AfterStormApp/App/RootView.swift`
- Create: `AfterStormApp/Design/AfterStormTheme.swift`
- Create: `AfterStormApp/Design/PremiumButtonStyle.swift`

**Interfaces:**
- Consumes: local `AfterStormCore` package.
- Produces: app entry point and reusable premium controls used by all screens.

- [ ] **Step 1: Add XcodeGen manifest**

Define an iOS application named `AfterStorm`, Swift 6, iOS 18 deployment target, bundle identifier `com.stormandme.afterstorm`, and a local package reference to `.` product `AfterStormCore`.

- [ ] **Step 2: Implement `AppFlow`**

```swift
@MainActor
@Observable
final class AppFlow {
    enum Phase { case studioIntro, stormReveal, personalization, avatar, firstQuest, questDetail, questMode, questComplete, restorationReveal, world }
    var phase: Phase = .studioIntro
}
```

- [ ] **Step 3: Implement premium theme tokens**

Use Apple system typography, semantic materials, reusable spacing/radius constants, and spring animation constants. Do not hardcode a random gradient palette in every screen.

- [ ] **Step 4: Implement tactile button style**

Pressed state scales to ~0.97 with a short spring, changes material highlight, and invokes semantic haptics from the screen action rather than inside generic styling.

- [ ] **Step 5: Validate source structure**

On Linux run `swift test` to ensure the core package remains green. On macOS/Xcode generation is `xcodegen generate && xcodebuild -scheme AfterStorm -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`.

- [ ] **Step 6: Commit**

```bash
git add project.yml AfterStormApp
git commit -m "feat: scaffold native AfterStorm app shell"
```

---

### Task 5: Build the Storm and Me Studios intro and cinematic storm reveal

**Files:**
- Create: `AfterStormApp/Launch/StudioIntroView.swift`
- Create: `AfterStormApp/Onboarding/StormRevealView.swift`
- Create: `AfterStormApp/Services/HapticsService.swift`
- Create: `AfterStormApp/Services/AudioService.swift`

**Interfaces:**
- Produces: completion callbacks that advance `AppFlow`.

- [ ] **Step 1: Build intro state machine**

Stages: blackout → cloud material → lightning flash → `STORM AND ME STUDIOS` resolve → dissolve into AfterStorm. Use SwiftUI timeline/keyframe animation and reduced-motion fallback.

- [ ] **Step 2: Add restrained semantic haptics**

Expose `tap()`, `questComplete()`, `restorationImpact()`, `unlock()`; no screen directly instantiates UIKit feedback generators.

- [ ] **Step 3: Add audio hooks**

Expose intro thunder, soft rain loop, completion chime, restoration impact. Missing audio asset must fail silently in debug and never crash launch.

- [ ] **Step 4: Build storm reveal**

Show the two approved lines and `Begin`; animate depth/parallax without blocking VoiceOver or Reduced Motion.

- [ ] **Step 5: Commit**

```bash
git add AfterStormApp
git commit -m "feat: add cinematic studio and storm intro"
```

---

### Task 6: Build first-run personalization and avatar choice

**Files:**
- Create: `AfterStormApp/Onboarding/LifeAreaSelectionView.swift`
- Create: `AfterStormApp/Onboarding/AvatarChoiceView.swift`

**Interfaces:**
- Consumes: `LifeArea`, `AvatarKind`.
- Produces: selected areas and avatar kind for the core session.

- [ ] **Step 1: Implement multi-select life-area cards**

Selecting “Honestly… everything” expands to all concrete `LifeArea` values. Continue remains disabled until at least one concrete area is selected.

- [ ] **Step 2: Implement human/Stormling choice**

Two premium animated character cards with accessible labels; V1 uses purpose-built silhouette/shape treatment until final original character art replaces it before release.

- [ ] **Step 3: Wire to session configure**

Pass concrete areas and selected avatar kind to `AfterStormSession.configure`.

- [ ] **Step 4: Commit**

```bash
git add AfterStormApp/Onboarding
git commit -m "feat: add AfterStorm personalization"
```

---

### Task 7: Build the first quest experience

**Files:**
- Create: `AfterStormApp/Onboarding/FirstQuestView.swift`
- Create: `AfterStormApp/Quest/QuestDetailView.swift`
- Create: `AfterStormApp/Quest/QuestModeView.swift`
- Create: `AfterStormApp/Quest/QuestCompleteView.swift`

**Interfaces:**
- Consumes: session quest suggestions.
- Produces: selected/completed `Quest`.

- [ ] **Step 1: Display exactly three personalized quest cards**

Each shows title, time, Sparks, and restoration target. `Give Me a Quest` refreshes suggestions through the session.

- [ ] **Step 2: Build Quest Detail**

Use plain-language instruction, reward preview, Start Quest, Swap Quest.

- [ ] **Step 3: Build Quest Mode**

Large calm title, optional timer display, Pause, Done, `Need Something Easier`. Easier action uses `session.makeEasier` and visibly reduces scope.

- [ ] **Step 4: Build completion confirmation**

`I DID IT` calls `session.complete(quest)` exactly once, emits completion haptic/audio, then routes to restoration reveal.

- [ ] **Step 5: Commit**

```bash
git add AfterStormApp/Quest AfterStormApp/Onboarding/FirstQuestView.swift
git commit -m "feat: add first playable quest flow"
```

---

### Task 8: Build the living world and first restoration reveal

**Files:**
- Create: `AfterStormApp/World/WorldHomeView.swift`
- Create: `AfterStormApp/World/WorldDioramaView.swift`
- Create: `AfterStormApp/World/RestorationRevealView.swift`

**Interfaces:**
- Consumes: `RestorationNode`, `PlayerProgress`, completed quest.
- Produces: persistent visible world state.

- [ ] **Step 1: Build world state renderer contract**

Map restoration node stages to explicit visual states: dark → repairing → restored. Keep that mapping outside the core quest engine.

- [ ] **Step 2: Build SwiftUI atmospheric diorama fallback**

Use layered gradients/materials, rain particles, building silhouettes, window lights, fog, and parallax so previews and non-RealityKit development remain visually coherent.

- [ ] **Step 3: Add RealityKit host boundary**

`WorldDioramaView` owns RealityKit entities/camera/lighting only and takes immutable restoration state as input. Quest logic cannot import RealityKit.

- [ ] **Step 4: Build cinematic restoration reveal**

Animate camera/scene emphasis toward the quest target, change its state, trigger impact haptic/audio, display `YOU RESTORED …` and Sparks.

- [ ] **Step 5: Route back to World**

The changed node must remain restored after the reveal and later relaunch once persistence is added.

- [ ] **Step 6: Commit**

```bash
git add AfterStormApp/World
git commit -m "feat: reveal persistent world restoration"
```

---

### Task 9: Add local persistence for the vertical slice

**Files:**
- Create: `AfterStormApp/Persistence/AppModel.swift`
- Create: `AfterStormApp/Persistence/PersistenceService.swift`
- Modify: `AfterStormApp/App/AfterStormApp.swift`

**Interfaces:**
- Consumes: serializable core profile/progress/restoration state.
- Produces: local-first persisted onboarding and world progress.

- [ ] **Step 1: Define SwiftData entities/adapters**

Persist selected life areas, avatar kind, Sparks, completed quest count, and restoration-node stages. Do not persist camera images.

- [ ] **Step 2: Load at app launch**

Returning users still see the short Studio intro but skip first-run onboarding and enter their persistent world.

- [ ] **Step 3: Save after configuration and every completion**

A quest completion must be atomic from the app user's perspective: Sparks and restoration stage save together.

- [ ] **Step 4: Commit**

```bash
git add AfterStormApp/Persistence AfterStormApp/App
git commit -m "feat: persist AfterStorm player progress"
```

---

### Task 10: Quality gate the slice

**Files:**
- Modify: test files as needed for discovered regressions.
- Create: `docs/quality/core-slice-acceptance.md`

**Interfaces:**
- Produces: verified launch-to-restoration acceptance checklist.

- [ ] **Step 1: Run core tests**

Run: `swift test`
Expected: zero failures.

- [ ] **Step 2: Run static source checks**

Search for `TODO`, `TBD`, `fatalError`, mock-only critical paths, and accidental direct AI dependencies in UI files. Resolve all release-critical hits.

- [ ] **Step 3: macOS/Xcode validation**

Run on a Mac with current Xcode:

```bash
xcodegen generate
xcodebuild -scheme AfterStorm -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

Expected: build/tests pass.

- [ ] **Step 4: Manual premium acceptance**

Verify: intro has intentional timing; buttons have pressed/loading/success states; Reduced Motion works; VoiceOver actions are labeled; no placeholder user-facing art is present in the candidate; completion always creates a visible world change; AI unavailable path remains fully usable.

- [ ] **Step 5: Commit**

```bash
git add docs Tests AfterStormApp
git commit -m "test: verify AfterStorm core slice"
```

---

## Plan Self-Review

- Spec coverage for this sub-project: launch identity, cinematic storm reveal, personalization, avatar kind, local quest generation, easier quest path, Sparks, world restoration, haptics/audio boundaries, local persistence, Reduced Motion/accessibility, and AI-independent operation are covered.
- Deferred by design to later V1 plans: Scan My World, Tell AfterStorm voice capture, Foundation Models/Vision adapter, full Collection/Residents/Progress tabs, StoreKit/AfterStorm+, widgets/App Intents, CloudKit, final premium 3D asset production, and App Store launch assets.
- Placeholder scan: no `TBD`/`TODO` implementation instructions remain in this plan.
- Type consistency: `LifeArea`, `AvatarKind`, `Quest`, `QuestEngine`, `AfterStormSession`, `RestorationNode`, and `PlayerProgress` are introduced before dependent tasks.
