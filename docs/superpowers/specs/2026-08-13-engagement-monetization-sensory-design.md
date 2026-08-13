# AfterStorm Engagement, Monetization & Sensory Experience Design

## Product intent
AfterStorm should feel like a premium animated life-restoration game that happens to improve the user’s real day. The product must earn retention through emotional attachment, visible world restoration, collectibility, sound/haptics, and meaningful progression — not through guilt, streak punishment, intrusive ads, or a mandatory account wall.

The core loop remains:

**real-life action → tiny quest → completion → cinematic restoration → reward → world/resident/collection progress → next meaningful action**

## Locked product principles

1. **Guest-first.** Users can complete onboarding and play immediately without creating an account.
2. **The core loop stays free.** Free users can meaningfully restore The Block, complete quests, progress, customize, and experience the product’s central promise.
3. **AfterStorm+ sells expansion, depth, and expression — not relief from an intentionally bad free tier.**
4. **Rewarded ads only.** No banner ads and no forced interstitials in the core flow.
5. **No punishment for inactivity.** The world never decays because the user missed a day.
6. **Full cinematic mode is the default visual ambition, with user-controlled intensity and accessibility overrides.**
7. **Sound and haptics are part of gameplay feedback, not decoration.**
8. **Every monetization moment must be contextual and value-first.** No first-launch hard paywall.

---

## 1. Avatar Studio usability fix

### Problem
Horizontal option scrollers inside the vertically scrolling Avatar Studio compete for gesture recognition on compact/Appetize-style viewports. The sticky bottom action dock also visually compresses the lower customization rows.

### Design
Replace horizontal chip scrollers with **adaptive wrapping option groups** inside one vertical ScrollView.

Each customization section — Palette, Stormling Body / Skin Tone, Head Shape / Hair, Eyes, Outfit, Accessory — uses a compact adaptive chip grid that wraps to available width.

Requirements:
- one dominant vertical scroll gesture;
- every option remains reachable above the sticky bottom action dock;
- selected chips use spring scale, glow, haptic feedback, and an obvious selected state;
- unlocked/premium cosmetic states are visually distinct but never block access to required base customization;
- avatar preview remains visible near the top and reacts live to changes.

---

## 2. Cinematic sensory system

### Experience levels
Add a persisted `ExperienceIntensity` preference with four modes:

- **Cinematic** — full weather, particles, parallax/camera drift, avatar reactions, glow, environmental motion, restoration bursts, richer haptic patterns.
- **Balanced** — full interaction feedback with reduced ambient particles/camera motion.
- **Calm** — minimal ambient motion, simple fades/springs, subdued effects.
- **Follow System** — derives motion/flash behavior from platform accessibility settings while keeping non-motion feedback intact.

Cinematic is the visual target, but the app must respect Reduce Motion and reduced-flashing accessibility preferences regardless of the selected preset.

### Fine-grained controls
Settings exposes independent controls for:
- Weather & particles
- Camera/parallax motion
- Lightning/flash effects
- Avatar idle animation
- Ambient audio
- Sound effects
- Haptics

The preset changes these controls as a group; advanced users may override individual controls afterward.

### Ambient animation
In Cinematic mode:
- Stormlings softly breathe, blink, shift expression, react to taps, and celebrate unlocks/restorations.
- Humans use restrained idle movement and celebratory reactions.
- World elements animate continuously where appropriate: clouds, rain, leaves, puddle reflections, power lights, signage, window glow, smoke/steam, birds returning, water, and weather transitions.
- Restored systems visibly come alive: lamps energize in sequence, bridge lights chase on, communications pulse, trees straighten, storefronts warm up, etc.
- Diorama camera uses subtle depth/parallax rather than aggressive game-camera motion.

### Interaction animation
- chip selection: compress → spring → glow lock;
- quest selection: card lift + soft haptic;
- completion: reward particles travel from quest result toward world/progress UI;
- restoration: localized world burst with matching sound/haptic pattern;
- collectible unlock: short staged reveal with rarity-aware feedback;
- premium unlock: tasteful gold/spark treatment, never casino-style flashing.

---

## 3. Sound design

Expand the existing `AudioService` into a preference-aware audio layer.

