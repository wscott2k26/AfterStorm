# AfterStorm Reactive Visual Luxury System Design

## Goal
Raise AfterStorm from a clean dark interface to a visually distinctive premium experience whose atmosphere visibly heals with the player’s progress.

The visual identity is now locked around three adaptive systems working together:

1. **Reactive Storm-to-Afterglow Background**
2. **Adaptive Real-Glass UI**
3. **Adaptive Accent Lighting**

The design must feel cinematic, emotional, and premium without compromising readability, accessibility, performance, or the core quest loop.

---

## 1. Reactive Storm-to-Afterglow Background

The background is not a flat color or static gradient. It is a living atmospheric scene tied to restoration progress.

### Early restoration — damaged world
- Deep navy and blue-black storm clouds.
- Cooler electric-blue highlights.
- Visible cloud depth, mist, rain haze, and occasional lightning presence when allowed by accessibility/settings.
- Stronger contrast between the dark sky and luminous UI.
- Overall mood: dramatic but beautiful, never grim or oppressive.

### Mid restoration — clearing world
- Storm remains visible but begins opening up.
- Teal and silver-blue light enters the sky.
- Clouds separate and atmosphere becomes more dimensional.
- Reflections, mist, and glow become brighter and more colorful.
- Overall mood: visible progress and relief.

### High restoration — afterglow
- Storm is calmer rather than completely erased.
- Warm gold, amber, rose, and soft sunset light enters the composition.
- Blue/teal tones remain underneath so the visual identity still feels like AfterStorm.
- Windows, lamps, road reflections, and glass surfaces pick up more warm light.
- Overall mood: earned beauty and restoration.

### Progress mapping
Visual progress is continuous rather than switching between three disconnected themes. Restoration fraction drives interpolation among storm, clearing, and afterglow states.

The world should visually answer the user’s real-life progress: every completed quest makes the atmosphere feel slightly more alive.

---

## 2. Real Storm Presentation

The storm must feel like a real atmospheric environment, not a decorative blue gradient.

Required layers:
- multi-depth cloud masses;
- atmospheric glow behind clouds;
- fog/mist haze;
- rain or particle depth when enabled;
- soft light blooms;
- restrained lightning flashes;
- wet-road/reflection response;
- slow parallax/depth movement in Cinematic mode.

The implementation may use deterministic SwiftUI-rendered atmospheric layers and generated image assets where they improve fidelity, but the experience must remain responsive on supported iPhones and in Appetize simulator builds.

The background must never overpower text or primary actions.

---

## 3. Adaptive Real-Glass UI

The UI uses a hybrid glass system rather than flat translucent panels.

### Storm state
- Smoked blue-black glass.
- Heavier blur and deeper shadow separation.
- Cool blue edge lighting.
- Slightly more opaque surfaces for readability against the storm.

### Clearing state
- Glass becomes clearer.
- Teal/silver highlights become more visible.
- Reflections brighten.
- Shadow depth softens slightly.

### Afterglow state
- Glass remains translucent but picks up warm gold/amber highlights.
- Internal reflections feel warmer.
- Edge lighting is brighter and more celebratory on key surfaces.
- Premium rewards and restoration moments may use stronger warm caustic-like glow.

### Real-glass characteristics
Every major premium surface should combine several of these rather than relying only on `.ultraThinMaterial`:
- backdrop blur/material;
- adaptive tint;
- top/leading light-catching edge;
- softer opposing edge;
- internal highlight gradient;
- subtle glossy sweep or reflected light;
- layered outer shadow;
- restrained colored bloom around selected/important content;
- shape-specific depth appropriate to cards, capsules, and buttons.

The intent is optical depth, not fake transparency.

---

## 4. Adaptive Accent Lighting

Accent color is progress-aware and mixed rather than one fixed brand color.

### Accent progression
- Early: electric storm blue.
- Mid: teal/cyan mixed with blue.
- High: warm gold mixed with residual teal/blue.

### Usage
Adaptive accent affects:
- selected cards/chips;
- primary button edges and glows;
- progress indicators;
- Sparks/reward moments;
- glass highlights;
- restoration pulses;
- world lights and reflections where appropriate.

No screen should become monochromatic. The premium look depends on layered color relationships rather than simply replacing blue with gold.

---

## 5. Premium Hero Treatment

Screens with a central avatar, world, quest, or restoration object must feel staged rather than dropped onto a plain panel.

### Avatar Studio / Me
- Avatar sits in a luminous atmospheric hero stage.
- Adaptive halo/glow behind the avatar.
- Faint storm/afterglow depth behind the circular preview.
- Selected customization options use richer glass-chip states.
- Eyes/Outfit/Accessory remain in the existing single vertical-scroll layout.

