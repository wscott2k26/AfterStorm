# AfterStorm Premium Sensory + Settings Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix Avatar Studio scrolling and add a persisted, user-controllable premium sensory system that drives animation, sound, haptics, and world/avatar intensity without weakening accessibility.

**Architecture:** Add a small device-local `ExperiencePreferences` service backed by `UserDefaults` because motion/audio/haptic choices are device-specific and should not require a SwiftData/CloudKit schema migration. Views and sensory services consume that one preference source. Avatar Studio switches from nested horizontal scrolling to adaptive wrapping chip grids; Me gains a first-class Settings destination; avatar/world presentation reads effective preferences plus system accessibility state. Existing quest/session/domain logic remains unchanged.

**Tech Stack:** Swift 6, SwiftUI, Observation, UserDefaults, AVFoundation, UIKit feedback generators, Core Haptics when available, XCTest source-contract tests, Azure package-only CI, Appetize visual acceptance.

## Global Constraints

- Preserve guest-first behavior and the current onboarding/navigation order.
- Do not add mandatory sign-in, ad SDKs, Game Center production integration, or CloudKit schema changes in Phase 1.
- Preserve existing SwiftData/iCloud-first storage fallback behavior.
- Cinematic is the visual ambition; Balanced, Calm, and Follow System must visibly reduce motion/effects.
- System Reduce Motion overrides nonessential motion regardless of selected preset.
- Lightning/flash, weather/particles, camera motion, avatar animation, ambience, sound effects, and haptics must be independently controllable.
- Audio and haptics are never required for comprehension.
- Keep Azure manual-only and package-only; do not reintroduce hosted simulator booting.
- No primary CTA may be obscured by the Avatar Studio sticky bottom dock.

---

### Task 1: Lock Phase 1 regression contracts

**Files:**
- Modify: `Tests/AfterStormCoreTests/BuildCompatibilityTests.swift`

**Interfaces:**
- Consumes repository source as text.
- Produces regression contracts for adaptive Avatar Studio layout, preference/settings wiring, preference-aware audio/haptics, and cinematic presentation hooks.

- [ ] **Step 1: Add failing source-contract tests**

Add tests that assert:

```swift
func testAvatarStudioUsesOneVerticalScrollAndAdaptiveWrappingChips() throws {
    let source = try source("AfterStormApp/Onboarding/AvatarStudioView.swift")
    XCTAssertTrue(source.contains("GridItem(.adaptive"))
    XCTAssertFalse(source.contains("ScrollView(.horizontal"))
    XCTAssertTrue(source.contains(".safeAreaInset(edge: .bottom)"))
}

func testExperiencePreferencesExposeAllRequiredControls() throws {
    let source = try source("AfterStormApp/Settings/ExperiencePreferences.swift")
    for token in [
        "ExperienceIntensity", "cinematic", "balanced", "calm", "followSystem",
        "weatherParticlesEnabled", "cameraMotionEnabled", "lightningEffectsEnabled",
        "avatarAnimationEnabled", "ambienceEnabled", "soundEffectsEnabled", "hapticsEnabled"
    ] {
        XCTAssertTrue(source.contains(token), "Missing preference token: \(token)")
    }
}

func testMeExposesSettingsAndSettingsExposesSensoryControls() throws {
    let me = try source("AfterStormApp/Main/MeView.swift")
    let settings = try source("AfterStormApp/Settings/SettingsView.swift")
    XCTAssertTrue(me.contains("Settings"))
    XCTAssertTrue(me.contains("showingSettings"))
    XCTAssertTrue(settings.contains("Experience"))
    XCTAssertTrue(settings.contains("Sound & Haptics"))
    XCTAssertTrue(settings.contains("Lightning & Flash"))
}

func testAudioAndHapticsRespectExperiencePreferences() throws {
    let audio = try source("AfterStormApp/Services/AudioService.swift")
    let haptics = try source("AfterStormApp/Services/HapticsService.swift")
    XCTAssertTrue(audio.contains("ExperiencePreferences.shared"))
    XCTAssertTrue(audio.contains("soundEffectsEnabled"))
    XCTAssertTrue(audio.contains("ambienceEnabled"))
    XCTAssertTrue(haptics.contains("ExperiencePreferences.shared"))
    XCTAssertTrue(haptics.contains("hapticsEnabled"))
}

func testAvatarAndWorldReadSensoryPreferences() throws {
    let avatar = try source("AfterStormApp/Onboarding/AvatarPreviewView.swift")
    let world = try source("AfterStormApp/World/WorldDioramaView.swift")
    XCTAssertTrue(avatar.contains("ExperiencePreferences.shared"))
    XCTAssertTrue(avatar.contains("avatarAnimationEnabled"))
    XCTAssertTrue(world.contains("ExperiencePreferences.shared"))
    XCTAssertTrue(world.contains("weatherParticlesEnabled"))
    XCTAssertTrue(world.contains("cameraMotionEnabled"))
}
```

