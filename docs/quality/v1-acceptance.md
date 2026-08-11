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
- The Block world with 24 visible restoration stages, evolving weather/lighting/life, resident reactions and a next-district tease at full restoration.
- Quest focus timer with pause/resume and Need Something Easier.
- Optional non-persisted after photo.
- Original audio cues plus evolving storm/afterglow ambience and haptics.
- SwiftData persistence with CloudKit-managed configuration attempt and durable local fallback.
- Give Me a Quest App Intent / Siri shortcut surface and Home Screen widget.
- Widget weather state that evolves from Stormy to Clearing to Afterglow.
- AfterStorm+ StoreKit 2 subscription shell while keeping the core restoration loop free.
- App icon asset catalog, privacy strings, entitlements, Reduce Motion handling and accessibility labels/hints on primary surfaces.
- XcodeGen project specification and GitHub Actions CI definition.

## Proven in the current workspace

The final local verification script is `./scripts/verify-local.sh` and must remain green before any checkpoint is handed off.

The Linux environment can prove:

- Swift package core tests: **22 passed, 0 failures**.
- Native app/widget/shared Swift syntax parse: **45 files parsed successfully**.
- `project.yml` parses as YAML and all declared source paths/target dependencies exist.
- App icon asset JSON, widget plist and app/widget entitlements parse correctly; deterministic icon/WAV assets are recreated from `scripts/generate-assets.py` before verification/build.
- Generated audio resources are 44.1 kHz, 16-bit, stereo WAV files.
- Release-marker scan contains no TODO, TBD, `fatalError`, mock-data or prototype-only markers in shipping Swift sources/tests.
- `git diff --check` is clean.
- No forced casts, `try!`, or obvious forced-unwrap patterns were found in the manual source audit.

## API/configuration checks against current primary documentation

- `SystemLanguageModel.isAvailable` is a valid Foundation Models availability convenience API.
- Foundation Models supports image attachments in prompts in the current iOS 27-era API; that code path is isolated behind an iOS 27 availability gate.
- SwiftData's named `ModelConfiguration` initializer supports `groupContainer` and `cloudKitDatabase`; `.automatic` is valid for entitlement-driven App Group/CloudKit discovery.
- XcodeGen supports local Swift package paths and target dependencies with `embed`/`codeSign` controls.
- The CI iOS build job targets GitHub's `xcode-27` runner because the project intentionally contains an iOS 27 multimodal enhancement while retaining an iOS 18 app baseline.

## Not yet proven from this Linux environment

These are release gates, not hidden implementation omissions:

1. Xcode 27 type-check/compile of the iOS app and widget.
2. iPhone simulator launch and first-run/returning-user visual inspection.
3. Physical-device camera, microphone, speech, haptics and audio behavior.
4. Apple Intelligence behavior on eligible hardware and fallback behavior on ineligible/disabled devices.
5. Live CloudKit/App Group entitlements under the Storm and Me Studios Apple team.
6. App Store Connect creation/testing of the monthly/yearly AfterStorm+ product identifiers.
7. TestFlight signing/archive/submission.

The branch must remain unmerged until item 1 is green and the primary loop has been visually inspected in iOS.

## External identifiers to configure

- App bundle: `com.stormandme.afterstorm`
- Widget bundle: `com.stormandme.afterstorm.widget`
- App Group: `group.com.stormandme.afterstorm`
- CloudKit container: `iCloud.com.stormandme.afterstorm`
- Monthly subscription: `com.stormandme.afterstorm.plus.monthly`
- Yearly subscription: `com.stormandme.afterstorm.plus.yearly`

## Release decision

**Status: V1 release-candidate source checkpoint, pending the macOS/Xcode gate.**

Do not merge to `main`, archive, or submit to TestFlight until the Xcode 27 simulator build is green.
