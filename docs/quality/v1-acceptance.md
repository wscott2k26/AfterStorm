# AfterStorm V1 Acceptance Report

**Product:** AfterStorm by Storm and Me Studios  
**Branch:** `feature/afterstorm-core-slice`  
**Date:** 2026-08-11

## Scope delivered

The locked V1 is implemented as a native iPhone-first Swift project with a tested platform-neutral core and an Apple-framework presentation/integration layer.

Implemented V1 surfaces and systems include:

- Animated Storm and Me Studios launch sting and cinematic first-run storm reveal.
- Multi-select life-area onboarding and editable preferences after onboarding.
- Human or original Stormling identity with skin/body, hair/head, eyes, palette, outfit, accessory and progression unlocks.
- Four-tab shell: World, Quests, Collection and Me.
- Local quest engine covering home, work, focus, digital, movement, learning and life admin, including 2/5/10/20+ minute discovery bands.
- Contextual typed/speech quest requests and Scan My World camera/photo flow.
- Vision/local fallback plus availability-gated Apple Foundation Models enhancement.
- Tested idempotent quest completion, Sparks, completion history, progression insights, residents and collectibles.
- The Block world with 24 visible restoration stages.
- Premium World pass: closer diorama framing, staged windows/doors/store/streetlights, wet-road reflections, progressive tree/nature healing, Stormlings/human/animal life, and the tested Stormy → Clearing → Afterglow weather state.
- Stronger restoration reveal with controlled push-in, Sparks/afterglow pulse, audio/haptics and resident reaction.
- Quest focus timer with pause/resume and Need Something Easier.
- Optional non-persisted after photo.
- Original audio cues plus evolving storm/afterglow ambience and haptics.
- SwiftData persistence with CloudKit-managed configuration attempt and durable local fallback.
- Give Me a Quest App Intent / Siri shortcut surface and Home Screen widget.
- Widget weather state that uses the same Stormy → Clearing → Afterglow core model as the World screen.
- AfterStorm+ StoreKit 2 subscription shell while keeping the core restoration loop free.
- App icon asset catalog, privacy strings, entitlements, Reduce Motion handling and accessibility labels/hints on primary surfaces.
- XcodeGen project specification.
- Azure Pipelines development CI plus manual-only GitHub Xcode 27 release verification.

## Previously proven macOS/Xcode baseline

Before the premium World/Azure migration commits, the feature branch passed the full Xcode 27 hosted gate:

- `swift test` green.
- AfterStorm app + widget compiled with Xcode 27 for the iPhone Simulator.
- Warning-clean Xcode build.
- Simulator boot/install/launch succeeded.
- First Quest, Quest Complete, Restoration and Main World acceptance scenarios launched and produced real simulator screenshots.
- The acceptance-state race that could return early scenarios to the intro was fixed and the subsequent Xcode 27 run was green.

This is the established native baseline. The newer World-polish commits must still receive their own macOS build/screenshot evidence before merge.

## Fresh verification for the current premium-World head

The current changed Swift/config files were mirrored from GitHub and hash-matched to their GitHub blobs before local verification.

Fresh Linux verification on the current code produced:

- Swift package core tests: **22 passed, 0 failures**.
- Swift parser: **71 Swift files parsed successfully** across app, widget, shared, core and tests.
- `project.yml`, `azure-pipelines.yml`, and `.github/workflows/ios-ci.yml` parse as YAML.
- App icon JSON, widget plist, entitlements and six WAV resources pass integrity checks; WAV files are 44.1 kHz, 16-bit, stereo.
- Release scan contains no TODO, TBD, `fatalError`, mock-data, prototype-only, `try!`, or `as!` markers in shipping Swift/core/test sources.
- Exact current changed-file hashes were verified for the theme, Apple Intelligence compatibility adapter, World diorama, World controls, restoration reveal, Azure pipeline, and manual GitHub workflow.
- GitHub Actions now has **no automatic push or pull-request trigger** for the expensive Xcode 27 workflow.
- The latest automatic GitHub Actions run is the already-started pre-disable plan commit; subsequent premium/Azure commits did not start new automatic Xcode runs.

## CI strategy after GitHub Actions quota exhaustion

### Azure Pipelines — normal development lane

`azure-pipelines.yml` is configured to:

- use Microsoft-hosted `macOS-26`,
- choose the newest installed Xcode 26.x,
- run the 22-test core suite,
- generate deterministic assets,
- generate the Xcode project,
- validate WidgetKit metadata,
- build AfterStorm + widget for the iOS Simulator with signing disabled,
- fail on Xcode warnings,
- boot an iPhone simulator,
- install and launch AfterStorm,
- capture First Quest / Quest Complete / Restoration / Main Progress screenshots,
- scan the runtime log for crash/watchdog/Metal termination patterns,
- publish Xcode logs and simulator screenshots as Azure artifacts.

The iOS 27 multimodal Foundation Models image path is compiler/availability-gated so Xcode 26 can build the complete app while Scan My World keeps its Vision/local fallback.

### GitHub Actions — manual release lane

`.github/workflows/ios-ci.yml` is `workflow_dispatch` only and retains the Xcode 27 build/simulator/screenshot lane for deliberate release checks. Routine commits no longer launch the expensive GitHub macOS runner.

## Remaining release gates

These are release gates, not hidden implementation omissions:

1. Complete the one-time Azure DevOps connection to `wscott2k26/AfterStorm` and run `/azure-pipelines.yml` on this feature branch.
2. Review the **new premium World** screenshot artifact from that Azure run and fix any visual/compile issue it reveals.
3. Physical-device camera, microphone, speech, haptics and audio behavior.
4. Apple Intelligence behavior on eligible hardware and fallback behavior on ineligible/disabled devices.
5. Live CloudKit/App Group entitlements under the Storm and Me Studios Apple team.
6. App Store Connect creation/testing of the monthly/yearly AfterStorm+ product identifiers.
7. TestFlight signing/archive/submission.

`main` remains protected until gates 1–2 are green.

## External identifiers to configure

- App bundle: `com.stormandme.afterstorm`
- Widget bundle: `com.stormandme.afterstorm.widget`
- App Group: `group.com.stormandme.afterstorm`
- CloudKit container: `iCloud.com.stormandme.afterstorm`
- Monthly subscription: `com.stormandme.afterstorm.plus.monthly`
- Yearly subscription: `com.stormandme.afterstorm.plus.yearly`

## Release decision

**Status: Premium V1 feature branch implemented and locally verified; prior Xcode 27 baseline green; current premium World head awaiting its first Azure macOS build + simulator screenshot review.**

Do not merge to `main`, archive, or submit to TestFlight until the Azure build/screenshot gate for the current head is green.