- [ ] **Step 2: Run the contracts and verify RED**

Run:

```bash
swift test --filter BuildCompatibilityTests
```

Expected: new Phase 1 tests fail because the files/wiring do not exist yet.

- [ ] **Step 3: Commit tests**

```bash
git add Tests/AfterStormCoreTests/BuildCompatibilityTests.swift
git commit -m "test: lock premium sensory phase one contracts"
```

---

### Task 2: Add persisted device-local experience preferences

**Files:**
- Create: `AfterStormApp/Settings/ExperiencePreferences.swift`

**Interfaces:**
- Produces: `enum ExperienceIntensity: String, CaseIterable, Identifiable`
- Produces: `@MainActor @Observable final class ExperiencePreferences`
- Shared access: `ExperiencePreferences.shared`
- Public mutable properties: `intensity`, `weatherParticlesEnabled`, `cameraMotionEnabled`, `lightningEffectsEnabled`, `avatarAnimationEnabled`, `ambienceEnabled`, `soundEffectsEnabled`, `hapticsEnabled`
- Public method: `applyPreset(_ intensity: ExperienceIntensity)`
- Public method: `allowsMotion(systemReduceMotion: Bool) -> Bool`

- [ ] **Step 1: Implement preference keys and intensity enum**

Use exact raw values:

```swift
enum ExperienceIntensity: String, CaseIterable, Identifiable {
    case cinematic
    case balanced
    case calm
    case followSystem

    var id: String { rawValue }
}
```

Use a private `Keys` namespace with keys prefixed `afterstorm.experience.`.

- [ ] **Step 2: Implement observable persisted properties**

`ExperiencePreferences.shared` loads values from `UserDefaults.standard`; setters persist immediately. Defaults for a fresh install:

```text
intensity = cinematic
weatherParticlesEnabled = true
cameraMotionEnabled = true
lightningEffectsEnabled = true
avatarAnimationEnabled = true
ambienceEnabled = true
soundEffectsEnabled = true
hapticsEnabled = true
```

`applyPreset` sets:

```text
cinematic: weather=true camera=true lightning=true avatar=true
balanced:  weather=true camera=false lightning=true avatar=true
calm:      weather=false camera=false lightning=false avatar=false
followSystem: weather=true camera=true lightning=true avatar=true
```

Do not alter ambience/SFX/haptics when changing the visual preset.

`allowsMotion(systemReduceMotion:)` returns false when system Reduce Motion is true; otherwise false only for `.calm`.

- [ ] **Step 3: Parse the file**

Run:

```bash
xcrun swiftc -parse AfterStormApp/Settings/ExperiencePreferences.swift
```

Expected: exit 0.

- [ ] **Step 4: Run preference regression test**

Run:

```bash
swift test --filter BuildCompatibilityTests/testExperiencePreferencesExposeAllRequiredControls
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add AfterStormApp/Settings/ExperiencePreferences.swift
git commit -m "feat: add persisted sensory experience preferences"
```

---

### Task 3: Fix Avatar Studio gesture conflict with adaptive wrapping chips

**Files:**
- Modify: `AfterStormApp/Onboarding/AvatarStudioView.swift`

**Interfaces:**
- Consumes existing `AvatarStyle`, `HapticsService.tap()`, `AfterStormTheme.quickSpring`.
- Keeps existing `onContinue: (AvatarStyle) -> Void` API unchanged.

- [ ] **Step 1: Replace nested horizontal scroller**

In generic `picker`, replace `ScrollView(.horizontal)` + `HStack` with:

