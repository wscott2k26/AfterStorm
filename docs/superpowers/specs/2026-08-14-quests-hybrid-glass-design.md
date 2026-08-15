# AfterStorm Quests Hybrid Glass Design

## Goal
Make the Quests screen unmistakably read as premium glass while preserving the existing storm atmosphere, quest hierarchy, readability, accessibility, and interactions.

This is a focused visual-quality pass. It does not redesign the app or change quest behavior.

## Locked Direction: Hybrid Glass C

The approved visual formula is **dark luxury smoked glass + crystal highlights**.

The screen should read visually as:

**storm world → translucent/reflected glass → crisp content**

not:

**blue background → gray panel → text**

## 1. Quest Discovery Cards

Quest cards must stop relying on a plain `.ultraThinMaterial` panel with a faint border.

Each card should combine:
- smoked navy/charcoal translucent material;
- adaptive tint from `RestorationVisualState`;
- a brighter top/leading crystal edge;
- a softer opposing edge;
- an internal reflective/specular gradient;
- subtle teal/blue refraction and restrained warm accent where the adaptive palette provides it;
- a dark depth shadow plus a restrained accent bloom;
- rounded premium geometry;
- strong text contrast.

The background must visibly influence the card surface so it reads as glass rather than a solid gray rectangle.

The life-area icon well should use a smaller inset glass treatment with blue/teal luminosity and a clearer rim without competing with the card.

## 2. Filter Chips

Duration and life-area filters should use a reusable compact glass control instead of default `.bordered` buttons.

Unselected state:
- dark translucent glass;
- restrained crystal edge;
- readable text and icon;
- subtle depth.

Selected state:
- brighter adaptive teal/blue luminosity;
- clearer crystal rim;
- restrained warm/gold highlight when present in the adaptive visual state;
- slightly stronger lift/glow;
- no neon treatment.

## 3. Give Me a Quest CTA

The primary CTA should be the strongest glass surface on the screen.

It should use:
- brighter top highlight;
- stronger internal blue/teal luminosity;
- richer depth and shadow;
- slightly stronger adaptive glow;
- high-contrast label;
- existing tactile press behavior where available.

The CTA remains in its existing role and layout.

## 4. Adaptive Glass Architecture

`AfterStormApp/Design/AdaptiveGlassSurface.swift` remains the centralized glass system.

Enhance it only as needed to support the Hybrid Glass C recipe. Do not create a second unrelated glass language.

The component must continue to:
- use `afterStormVisualState`;
- respond continuously to restoration progress;
- respect `accessibilityReduceTransparency`;
- avoid expensive or unstable effects;
- preserve readable fallbacks.

A compact reusable glass-chip style may be added near the adaptive glass system so filters use the same optical language.

## 5. Background Relationship

The Quests screen should use the richer adaptive storm background where supported by the existing architecture, rather than flattening the screen to a static gradient.

There must be enough environmental variation behind surfaces for the translucency and reflection to be visually legible.

## 6. Readability

Mandatory:
- quest titles remain crisp and bright;
- instructions remain clearly readable;
- time/reward rows remain legible;
- section headings remain distinct;
- filter labels remain high contrast;
- the CTA remains dominant.

No low-contrast gray-on-gray treatment is acceptable.

## 7. Motion

Keep motion restrained in this pass.

Allowed:
- existing button compression/spring;
- subtle selected-state lift;
- subtle non-looping highlight response if already supported.

Not allowed:
- continuous shimmer loops;
- distracting animated sweeps;
- large animation refactors.

## 8. Scope

In scope:
- `QuestsView` quest cards;
- duration filter chips;
- life-area filter chips;
- `Give Me a Quest` CTA treatment;
- targeted improvements to centralized adaptive glass primitives;
- background/depth relationship on the Quests screen;
- regression contracts for this pass.

Out of scope:
- World redesign;
- Me redesign;
- Collection redesign;
- MainTabView restructuring;
- quest generation changes;
- persistence changes;
- network/AI behavior changes;
- onboarding changes;
- monetization or accounts.

## 9. Acceptance Criteria

The pass is complete only when:
1. Quest cards visibly read as translucent premium glass.
2. Cards no longer resemble flat gray/slate panels.
3. Background color/light visibly influences glass surfaces.
4. Crystal highlights are visible but tasteful.
5. Filters look like miniature glass controls.
6. Selected filters are clearly differentiated from unselected filters.
7. `Give Me a Quest` reads as the strongest hero glass control.
8. Typography remains highly readable.
9. Reduce Transparency behavior remains functional.
10. Existing quest interactions continue working.
11. No unrelated app behavior changes.
12. Swift tests pass.
13. Full Xcode 26.3 iOS Simulator build passes.
14. The widget builds.
15. The Appetize simulator ZIP is created and verified.

## 10. Verification Environment

Use macOS 15 and Xcode 26.3.

Required checks:
- `swift test`;
- deterministic asset generation;
- XcodeGen project generation;
- full `xcodebuild` Debug simulator build with signing disabled;
- verify `AfterStorm.app/Info.plist`;
- verify `AfterStorm.app/PlugIns/AfterStormWidget.appex/Info.plist`;
- package with `ditto`;
- verify both paths inside the ZIP.