### Channels
- **Ambience:** rain, wind, distant thunder, city/town bed, birds, water, afterglow ambience.
- **UI SFX:** taps, selection, card lift, navigation accent, disabled/error feedback where needed.
- **Reward SFX:** quest complete, restoration impact, collectible unlock, premium unlock, resident reaction.

### Rules
- ambience and SFX are independently toggleable;
- ambience crossfades as restoration/weather state changes;
- audio never becomes required for comprehension;
- repeated UI sounds are short and restrained;
- major restoration moments may use layered sound but remain brief;
- platform audio/silent-mode behavior must be respected.

---

## 4. Haptic design

Keep basic UIKit feedback for normal interactions and add Core Haptics patterns for premium moments on supported devices.

### Haptic vocabulary
- soft tick: normal selection/toggle;
- light pulse: quest accepted;
- success notification: quest complete;
- heavy impact: power/bridge/building restoration;
- textured rumble: storm/lightning/world repair sequence;
- sparkle pattern: collectible/unlock;
- celebratory pattern: major district restoration.

Haptics are globally disableable. Calm mode uses only subtle semantic feedback. Reduce Motion does not disable haptics automatically.

---

## 5. Settings experience

Add a first-class **Settings** destination from Me.

### Sections
**Experience**
- Experience intensity preset
- Weather & particles
- Camera motion
- Lightning/flash effects
- Avatar animation

**Sound & Haptics**
- Ambience
- Sound effects
- Haptics

**Account & Sync**
- Current state: `Playing on this device`
- `Save My World` / iCloud sync entry point when available
- Game Center status/achievements entry point when available

**Notifications**
- gentle quest reminders
- seasonal/world event reminders
- no shame-based streak alerts

**Subscription**
- AfterStorm+ status
- Manage subscription
- Restore purchases

**Privacy & Data**
- existing privacy controls
- account deletion when an actual user account system is introduced

---

## 6. Account and cloud strategy

### Launch behavior
No mandatory sign-in during onboarding or before the first quest.

### Save My World
Introduce an optional **Save My World** moment after the user has already experienced value — for example after the first major restoration or from Settings/Me.

Preferred Apple-native direction:
- local SwiftData persistence first;
- private iCloud/CloudKit sync for world state and progress;
- graceful offline/local-only behavior;
- no email/password account required for basic play.

### Game Center
Game Center is a later engagement layer, not a launch blocker.

Use it for:
- achievements;
- friendly restoration challenges;
- optional social identity/discovery.

Avoid global productivity leaderboards that turn self-improvement into unhealthy competition.

---

## 7. Retention system

### Daily Storm Forecast
Each day the user sees three small suggested quests tuned to selected life areas and recent behavior. The user can ignore them without penalty.

### Progression hooks
- world districts/areas;
- residents with personalities/reactions;
- collectibles and cosmetic sets;
- restoration journal/history;
- meaningful stats/insights;
- widgets/Shortcuts for quick re-entry;
- seasonal restoration events;
- recurring content drops/world packs.

### Return language
No lost streaks, decay, or guilt.

Example return copy:
> “The storm waited. Restore one small thing today.”

---

## 8. Monetization architecture

### Free tier
Free users receive:
- complete core real-life quest → restoration loop;
- The Block base world;
- meaningful world progression;
- base human/Stormling avatar customization;
- residents and base collectibles;
- basic stats/progress;
- widgets/Shortcuts needed for the core experience;
- optional rewarded-ad opportunities.

### AfterStorm+
AfterStorm+ extends the experience with:
- premium worlds/districts;
- deeper avatar/world customization;
- premium weather/ambience/animation themes;
- seasonal restoration themes and expanded collections;
- additional residents/story content;
- advanced insights/statistics;
- expanded intelligent quest planning/personalization;
- ad-free experience.

The existing monthly and yearly StoreKit product IDs remain the subscription architecture. Exact App Store launch prices are a merchandising decision and are not hard-coded into this implementation spec.

### Contextual Plus entry points
Do not show a hard paywall on first launch.

Recommended Plus moments:
- user taps a premium world/district;
- user taps a premium cosmetic/theme;
- after a satisfying restoration when a new premium expansion is previewed;
- from Me/Settings;
- after the user has demonstrated repeated engagement, never as an interruption to an active quest.

