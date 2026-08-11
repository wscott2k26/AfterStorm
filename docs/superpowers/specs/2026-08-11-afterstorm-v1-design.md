# AfterStorm V1 Design

## Product
**Name:** AfterStorm  
**Studio:** Storm and Me Studios  
**Tagline:** Rebuild your world by rebuilding your day.

## Product Standard
AfterStorm is a commercial, App Store-grade native iOS product. It must not look or behave like an AI-generated prototype. The visual bar is premium: cinematic pacing, tactile controls, custom world/character art, polished sound design, meaningful haptics, coherent typography, consistent motion, and a refined Apple-native shell.

## Core Promise
AfterStorm turns ordinary real-life accomplishments into small, achievable quests. Completing a quest causes an immediate, visible restoration in a storm-damaged miniature world. The app rewards forward motion without guilt, destructive streaks, or punishment for absence.

## Core Loop
1. Open AfterStorm.
2. See the living world and current weather/state.
3. Receive three smart quest suggestions or tap **Give Me a Quest**.
4. Complete one small real-life action.
5. Confirm completion; optional proof/photo.
6. Trigger a cinematic restoration reveal.
7. Earn Sparks and unlock progression.
8. Return to the world with a visible lasting improvement.

## Experience Pillars
### 1. Premium Visual Identity
- Cozy stylized 3D forms.
- Realistic lighting, rain, reflections, clouds, fog, sunset, and volumetric atmosphere.
- Storybook/diorama composition.
- Stormlings as signature original characters, with humans and animals living alongside them.
- Premium translucent system surfaces and native Apple material effects where appropriate.
- Tactile controls with springy compression, depth, and micro-motion.
- No generic template cards, stock clip art, or flat web-wrapper appearance.

### 2. Cinematic Pacing
- Smooth camera moves instead of abrupt screen swaps.
- Subtle parallax and breathing backgrounds.
- Restoration reveals use camera motion, lighting changes, audio, and haptics.
- Motion must clarify state changes, never exist as visual noise.

### 3. Tactile Feedback
- Button press states physically compress and rebound.
- Success, warning, completion, unlock, and restoration events use distinct haptic signatures.
- Audio cues are restrained, memorable, and matched to the world.

### 4. Useful Gamification
- One currency: **Sparks**.
- Visible world restoration is the primary reward.
- Unlockable avatar items, decorations, residents, small pets, seasonal cosmetics, and environment variations.
- No punitive streak destruction.
- No dark patterns or fake urgency.

### 5. AI as Enhancement, Not Dependency
- LocalQuestEngine provides useful quests on every supported device.
- IntelligentQuestEngine can improve recommendations with Apple Foundation Models when available.
- Image understanding can convert a photographed space/work area into structured micro-quests.
- Voice/text can turn statements like “I have ten minutes” into appropriately-sized quests.
- AI output must be structured, bounded, and actionable; no generic chatbot home screen.

## First Launch Flow
### 00 — Storm and Me Studios Intro
Every launch begins with a beautiful Storm and Me Studios animation.
- Dark screen.
- Distant thunder.
- Clouds form around the brand mark.
- Lightning flash through the logo.
- Rain/particle pass.
- **STORM AND ME STUDIOS** resolves.
- Transition directly into AfterStorm.
- Repeat-launch version targets ~1–2 seconds; first launch may be longer.

### 01 — The Storm
Cinematic reveal of The Block after a storm.
Copy:
- “Every storm leaves something behind.”
- “But little things can rebuild a world.”
CTA: **Begin**

### 02 — What Needs Restoring?
Multi-select personalization:
- Home & clutter
- Work & productivity
- Focus & procrastination
- Digital mess
- Movement & energy
- Learning & growth
- Errands & life admin
- Honestly… everything

### 03 — Choose Who You Are
Choose:
- Custom human avatar
- Custom Stormling

