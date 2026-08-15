# AfterStorm V1 External Release Setup

The repository contains the V1 application implementation and build configuration. The items below require macOS/Xcode or Apple/GitHub account-side configuration and therefore cannot be truthfully verified from the current Linux workspace.

## macOS / Xcode gate

- Run `./scripts/generate-xcode.sh`.
- Build `AfterStorm` for a generic iOS Simulator with code signing disabled.
- Run the app on at least one supported iPhone simulator.
- Exercise first run, returning launch, camera/photo fallback, Tell AfterStorm typed flow, widget, quest completion, persistence relaunch, Reduce Motion and large Dynamic Type.
- Repeat on a physical device for camera, microphone, speech, haptics and audio.
- Verify Foundation Models behavior on a compatible OS/device and verify local fallback on a device where it is unavailable.

## Apple developer capabilities

For app identifier `com.stormandme.afterstorm`:

- Enable App Groups and add `group.com.stormandme.afterstorm`.
- Enable iCloud / CloudKit and add `iCloud.com.stormandme.afterstorm`.
- Ensure the widget identifier `com.stormandme.afterstorm.widget` has the same App Group.
- Refresh signing profiles after capabilities are enabled.

## StoreKit / App Store Connect

Create and configure these subscription products before testing purchase UI against production metadata:

- `com.stormandme.afterstorm.plus.monthly`
- `com.stormandme.afterstorm.plus.yearly`

Add the products to the intended subscription group, set pricing/localization/review metadata, and test purchase/restore/current-entitlement states with Apple’s StoreKit sandbox/TestFlight flow.

## Brand and App Store presentation

- Review the included original AfterStorm icon on device and optionally refine it in Icon Composer before submission.
- Capture final App Store screenshots only from the verified release UI; do not use prototype mockups as store screenshots.
- Complete App Privacy disclosures from the shipped behavior.
- Prepare support/privacy URLs and age rating metadata.
- Run VoiceOver, Reduce Motion, Larger Text and color/contrast checks on device.

## GitHub CI

The private repository is `wscott2k26/AfterStorm`. Push the release-candidate branch there and let `.github/workflows/ios-ci.yml` provide the Xcode 27 / iOS 27 simulator compile gate before merge to `main`.

## Merge rule

Do not merge `feature/afterstorm-core-slice` into `main` until the Xcode simulator build is green and the first-run/restoration loop has been visually inspected on iOS.
