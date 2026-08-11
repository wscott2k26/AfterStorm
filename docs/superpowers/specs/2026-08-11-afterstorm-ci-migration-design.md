# AfterStorm CI Migration Design

**Date:** 2026-08-11  
**Product:** AfterStorm by Storm and Me Studios  
**Goal:** Stop routine AfterStorm development from consuming GitHub Actions macOS minutes while preserving a full Xcode 27 release gate.

## Decision

Use a two-lane CI model:

1. **Azure Pipelines — routine development CI**
   - Microsoft-hosted `macOS-26` agent.
   - Intended to use Azure DevOps' private-project free Microsoft-hosted grant after the Azure DevOps organization is linked to a valid Azure subscription.
   - Run Swift core tests, deterministic asset generation, XcodeGen, warning-clean iOS/widget build, and simulator smoke checks.
   - Pin Xcode 26.6 rather than relying on the image default.

2. **GitHub Actions — manual Xcode 27 release gate only**
   - Remove automatic `push` and `pull_request` triggers from `.github/workflows/ios-ci.yml`.
   - Retain `workflow_dispatch` so the known-good Xcode 27/iOS 27 validation lane remains available before release or after changes to iOS 27-only code.
   - This prevents ordinary commits from consuming GitHub macOS minutes.

## Xcode 26 / Xcode 27 compatibility boundary

AfterStorm's app baseline and core product remain buildable without the iOS 27 multimodal Foundation Models enhancement. The only iOS 27-only source currently depends on the image-attachment API in `AppleIntelligenceQuestService.sceneDescription`.

Azure's Xcode 26 lane will compile a fallback implementation for that one method using an explicit Swift compilation condition. The fallback throws the existing `ServiceError.unavailable`, which causes AfterStorm to use its existing Vision/local fallback path. The normal Xcode 27 build does **not** define that condition and therefore continues compiling and validating the real multimodal implementation.

This keeps the production behavior unchanged on supported iOS 27/Xcode 27 builds while allowing the inexpensive routine CI lane to validate the rest of the native app on Xcode 26.

## Azure pipeline shape

Create `/azure-pipelines.yml` with one macOS job to minimize hosted-minute consumption:

- Checkout repository.
- Select `/Applications/Xcode_26.6.app/Contents/Developer`.
- Print Xcode/Swift versions for evidence.
- Generate deterministic icon/audio assets.
- Install XcodeGen if it is not already available.
- Run `swift test`.
- Generate `AfterStorm.xcodeproj`.
- Verify WidgetKit plist metadata.
- Build app + widget with signing disabled and the Azure Xcode-26 compatibility compilation condition enabled.
- Fail on Xcode warnings.
- Boot an available iPhone simulator, install AfterStorm, launch it, and capture smoke screenshots when the hosted image provides a usable simulator runtime.
- Publish logs/screenshots as Azure Pipeline artifacts.

The job must stay under Azure DevOps' free-tier 60-minute per-job limit.

## Trigger policy

Azure Pipelines becomes the normal automatic gate for the feature branch and future pull requests/main updates. GitHub Actions becomes manual-only.

This avoids paying the GitHub macOS multiplier for every commit while preserving the stronger Xcode 27 lane when it is specifically needed.

## Failure handling

- If Azure reports no hosted parallelism, connect the Azure DevOps organization to the user's Azure for Students subscription through Organization Settings > Billing.
- If `macOS-26` is temporarily unavailable because it is still a preview image, the pipeline must fail clearly rather than silently downgrade to a different SDK.
- If the Xcode 26 build exposes an incompatibility outside the isolated iOS 27 multimodal method, fix the compatibility issue rather than disabling additional product code.
- The GitHub Xcode 27 workflow remains the release source of truth for iOS 27-only API compilation.

## Verification / acceptance

Migration is accepted when:

1. `.github/workflows/ios-ci.yml` has only `workflow_dispatch` as an event trigger.
2. `azure-pipelines.yml` exists and validates as YAML.
3. The Xcode-26 CI compatibility flag affects only the iOS 27 image-analysis implementation.
4. Existing Swift core tests remain green.
5. Existing Xcode 27 GitHub workflow behavior is otherwise unchanged and remains manually runnable.
6. A first Azure Pipeline run completes successfully after the Azure DevOps project is connected.

## Out of scope

- Moving source code away from GitHub.
- Replacing Xcode Cloud as a possible future signing/TestFlight release lane.
- Paying for Azure GitHub-hosted PAYG Apple Silicon agents unless the free Microsoft-hosted lane proves insufficient.
- Weakening AfterStorm's production fallback behavior or removing iOS 27 multimodal support.
