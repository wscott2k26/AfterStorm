# AfterStorm Core Slice — Acceptance Checkpoint

**Branch:** `feature/afterstorm-core-slice`  
**Product:** AfterStorm by Storm and Me Studios  
**Checkpoint scope:** Studio intro → storm reveal → personalization → Human/Stormling choice → three local quests → quest detail/focus/completion → Sparks → persistent restoration → living world.

## Verified in Current Environment

- `swift test`: **8 tests passed, 0 failures**.
- Native app source syntax: `swiftc -frontend -parse` completed with exit code 0 across all `AfterStormApp/**/*.swift` files.
- `project.yml`: parsed as valid YAML and contains the local `AfterStormCore` package/product dependency.
- Static release-critical source scan: no `TODO`, `TBD`, `fatalError`, `mock data`, or `placeholder` markers in Swift source.
- RealityKit boundary exists in `WorldDioramaView` via `RealityView`.
- SwiftData boundary exists via `@Model` in `AppModel`.
- UI slice has no direct Foundation Models dependency; AI remains optional by architecture.
- Git working tree was clean at verification time.

## Core Behaviors Under Automated Test

1. Local quest suggestions stay inside selected life areas and return three useful quests.
2. Consecutive local quest requests rotate suggestions.
3. Completing a quest awards Sparks and advances only the intended restoration node.
4. Fully restored nodes never regress or exceed their max stage.
5. First-run configuration can produce quests and restore the world.
6. `Need Something Easier` reduces quest duration while preserving a positive reward.
7. Double completion of the same quest is idempotent; Sparks and restoration cannot be awarded twice.
8. Session snapshots restore selected areas, avatar kind, Sparks, world nodes, and completed-quest identity.

## Premium Product Rules Implemented in the Slice

- Native Swift/SwiftUI shell rather than a web wrapper.
- Centralized visual tokens and tactile spring button behavior.
- Cinematic Storm and Me Studios launch sequence.
- Atmospheric weather, depth, rain, lighting, and diorama treatment.
- RealityKit isolated from quest/business logic.
- Semantic haptic service and restrained audio hooks.
- SwiftData local-first persistence.
- Graceful storage recovery instead of a startup crash.
- No fake Scan/Tell controls before those features are implemented.
- No punitive streak logic.
- One currency only: Sparks.
- AI is an enhancement, never a requirement for the core loop.

## Required Before Merge / TestFlight

The current execution environment is Linux and does not contain Xcode or an iOS SDK. Therefore the following is intentionally **not claimed as verified yet**:

```bash
xcodegen generate
xcodebuild -scheme AfterStorm -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

Before merging this branch into the protected main line:

- Generate the `.xcodeproj` on macOS with XcodeGen.
- Compile and run on the current iPhone simulator target.
- Resolve any SwiftUI/SwiftData/RealityKit type-check or SDK issues discovered by the Apple compiler/SDK.
- Run Accessibility Inspector/VoiceOver and Reduce Motion checks.
- Replace development-only shape/SF Symbol character/world art with final original Storm and Me Studios assets before release candidacy.
- Original deterministic Storm and Me audio cues are generated from source for intro, completion, restoration, unlock and evolving world ambience.
- Verify frame rate and restoration animation on a physical supported iPhone.

**Release status:** Engineering checkpoint only. Not TestFlight-ready until the macOS/Xcode gate passes.
