# AfterStorm V1 Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the locked AfterStorm V1 beyond the core slice with premium navigation, contextual quest inputs, progression surfaces, Apple integrations, monetization shell, privacy/accessibility, and release-grade verification.

**Architecture:** Keep behavior and progression rules in `AfterStormCore`; keep Apple-only frameworks behind small app services/adapters. The main SwiftUI app uses a four-tab shell around the existing tested restoration loop. Apple Intelligence is opportunistic; Vision/local quest generation keep Scan/Tell functional when the model is unavailable.

**Tech Stack:** Swift 6, Swift Package Manager, SwiftUI, SwiftData, RealityKit, Vision, PhotosUI/UIKit camera bridge, Speech, FoundationModels (availability-gated), AppIntents, WidgetKit, StoreKit 2, CloudKit-managed SwiftData configuration, AVFoundation, UIKit haptics, XcodeGen.

## Global Constraints
- Product: **AfterStorm** by **Storm and Me Studios**.
- Tagline: **Rebuild your world by rebuilding your day.**
- Premium polish is required; no fake controls or prototype-only flows.
- iPhone-first native app, iOS 18 baseline.
- Foundation Models must be availability-gated; image prompting is treated as newer-platform enhancement.
- Camera images are never persisted by AfterStorm.
- One currency: Sparks.
- No punitive streaks or destructive progress.
- Core behavior remains test-first and Linux-testable.
- No merge to `main` without an actual Xcode/iOS SDK build on macOS.

---

### Task 1: Expand tested core for V1 discovery and progression
**Files:** create `QuestCompletionRecord.swift`, `AvatarStyle.swift`, `Collectible.swift`, `Resident.swift`, `ProgressInsights.swift`, tests.
- [x] Write failing tests for completion history, insight aggregation, deterministic unlock thresholds, and avatar-style snapshot persistence.
- [x] Run focused tests and verify RED.
- [x] Implement minimal core models/session changes.
- [x] Run `swift test` and verify GREEN.
- [x] Commit.

### Task 2: Add contextual local quest composition
**Files:** create `QuestContext.swift`, `ContextQuestComposer.swift`, tests.
- [x] Write failing tests for time extraction/limits and keyword-to-life-area routing.
- [x] Verify RED.
- [x] Implement local contextual composer that returns bounded micro-quests without AI.
- [x] Verify GREEN and commit.

### Task 3: Build the premium four-tab application shell
**Files:** create `MainTabView`, `QuestsView`, `CollectionView`, `MeView`, `PlayerProgressView`, `RestorationMapView`, `ResidentsView`; modify root/world.
- [x] Route post-onboarding users into four tabs.
- [x] Keep Give Me a Quest prominent on World and Quests.
- [x] Add real navigation for Map, Residents, Collection, Progress; no dead buttons.
- [x] Parse all native Swift files and commit.

### Task 4: Finish onboarding avatar studio
**Files:** create `AvatarStudioView`, `AvatarPreviewView`; modify flow/model/persistence.
- [x] Add palette/outfit/accessory selection after Human/Stormling choice.
- [x] Persist style through core snapshot.
- [x] Parse, test, commit.

### Task 5: Build Scan My World and Tell AfterStorm
**Files:** create `ScanMyWorldView`, `CameraCaptureView`, `SceneAnalysisService`, `TellAfterStormView`, `SpeechInputService`, `ContextualQuestService`.
- [x] Camera or PhotosPicker selection produces in-memory image data only.
- [x] Vision OCR creates a local scene summary; local contextual composer always works.
- [x] Tell screen supports typed context and optional speech recognition with proper permission keys.
- [x] Generated contextual quests feed the same quest-detail/focus/restoration loop.
- [x] Parse, tests, commit.

### Task 6: Add Apple Intelligence enhancement
**Files:** create `AppleIntelligenceQuestService`.
- [x] Gate `FoundationModels` at OS/framework availability.
- [x] Use `SystemLanguageModel` availability before any request.
- [x] Generate bounded quest suggestions from text context; fall back to local composer on unavailable/error.
- [x] Keep multimodal image path isolated for iOS 27+ and never required for Scan to function.
- [x] Parse and commit; mark Xcode typecheck pending.

### Task 7: Add App Intents, widget, CloudKit-ready persistence
**Files:** create shared intent route store, `GiveMeAQuestIntent`, widget extension sources, entitlements/config changes; modify model container configuration.
- [x] Expose a Give Me a Quest App Intent/Shortcut.
- [x] Add a glanceable widget with Sparks/restoration summary and quick-quest action.
- [x] Configure SwiftData with managed CloudKit automatic sync when entitlements are present, with local recovery fallback.
- [x] Parse/project-YAML validate and commit.

### Task 8: Add AfterStorm+ StoreKit shell
**Files:** create `StoreKitService`, `AfterStormPlusView`; modify Me/Collection.
- [x] Use StoreKit 2 current entitlements for premium state.
- [x] Use Apple StoreKit subscription views for monthly/yearly product IDs.
- [x] Free core loop remains fully usable.
- [x] Parse and commit; App Store Connect product configuration remains external release setup.

### Task 9: Premium/accessibility/privacy hardening
**Files:** modify theme/screens/project settings; create `PrivacyView` and release checklist.
- [x] Add Reduce Motion paths, VoiceOver labels/hints, Dynamic Type-safe layouts, loading/empty/error states.
- [x] Add camera, microphone, speech privacy strings.
- [x] Verify no user-facing placeholder/mock/TODO controls.
- [x] Verify every primary action has a destination or explicit disabled state.
- [x] Commit.

### Task 10: Final environment verification and packaging
- [x] Run `swift test` fresh; zero failures required.
- [x] `swiftc -frontend -parse` every Swift file that does not require macro expansion; record limitations.
- [x] Validate `project.yml` as YAML and inspect all target paths.
- [x] Static scan for TODO/TBD/fatalError/mock/placeholder/dead-action markers.
- [x] Generate a V1 acceptance report separating Linux-proven results from Mac/Xcode-required checks.
- [x] Package the feature branch checkpoint.
- [x] Do **not** merge to main until macOS Xcode build/simulator verification is available.