### 04 — Quick Avatar Studio
Launch-level customization only:
- Human: skin tone, hair, eyes, outfit, accessory.
- Stormling: body/fur style, head shape, eyes, outfit, accessory.
- Deeper cosmetics unlock later.

### 05 — First Quest
Show three tiny quests personalized from onboarding plus **Give Me a Quest**.
Goal: first meaningful action within minutes, not a long setup funnel.

## Main Navigation
Four tabs:
1. **World**
2. **Quests**
3. **Collection**
4. **Me**

The **Give Me a Quest** action stays prominent on World and Quests.

## Core Screens
### 06 — World
Primary emotional home screen.
- Interactive 3D diorama: **The Block**.
- Shows current restored state, residents, weather, and environment changes.
- Main actions: Give Me a Quest, Scan My World, Tell AfterStorm, View Restoration.

### 07 — Quests
- Suggested for You
- Quick Wins
- Continue Something
- Filters: 2 min / 5 min / 10 min / 20+ min
- Category chips based on user profile.

### 08 — Quest Detail
Includes:
- Title
- Approximate time
- Plain-language instruction
- Reward preview
- Restoration target
- Start Quest
- Swap Quest

### 09 — Scan My World
- Camera capture.
- Analyze scene when available.
- Produce three structured micro-quests.
- Never shame user.
- Photos not saved by default.

### 10 — Tell AfterStorm
Voice/text prompts converted into bounded quests.
Examples:
- “I have ten minutes.”
- “My office is a mess.”
- “I need something easy.”

### 11 — Quest Mode
Minimal distraction.
- Quest title
- Optional timer
- Stormling companion animation
- Pause
- Done
- Need Something Easier

### 12 — Quest Complete
- **I DID IT**
- Optional after photo
- Success haptic/audio
- Immediate transition into restoration reveal

### 13 — Restoration Reveal
The dopamine centerpiece.
- Camera flies to affected world node.
- Building/environment animation plays.
- Weather/light/audio respond.
- Residents react.
- Sparks award appears.

### 14 — Restoration Map
Visual map of The Block:
- Homes
- Power Station
- Workshop
- Park
- Main Street
- Bridge
- Corner Store

### 15 — Residents
Stormlings, humans, animals.
Each can have:
- Name
- Personality
- Tiny story
- Home/location
- Contextual reactions

### 16 — Collection
- Avatar outfits
- Stormling accessories
- Decorations
- Plants
- Lamps
- Benches
- Signs
- Weather effects
- Pets
- Seasonal items

### 17 — Progress
Positive framing only.
- Things You Restored
- This Week
- All Time
- Quest Categories
- Favorite Quest Length
- Areas Restored

Return message after absence:
**“Welcome back. The storm waited for you.”**

## V1 World: The Block
Initial state:
- Five damaged homes
- Corner store
- Park
- Workshop
- Bridge
- Trees
- Streetlights
- Power station
- Roads
- Stormling homes
- Animals
- Rain/weather system

Restoration milestones visibly transform this same environment rather than sending the user through disconnected levels.

## Progression
Example restoration sequence:
- Porch light returns
- Fallen tree removed
- Flowers grow
- Store reopens
- Stormlings return outside
- Bridge repaired
- Neighborhood celebration

The final V1 completion pulls the camera back and reveals another damaged district in the distance.
Copy: **“The storm was bigger than we thought.”**

## Design System
### Surfaces
- Native materials/translucent surfaces where legibility remains strong.
- Avoid visual overload; the world is the hero.
- Controls use depth, soft highlights, realistic shadows, and spring motion.

### Typography
- Apple-native readability first.
- Use hierarchy, spacing, and weight before decorative typefaces.
- Brand display face may be used sparingly for titles/marketing, never at the expense of accessibility.

### Motion
- Spring-based interactions.
- Environmental parallax.
- Character idle loops.
- Restoration-specific animations.
- 60fps target on supported devices.

