# AfterStorm

**AfterStorm by Storm and Me Studios**  
*Rebuild your world by rebuilding your day.*

AfterStorm is a native, iPhone-first restoration game for real life: choose or generate a small real-world quest, complete it, earn Sparks, and visibly restore a storm-damaged miniature world.

## V1 product loop

`Storm and Me Studios intro → cinematic storm reveal → multi-select personalization → Human/Stormling avatar studio → smart/local quest choices → optional Scan My World / Tell AfterStorm → focus/timer mode → completion → cinematic restoration → persistent living world`

## V1 surfaces

- **World** — The Block diorama, 24 visible restoration stages, staged street/window/store lighting, wet-road reflections, trees and nature healing, Stormlings/residents returning, Stormy → Clearing → Afterglow weather, Map, Scan, Tell, and Give Me a Quest.
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
- `azure-pipelines.yml` — normal development CI: tests, Xcode build, simulator smoke launch and acceptance screenshots on Microsoft-hosted macOS.
- `.github/workflows/ios-ci.yml` — manual-only Xcode 27 release verification so routine commits do not consume GitHub macOS minutes.

## Local verification

```bash
./scripts/verify-local.sh
```

The verifier recreates deterministic icon/audio assets, then proves core tests, native Swift syntax, project/resource integrity, Azure/GitHub CI policy and release-marker cleanliness. Linux cannot replace the final macOS/iOS SDK typecheck.

## Generate on macOS

```bash
./scripts/generate-xcode.sh
open AfterStorm.xcodeproj
```

Then select the Storm and Me Studios development team and verify the app + widget on an iPhone simulator/device before release.

## CI strategy

- **Azure Pipelines:** automatic development builds on `main` and `feature/*`; publishes Xcode logs and real simulator acceptance screenshots.
- **GitHub Actions:** manual Xcode 27 release check only.
- Azure connection instructions: `docs/quality/azure-pipelines-setup.md`.

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
- `main` stays protected until the current feature branch has a fresh macOS/Xcode compile and visual acceptance result.
