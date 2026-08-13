# AfterStorm Onboarding Flow + Studio Intro Polish Design

## Goal
Fix the first-run flow so a user can always progress on compact iPhone/Appetize viewports, while making the Storm and Me Studios intro feel more intentional and premium.

## Scope

### 1. Storm and Me Studios intro
Sequence:
1. Dark atmospheric background appears.
2. Cloud materializes first.
3. Lightning flashes/strikes into the cloud.
4. A gold bolt remains visibly embedded in the cloud after the strike.
5. “STORM AND ME” and then “STUDIOS” resolve beneath it.
6. The intro hands off to the storm reveal/onboarding flow.

Reduce Motion keeps the final composed logo visible without the full animated strike sequence.

### 2. Life-area selection screen
The current Continue button is inside the ScrollView below the category grid. On shorter viewports it can be off-screen and appear missing.

New layout:
- Header + category grid + “Honestly… everything” remain scrollable.
- A sticky safe-area bottom action area contains a prominent Continue button.
- Continue remains disabled until at least one area is selected.
- Selected states remain visually obvious.
- Bottom content receives enough padding so the sticky CTA never covers cards.

### 3. Avatar choice screen
Keep the existing visible “That’s Me” CTA, but audit spacing/safe-area behavior on compact screens. No functional redesign unless needed for consistency.

### 4. Avatar customization screen
The current “That’s Me” CTA is also at the end of a long ScrollView and can suffer the same hidden-action problem.

New layout:
- Avatar preview and customization pickers remain scrollable.
- “That’s Me” moves into the same sticky safe-area action treatment used by life-area selection.
- Bottom scroll padding prevents overlap.

### 5. Storm reveal and first quest
Audit the existing Begin and quest actions for compact-screen visibility. Preserve their current flow unless a real layout issue is found.

## Navigation behavior
The onboarding phase order remains unchanged:
Studio Intro → Storm Reveal → Life Areas → Avatar Choice → Avatar Studio → First Quest.

No authentication/sign-in is added in this patch. AfterStorm remains immediately usable without creating an account; account/cloud-sync can be designed separately later if it provides enough user value.

## Error/edge handling
- Selection state survives scrolling because it stays local view state until Continue.
- Disabled Continue state is visually muted and inaccessible as an action until a selection exists.
- Safe-area insets are respected so CTAs are not hidden by the home indicator.
- Reduce Motion receives a complete final studio mark instead of a partially animated state.

## Verification
- Build the iOS simulator target.
- Test the onboarding flow on a compact iPhone viewport.
- Verify Continue is visible before and after selecting categories.
- Verify avatar customization CTA remains visible while content scrolls.
- Verify all onboarding transitions reach First Quest.
- Verify the intro ends with the cloud + retained bolt + Storm and Me Studios wordmark.
- Repackage the simulator `.app` for Appetize and visually inspect the complete flow.

## Out of scope
- Sign-in/authentication.
- Cloud account sync redesign.
- New onboarding questions.
- Changes to quest generation/business logic.