```swift
let columns = [GridItem(.adaptive(minimum: 88), spacing: 8)]
LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
    ForEach(options, id: \.self) { option in
        Button(label(option)) {
            HapticsService.tap()
            withAnimation(AfterStormTheme.quickSpring) {
                selection.wrappedValue = option
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(selection.wrappedValue == option ? AfterStormTheme.rainBlue : .gray.opacity(0.35))
        .scaleEffect(selection.wrappedValue == option ? 1.035 : 1)
        .animation(AfterStormTheme.quickSpring, value: selection.wrappedValue == option)
        .accessibilityAddTraits(selection.wrappedValue == option ? .isSelected : [])
    }
}
```

Use `.fixedSize(horizontal: false, vertical: true)` on chip labels if needed to avoid truncating wrapped labels.

- [ ] **Step 2: Add sufficient end-of-scroll clearance**

Place:

```swift
Color.clear.frame(height: 28)
```

at the bottom of the scroll content so Accessory remains comfortably reachable above the safe-area dock.

- [ ] **Step 3: Parse and run regression test**

Run:

```bash
xcrun swiftc -parse AfterStormApp/Onboarding/AvatarStudioView.swift
swift test --filter BuildCompatibilityTests/testAvatarStudioUsesOneVerticalScrollAndAdaptiveWrappingChips
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add AfterStormApp/Onboarding/AvatarStudioView.swift
git commit -m "fix: make avatar customization fully vertically scrollable"
```

---

### Task 4: Add first-class Settings experience from Me

**Files:**
- Create: `AfterStormApp/Settings/SettingsView.swift`
- Modify: `AfterStormApp/Main/MeView.swift`

**Interfaces:**
- `SettingsView` consumes `ExperiencePreferences.shared`.
- Me presents Settings as a sheet/navigation destination with no change to `AppSessionModel`.

- [ ] **Step 1: Build SettingsView**

Use `NavigationStack` + `Form` or premium grouped cards with these exact sections and controls:

```text
Experience
- segmented/menu Picker: Cinematic / Balanced / Calm / Follow System
- Weather & Particles toggle
- Camera Motion toggle
- Lightning & Flash toggle
- Avatar Animation toggle

Sound & Haptics
- Ambience toggle
- Sound Effects toggle
- Haptics toggle

Account & Sync
- status row: Playing on this device
- explanatory row: iCloud sync is used automatically when available; local storage remains available offline

Subscription
- row/button opening AfterStorm+

Privacy & Data
- row/button opening existing PrivacyView
```

When the intensity picker changes, call `preferences.applyPreset(newValue)`.

- [ ] **Step 2: Add Settings entry to MeView**

Add `@State private var showingSettings = false`, menu button:

```swift
menuButton("Settings", "gearshape.fill") { showingSettings = true }
```

and sheet:

```swift
.sheet(isPresented: $showingSettings) {
    SettingsView()
}
```

- [ ] **Step 3: Parse and test**

Run:

```bash
xcrun swiftc -parse AfterStormApp/Settings/SettingsView.swift
xcrun swiftc -parse AfterStormApp/Main/MeView.swift
swift test --filter BuildCompatibilityTests/testMeExposesSettingsAndSettingsExposesSensoryControls
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add AfterStormApp/Settings/SettingsView.swift AfterStormApp/Main/MeView.swift
git commit -m "feat: add premium sensory settings experience"
```

---

### Task 5: Make audio and haptics preference-aware and richer

**Files:**
- Modify: `AfterStormApp/Services/AudioService.swift`
- Modify: `AfterStormApp/Services/HapticsService.swift`

**Interfaces:**
- Both services read `ExperiencePreferences.shared`.
- Existing public methods remain source-compatible.
- Add haptic methods: `questAccepted()`, `collectibleUnlock()`, `majorRestoration()`.

- [ ] **Step 1: Gate audio channels**

Before one-shot effects, return when `soundEffectsEnabled == false`.

Before starting/updating ambience, if `ambienceEnabled == false`, call `stopWorldAmbience()` and return.

Do not gate `stopWorldAmbience()` itself.

- [ ] **Step 2: Gate normal haptics**

At the top of every public haptic method:

```swift
guard ExperiencePreferences.shared.hapticsEnabled else { return }
```

Add `questAccepted()` using `.light` impact.

- [ ] **Step 3: Add Core Haptics premium patterns**

