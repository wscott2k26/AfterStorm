# AfterStorm — App Store 1.0 Metadata Pack

## App identity
- Name: AfterStorm
- Bundle ID: `com.stormandme.afterstorm`
- Widget bundle ID: `com.stormandme.afterstorm.widget`
- Version: `1.0`
- Build: `1`
- Primary language: English (U.S.)
- Primary category: Productivity
- Secondary category: Lifestyle
- Copyright: © 2026 Storm And Me LLC

## Public URLs
- Privacy Policy: https://stormandmeofficial.com/afterstorm/privacy
- Support: https://stormandmeofficial.com/afterstorm/support
- Marketing: https://stormandmeofficial.com/afterstorm

## Subtitle
Small quests. Real progress.

## Promotional text
When everything feels like too much, AfterStorm turns the next few minutes into one clear, manageable quest — and lets your world brighten as you make progress.

## Description
AfterStorm turns everyday overwhelm into small, achievable quests.

Choose the parts of life that need attention — home, work, focus, digital life, movement, learning, and more — then let AfterStorm suggest a next step that fits the time and energy you have right now.

Complete quests to earn Sparks and restore a storm-darkened world one piece at a time. Your progress becomes visible: lights return, the block changes, and the atmosphere clears as small wins add up.

FEATURES
• Tiny quests designed to feel doable, not overwhelming
• Time filters for quick wins or deeper focus
• A visual restoration world that changes with your progress
• Quest Mode with a focused timer and pause/resume controls
• Optional camera and voice input when you choose to use them
• Apple Intelligence support on compatible devices, with graceful local fallbacks
• Home Screen widget for a quick look at your progress
• iCloud-backed progress when available, with a local fallback
• Accessibility-aware motion, transparency, and haptic behavior

AfterStorm is built around one idea: you do not have to fix everything today. Restore one thing. Then another.

## Keywords
productivity,habits,focus,tasks,declutter,goals,routine,motivation,wellness,self care

## Review notes
AfterStorm does not require an account or login for version 1.0. There are no required purchases in this submission.

Suggested review flow:
1. Complete onboarding and choose one or more Life Areas.
2. Open Quests and choose or generate a quest.
3. Start Quest Mode, pause/resume if desired, then complete the quest.
4. Return to World to observe restoration progress.

Camera, microphone, speech recognition, and photo-library features are optional and are only requested after the reviewer chooses the related feature. Core quest and progression functionality remains usable without granting those optional permissions.

## Privacy questionnaire working answer
Current architecture is device-first. Quest progress and preferences are stored through SwiftData and may sync through the user's iCloud/CloudKit account when available. Apple Intelligence quest generation uses Apple's system Foundation Models on supported devices. AfterStorm version 1.0 does not include an AfterStorm-operated analytics, advertising, or user-profile backend.

Before publishing the privacy answers in App Store Connect, confirm the generated Xcode privacy report and the final binary contain no newly added third-party SDKs or remote data flows.

## Export compliance working answer
The current source does not implement custom cryptography. Standard Apple platform security, iCloud, and system networking may use encryption. The project declares that it does not use non-exempt encryption. Reconfirm this answer if custom cryptography or a non-Apple networking/security SDK is added before submission.

## Age rating working answer
Expected low-content rating. Complete Apple's current age-rating questionnaire in App Store Connect using the final feature set. AfterStorm 1.0 has no user-generated public content, gambling, sexual content, violence, or social feed.

## Screenshot set
Use final product UI only; no Appetize chrome.

Recommended 6.9-inch portrait master size: `1320 x 2868` or another currently accepted 6.9-inch size.

Capture 5 screens:
1. World — early storm state with the restoration deck visible.
2. Life Areas — "What needs restoring?"
3. Quests — glass quest cards and filters.
4. Quest Mode — active focused quest/timer.
5. World — visibly restored/clearing state after progress.

Suggested screenshot captions:
1. YOUR WORLD CHANGES WITH YOU
2. CHOOSE WHAT NEEDS RESTORING
3. ONE SMALL QUEST AT A TIME
4. FOCUS ON THE NEXT FEW MINUTES
5. WATCH SMALL WINS ADD UP

## Submission gate
Do not submit until all are true:
- App Store Connect app record exists for `com.stormandme.afterstorm`.
- Latest Apple agreements are accepted.
- A valid Distribution signing identity/team can archive the app and widget.
- Privacy and Support URLs return HTTP 200 publicly.
- Final 6.9-inch screenshots are uploaded.
- App Privacy questionnaire is published.
- Age Rating questionnaire is complete.
- Release build passes Xcode 26.x device archive validation.
- The uploaded build finishes App Store Connect processing without blocking warnings/errors.