### Quest screens
- Primary quest cards receive stronger depth and selected-state lighting.
- Primary CTA should feel like a thick glass control with internal gradient and tactile compression.
- Reward/Sparks treatment should use adaptive light rather than a flat icon color.

### Main World
- World remains the visual hero.
- Bottom control dock should appear suspended above the environment, with the storm/world visibly influencing the glass tint.
- The UI should not hide the diorama behind large opaque surfaces.

---

## 6. Motion and Light Behavior

The previously approved sensory settings remain authoritative.

### Cinematic
- Full cloud drift/parallax.
- Slow moving glow and reflected-light sweeps.
- Subtle glass highlight movement.
- Rich avatar motion and ambient world life.
- Lightning/rain particles when enabled.

### Balanced
- Reduced camera drift.
- Slower/subtler highlight movement.
- Weather remains but with lower visual intensity.

### Calm
- No nonessential camera drift.
- No moving glossy sweeps.
- Weather particles and flashes follow Calm/settings behavior.
- Static gradients/glow preserve visual richness without motion.

### Follow System
- Respects system Reduce Motion first.
- Uses the app’s adaptive visual system at a restrained motion level when motion is permitted.

Accessibility settings always override decorative motion.

---

## 7. Tactile and Sensory Integration

Visual luxury must stay synchronized with the Phase 1 sensory system.

- Primary glass buttons compress/spring on touch.
- Selected chips brighten and lift subtly.
- Major restoration moments combine glow expansion, audio, and the richer haptic pattern.
- Collectible unlocks use sparkle-like visual and haptic feedback.
- Sound/haptics remain individually disableable.

The app should feel responsive even with audio disabled.

---

## 8. Readability Rules

Premium effects may never make content harder to use.

- Text contrast must remain strong over all storm states.
- Glass opacity/tint increases automatically when the background behind it becomes visually busy.
- Small text never relies on glow for readability.
- Primary actions must remain visually dominant.
- Decorative light sweeps never pass across text strongly enough to reduce legibility.
- Reduce Transparency and Reduce Motion behavior must degrade gracefully.

---

## 9. Architecture

The luxury system should be centralized instead of hand-tuning every screen independently.

Recommended units:

### `RestorationVisualState`
Consumes restoration fraction and exposes interpolated values for:
- background gradient/colors;
- storm/afterglow intensity;
- glass tint;
- accent colors;
- glow intensity;
- atmosphere/light levels.

### `AdaptiveStormBackground`
Reusable living background driven by `RestorationVisualState` and `ExperiencePreferences`.

### `AdaptiveGlassSurface`
Reusable container modifier/view that produces the smoked-to-clear glass treatment with adaptive edge light and shadow.

### `AdaptiveAccent`
Centralized accent palette derived from restoration state.

### Existing views
Main screens consume these components rather than manually creating unrelated gradients.

This preserves consistency and makes future worlds/themes easier to add.

---

## 10. First Visual-Luxury Pass Scope

The first implementation pass applies the system to the highest-impact screens only:

1. Life Area selection.
2. Avatar Choice.
3. Avatar Studio.
4. Quest selection/detail.
5. Quest Complete.
6. Restoration Reveal.
7. Main World control dock.
8. Me/Settings surfaces where visible during normal play.

The underlying world-diorama progression remains intact; this pass enhances atmosphere and presentation rather than redesigning game logic.

---

## 11. Verification

### Code verification
- Swift source parse/typecheck where available.
- Existing core tests remain green.
- Add regression contracts for centralized adaptive visual components.
- Xcode simulator build must pass before calling the pass complete.

### Visual verification in Appetize
Check at minimum:
- damaged/storm state;
- mid-restoration/clearing state;
- high-restoration/afterglow state;
- Avatar Studio on compact iPhone;
- Main World;
- Restoration Reveal;
- Cinematic vs Calm settings.

Acceptance criteria:
- gradients are visibly richer than current flat dark treatment;
- storm reads as atmospheric and layered;
- glass reads as dimensional rather than gray/translucent;
- accent color visibly evolves with restoration;
- UI remains readable;
- no primary actions become hidden or clipped;
- Calm/Reduce Motion retains the premium look without unnecessary animation.

---

## 12. Out of Scope

This visual-luxury pass does not add:
- new monetization logic;
- new account/authentication behavior;
- rewarded-ad SDK integration;
- Game Center;
- new quest-generation rules;
- new world progression mechanics.

Those remain separate product phases.

---

## Locked Visual Formula

**Real storm atmosphere + reactive restoration gradients + adaptive smoked-to-clear glass + adaptive blue/teal/gold accents + cinematic depth + tactile sensory feedback.**

When a future visual decision requires choosing between static vs adaptive, flat vs layered, or single-tone vs mixed, the default AfterStorm direction is **adaptive, layered, mixed, and premium**, provided readability and accessibility remain strong.