Under `#if canImport(CoreHaptics)`, import CoreHaptics and maintain a lazy `CHHapticEngine?`.

`collectibleUnlock()` plays a brief 3-event transient rising-intensity sparkle pattern.

`majorRestoration()` plays a short continuous low-frequency rumble followed by a strong transient impact. Fall back to UIKit feedback if Core Haptics is unavailable or the engine fails.

Keep patterns under 1 second.

- [ ] **Step 4: Parse and test**

Run:

```bash
xcrun swiftc -parse AfterStormApp/Services/AudioService.swift
xcrun swiftc -parse AfterStormApp/Services/HapticsService.swift
swift test --filter BuildCompatibilityTests/testAudioAndHapticsRespectExperiencePreferences
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add AfterStormApp/Services/AudioService.swift AfterStormApp/Services/HapticsService.swift
git commit -m "feat: make AfterStorm audio and haptics user controlled"
```

---

### Task 6: Add Cinematic avatar life without breaking Calm/Reduce Motion

**Files:**
- Modify: `AfterStormApp/Onboarding/AvatarPreviewView.swift`

**Interfaces:**
- Reads `ExperiencePreferences.shared.avatarAnimationEnabled` and `ExperiencePreferences.shared.intensity`.
- Reads SwiftUI `accessibilityReduceMotion`.
- No change to public initializer: `AvatarPreviewView(kind:style:size:)`.

- [ ] **Step 1: Add animation state**

Add:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
@State private var floating = false
@State private var blinking = false
private let preferences = ExperiencePreferences.shared
```

Compute `animationEnabled` as avatar toggle on, system Reduce Motion off, and intensity not Calm.

- [ ] **Step 2: Add avatar idle motion**

Apply subtle repeating vertical float/scale to the avatar shape only in animation-enabled modes. Cinematic uses roughly 2–3 pt float plus 0.8–1.5% breathing scale; Balanced uses about half that; Calm/Reduce Motion uses none.

- [ ] **Step 3: Add blink behavior**

Pass a `blink` flag into `StormlingShape` and `HumanShape`; temporarily reduce eye height/scale during blink. Use a cancellable `.task(id: animationEnabled)` loop with irregular 2.4–4.2 second sleeps. Stop immediately when animation becomes disabled.

- [ ] **Step 4: Add restrained aura response**

In Cinematic mode only, slightly animate the accent-circle glow opacity/radius so the avatar feels alive without constant flashing.

- [ ] **Step 5: Parse and run avatar/world preference regression**

Run:

```bash
xcrun swiftc -parse AfterStormApp/Onboarding/AvatarPreviewView.swift
swift test --filter BuildCompatibilityTests/testAvatarAndWorldReadSensoryPreferences
```

Expected: test may still fail on World until Task 7; avatar file must parse.

- [ ] **Step 6: Commit**

```bash
git add AfterStormApp/Onboarding/AvatarPreviewView.swift
git commit -m "feat: bring AfterStorm avatars to life"
```

---

### Task 7: Make world atmosphere respond to Cinematic/Balanced/Calm settings

**Files:**
- Modify: `AfterStormApp/World/WorldDioramaView.swift`

**Interfaces:**
- Reads `ExperiencePreferences.shared` plus existing `accessibilityReduceMotion`.
- No change to external `WorldDioramaView(nodes:progressSparks:atmosphericOnly:)` API.

- [ ] **Step 1: Derive effective visual flags**

Inside `WorldDioramaView`, derive:

```swift
private let preferences = ExperiencePreferences.shared
```

Within body, compute whether ambient motion is allowed using system Reduce Motion plus `preferences.allowsMotion(...)`.

Use independent preference flags for:
- weather/particle rendering;
- camera/parallax movement;
- lightning/flash surfaces where present;
- generic motion passed into child scene layers.

- [ ] **Step 2: Gate RainField and high-volume particles**

Only render animated `RainField` when weather particles are enabled and effective motion is allowed. Preserve the existing static rain gradient fallback for accessibility/Calm/disabled weather so weather state remains understandable.

- [ ] **Step 3: Add restrained Cinematic parallax**

Add a slow 2–4 pt scene drift/parallax layer in Cinematic mode only. Balanced gets either zero or half-amplitude drift; Calm/Reduce Motion gets none. Do not change hit testing or content positions enough to affect layout.

- [ ] **Step 4: Gate other ambient life where practical**

Pass effective motion into `PremiumBlockScene` / `WorldLifeLayer` rather than raw system `reduceMotion` so user Calm/avatar/world settings actually reduce the scene.

- [ ] **Step 5: Parse and run regression test**

Run:

```bash
xcrun swiftc -parse AfterStormApp/World/WorldDioramaView.swift
swift test --filter BuildCompatibilityTests/testAvatarAndWorldReadSensoryPreferences
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add AfterStormApp/World/WorldDioramaView.swift
git commit -m "feat: make world atmosphere follow sensory settings"
```

---

### Task 8: Wire richer semantic feedback into high-value moments

**Files:**
- Modify: `AfterStormApp/Quest/QuestModeView.swift`
- Modify: `AfterStormApp/Quest/QuestCompleteView.swift`
- Modify: `AfterStormApp/World/RestorationRevealView.swift`
- Modify selectively: other call sites only where an existing semantic event already occurs.

**Interfaces:**
- Uses `HapticsService.questAccepted()`, `questComplete()`, `collectibleUnlock()`, `majorRestoration()`.
- Uses existing `AudioService` one-shot methods; no new business events.

- [ ] **Step 1: Use questAccepted at quest start/commit action**

Replace generic `tap()` only at the semantic quest-accept point, not every navigation tap.

- [ ] **Step 2: Pair quest completion with success feedback**

Ensure quest completion triggers `AudioService.shared.playQuestComplete()` + `HapticsService.questComplete()` once.

- [ ] **Step 3: Pair major restoration reveal with premium feedback**

At the existing restoration-impact point, trigger `AudioService.shared.playRestoration()` + `HapticsService.majorRestoration()` once.

- [ ] **Step 4: Use collectibleUnlock for actual unlock events**

Only call when a collectible is newly unlocked; do not fire on merely viewing the collection.

- [ ] **Step 5: Parse touched files**

Run `xcrun swiftc -parse` for each changed file.

- [ ] **Step 6: Commit**

```bash
git add AfterStormApp/Quest AfterStormApp/World/RestorationRevealView.swift
git commit -m "feat: add semantic sound and haptic feedback"
```

---

### Task 9: Full verification and one fresh Appetize build

**Files:**
- Verify source and update acceptance evidence only after real run.
- Update: `docs/quality/v1-acceptance.md` after visual acceptance.

**Interfaces:**
- Consumes all Phase 1 tasks.
- Produces one Azure artifact: `afterstorm-simulator-build/AfterStorm-simulator.app.zip`.

- [ ] **Step 1: Run full core test suite**

```bash
swift test
```

Expected: all tests PASS.

- [ ] **Step 2: Parse every native Swift file**

```bash
find AfterStormApp AfterStormWidget Shared -name '*.swift' -print0 | while IFS= read -r -d '' file; do
  xcrun swiftc -parse "$file"