### Sound
- Custom Storm and Me Studios sting.
- Rain/thunder ambience.
- Soft environmental loops.
- Distinct quest complete/restoration/unlock sounds.
- Music evolves as The Block recovers.

### Haptics
- Subtle tap feedback.
- Confirm/complete response.
- Restoration impact pulse.
- Unlock signature.

## Technical Architecture
### App Shell
- Swift
- SwiftUI
- SwiftData
- Swift Testing

### World Layer
- RealityKit embedded through SwiftUI.
- World renderer owns visuals only.
- Quest/business logic does not live in world rendering code.

### Quest Engine
Protocol: `QuestEngine`
- `LocalQuestEngine`
- `IntelligentQuestEngine`

The local engine is mandatory and complete enough for the product to function without Apple Intelligence.

### Data Models
- UserProfile
- AvatarProfile
- Quest
- QuestCompletion
- WorldState
- RestorationNode
- Collectible
- AppSettings

### Services
- QuestService
- WorldProgressService
- HapticsService
- AudioService
- PurchaseService
- PersistenceService
- Optional CloudSyncService
- Optional IntelligentQuestService

### Apple Integrations
- App Intents: Give Me a Quest
- WidgetKit: current world/weather + quick quest
- StoreKit 2: premium entitlements
- CloudKit: optional sync where appropriate
- Foundation Models / Vision: intelligent quest generation and scene understanding when supported

## Monetization
Free must feel complete.

### Free
- The Block
- Core quest loop
- Basic scan/text/voice quest generation
- Stormlings
- Core progression
- Basic avatar customization
- Widgets

### AfterStorm+
Potential additions:
- Additional worlds
- Premium restoration themes
- Expanded customization
- Seasonal worlds
- Advanced personalized planning
- Expanded collectibles

No immediate install paywall. Let users experience a restoration reveal first.

## Privacy
- Camera images not stored by default.
- Local-first activity storage.
- Cloud sync optional where appropriate.
- No sale of sensitive personal productivity/behavior data.
- Clear permissions and graceful denial states.

## Accessibility
- Dynamic Type support where practical.
- VoiceOver labels for all actionable UI.
- Sufficient contrast over glass/material surfaces.
- Reduced Motion behavior.
- Haptic/audio events cannot be the only way information is conveyed.

## Deliberately Not in V1
- Social network
- Multiplayer
- Leaderboards
- Clans
- Chatrooms
- Combat/RPG battle systems
- Multiple currencies
- Full Apple Watch app
- Android
- Huge crafting economy
- Punitive streak mechanics

## Engineering Rules
1. Important logic gets tests first.
2. No giant files or God objects.
3. Each service has one responsibility.
4. AI logic stays outside UI.
5. World rendering stays outside quest logic.
6. AI must fail gracefully.
7. No TestFlight build before local validation passes.
8. No feature enters V1 just because it sounds cool.
9. V1 must remain explainable in one sentence.
10. Every completed quest creates a visible payoff.
11. No mock-only critical flows in production.
12. Premium polish is a product requirement, not a post-launch phase.

## Premium Acceptance Bar
Before V1 is considered release-ready:
- Launch animation polished.
- Onboarding visually cohesive.
- No placeholder art/icons in user-facing flows.
- Every primary interaction has a designed pressed/loading/success/error state.
- Core transitions are animated intentionally.
- Haptics and sound are tuned, not scattered randomly.
- RealityKit world holds stable frame rate on target devices.
- App works with AI disabled/unavailable.
- Accessibility pass complete.
- Purchase/entitlement flow tested.
- App Store screenshots reflect the actual product.
- No obvious stock/template aesthetic.
- No dead-end screens.
- No fake data in release-critical paths.

## V1 Success Test
A new user can:
**Install → see Storm and Me Studios → understand the world → personalize → receive a quest → complete a real action → watch the world transform → want to do another one.**

If that loop is not delightful, nothing else ships ahead of fixing it.
