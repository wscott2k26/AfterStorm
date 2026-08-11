# AfterStorm

**AfterStorm by Storm and Me Studios**  
*Rebuild your world by rebuilding your day.*

AfterStorm is a native, iPhone-first restoration game for real life: choose or generate a small real-world quest, complete it, earn Sparks, and visibly restore a storm-damaged miniature world.

## V1 product loop

`Storm and Me Studios intro → cinematic storm reveal → multi-select personalization → Human/Stormling avatar studio → smart/local quest choices → optional Scan My World / Tell AfterStorm → focus/timer mode → completion → cinematic restoration → persistent living world`

## V1 surfaces

- **World** — The Block diorama, 24 visible restoration stages, weather clearing, residents returning, Map, Scan, Tell, and Give Me a Quest.
- **Quests** — three rotating suggestions, life-area/time filters, quest detail, easier mode, timer/pause, completion and restoration.
- **Collection** — deterministic Sparks/quest-based cosmetic and world rewards.
- **Me** — avatar editing, life-area editing, progress, residents, privacy, and AfterStorm+.
- **Apple integrations** — SwiftData persistence with CloudKit-ready fallback, App Intent/Siri shortcut, WidgetKit widget, StoreKit 2 subscription shell, optional Foundation Models enhancement, Vision/photo analysis and optional speech input.

## Architecture

- `Sources/AfterStormCore` — platform-neutral, automated-testable quest/progression/session logic.
- `AfterStormApp` — SwiftUI app, RealityKit world boundary, persistence and Apple-framework adapters.
- `Shared` — app-group widget snapshot and Give Me a Quest App Intent.
- `AfterStormWidget` — system-small/system-medium progress widget.
- `project.yml` — XcodeGen project definition.
- `.github/workflows/ios-ci.yml` — macOS core-test + iPhone-simulator build gate once this repo is connected to GitHub.

## Local verification

```bash
./scripts/verify-local.sh
```

The verifier first recreates the deterministic icon/audio build assets, then Linux can prove core tests, Swift syntax, project structure and resource integrity. It cannot prove an iOS SDK typecheck or simulator runtime.

## Generate on macOS

```bash
./scripts/generate-xcode.sh
open AfterStorm.xcodeproj
```

Then select the Storm and Me Studios development team and verify the app + widget on an iPhone simulator/device before merging the feature branch.

## Bundle identities

- App: `com.stormandme.afterstorm`
- Widget: `com.stormandme.afterstorm.widget`
- App Group: `group.com.stormandme.afterstorm`
- CloudKit container: `iCloud.com.stormandme.afterstorm`
- AfterStorm+ monthly: `com.stormandme.afterstorm.plus.monthly`
- AfterStorm+ yearly: `com.stormandme.afterstorm.plus.yearly`

## Product rules

- One currency: **Sparks**.
- No destructive streaks or shame mechanics.
- Foundation Models enhance the app; they never gate basic usefulness.
- Scan images are not stored in the AfterStorm progress database.
- Every completed quest advances a restoration stage and leaves a visible world change.
- `main` stays protected until a real Xcode/iOS build gate passes.