done
```

Expected: exit 0.

- [ ] **Step 3: Verify Azure stays manual/package-only**

Confirm `azure-pipelines.yml` contains `trigger: none`, `pr: none`, and no `simctl boot` or simulator screenshot task.

- [ ] **Step 4: Run Azure once**

Branch: `feature/afterstorm-core-slice`.

Expected:
- core tests PASS;
- app/widget iOS Simulator build PASS;
- package step PASS;
- artifact contains `AfterStorm-simulator.app.zip`, `zip-contents.txt`, and SHA-256 file.

- [ ] **Step 5: Replace Appetize build and visually accept**

On compact iPhone profile verify:
- all Avatar Studio sections including Eyes, Outfit, Accessory are reachable with vertical scroll;
- sticky CTA never covers the final option group;
- Cinematic visibly animates avatar/world;
- Balanced is calmer;
- Calm removes nonessential motion;
- toggling weather/camera/lightning/avatar animation takes effect;
- ambience/SFX/haptics controls behave without breaking navigation;
- onboarding still reaches First Quest and main app.

- [ ] **Step 6: Record acceptance evidence**

Update `docs/quality/v1-acceptance.md` with Azure build number, commit SHA, Appetize device/OS, and observed Phase 1 results.

- [ ] **Step 7: Commit acceptance record**

```bash
git add docs/quality/v1-acceptance.md
git commit -m "docs: record premium sensory phase one acceptance"
```