### Rewarded ads
Rewarded ads are always opt-in.

Examples:
- **Supply Drop:** watch to receive bonus Sparks/materials;
- **Double Restoration Reward:** optional multiplier after a completed quest;
- **Temporary Weather/Cosmetic Preview:** try a premium visual effect for a limited session.

Rules:
- no banners;
- no forced interstitials;
- no ad before/inside a quest;
- reward is disclosed before playback;
- the user can always decline and continue;
- Plus removes rewarded-ad prompts from normal surfaces, while optional reward mechanics may simply provide the reward through Plus instead of requiring an ad.

### One-time cosmetics
One-time cosmetic/world-theme purchases may be added after launch validation. They are not required for the first monetization implementation cycle.

---

## 9. Purchase motivation

The purchase reason is **identity + expansion + depth**, not artificial friction.

Free users should think:
> “This already helps me and I want more of this world.”

Plus users should feel they gain:
- more places to restore;
- more ways to make the world/avatar theirs;
- richer atmosphere and seasonal content;
- smarter/deeper planning;
- a cleaner ad-free premium experience.

Every Plus preview should show the actual visual/content benefit instead of generic marketing copy.

---

## 10. Privacy and advertising guardrails

- Start with rewarded-only advertising.
- Prefer contextual/non-personalized advertising where practical.
- Do not add cross-app tracking solely to improve ad yield.
- Any future tracking behavior must be behind the platform’s required consent flow.
- Analytics should focus on product events such as onboarding completion, quest start/complete, restoration viewed, Plus screen viewed, trial/purchase outcome, and setting intensity — not invasive behavioral profiling.

---

## 11. First implementation cycle

This spec is broader than one safe code batch. Implementation is split into ordered phases.

### Phase 1 — Premium sensory/settings foundation
1. Fix Avatar Studio scrolling with adaptive wrapping option groups.
2. Add `ExperienceIntensity` + persisted sensory preferences.
3. Add Settings → Experience / Sound & Haptics controls.
4. Make existing AudioService and HapticsService respect preferences.
5. Add cinematic Stormling/avatar reactions and high-value world/UI motion using the preference system.
6. Add regression/accessibility tests and package a fresh Appetize build.

### Phase 2 — Retention layer
1. Daily Storm Forecast.
2. restoration journal and stronger progress insights;
3. achievements hooks/Game Center preparation;
4. notification preferences and gentle reminders;
5. seasonal/event architecture.

### Phase 3 — Monetization completion
1. Expand AfterStorm+ benefit presentation and entitlement-aware surfaces.
2. Restore-purchases/manage-subscription UX.
3. Premium world/cosmetic gates and contextual previews.
4. Rewarded-ad abstraction and provider integration.
5. Purchase/ad analytics events with privacy guardrails.

### Phase 4 — Save My World
1. Cloud sync model review/migration plan.
2. private iCloud/CloudKit sync;
3. recovery/conflict behavior;
4. optional Game Center identity/achievement layer.

---

## 12. Acceptance criteria

Phase 1 is accepted when:
- Avatar Studio reaches every customization option with one reliable vertical scroll on compact iPhone/Appetize viewports;
- Cinematic mode visibly delivers stronger ambient/world/avatar motion than the current build;
- Balanced and Calm visibly reduce intensity;
- system Reduce Motion overrides nonessential motion appropriately;
- sound, ambience, haptics, lightning/flash, particles, camera motion, and avatar animation can be controlled from Settings;
- preferences persist across launches;
- normal interactions have restrained tactile/audio feedback and major restoration moments have richer synchronized feedback;
- no primary CTA is obscured by a sticky dock;
- the app still builds through the manual Azure package-only pipeline and can be inspected in Appetize.

The broader monetization design is accepted when the core loop remains fully usable for free users, Plus has clear recurring expansion value, ads are opt-in rewarded-only, and no mandatory login blocks first value.

## Out of scope for Phase 1
- ad SDK integration;
- CloudKit production migration;
- Game Center production integration;
- new one-time cosmetic SKUs;
- final subscription pricing/offer configuration;
- large new world packs.
