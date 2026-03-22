# Premium Animation Upgrades — Springs, Parallax, Haptics & Numeric Transitions

## Features

- **Upgraded stagger animations** — All cards across Home, Wallet, Tools, Community, and Profile will slide in with premium spring physics (snappier, more responsive feel)
- **Numeric text transitions** — All monetary values ($amounts) animate smoothly when they change, with a counting/rolling effect
- **Parallax hero card** — The "Total Saved This Month" card on Home subtly moves at a different scroll speed, creating depth
- **Enhanced haptic feedback** — Consistent haptic responses: light taps on cards, medium on CTA buttons, success feedback on saving wins, selection feedback on toggles/filters
- **Pull-to-refresh haptic** — A subtle haptic pulse when pulling to refresh on Home
- **Premium page transitions** — Smoother slide+fade transitions between screens

## Design

- **Spring animations everywhere** — Replace any remaining `easeOut`/`easeIn` with spring-based motion for a natural, bouncy iOS feel
- **Staggered card entrance** — Cards appear one after another with slight delays (0.08s between each), sliding up from 16pt below with a spring bounce
- **Parallax depth** — Hero savings card moves at 80% of scroll speed, creating a subtle floating effect
- **Numeric roll** — Dollar amounts use `.contentTransition(.numericText())` so numbers visually animate when values change
- **Button press depth** — All primary buttons already have the premium shadow+scale style; this will be consistently applied everywhere

## Changes

### Theme & Animation Utilities
- Add `Theme.springStagger` and `Theme.springSnappy` animation presets for consistent motion
- Upgrade the `staggerIn` modifier to use snappier spring parameters and 16pt offset
- Add a new `parallaxOffset` modifier for scroll-based parallax effect
- Ensure `PressableButtonStyle` is already premium (it is — shadow + scale + brightness)

### Home Screen
- Add `.contentTransition(.numericText())` to the hero saved amount and comparison text
- Add parallax scroll effect to the hero card using `GeometryReader` offset
- Add haptic on pull-to-refresh completion
- Ensure all sections use consistent stagger timing

### Wallet Screen
- Add `.contentTransition(.numericText())` to stat pills and transaction amounts
- Ensure stagger animations use the upgraded spring parameters

### Tools Screen
- Already has good stagger animations — tune spring parameters to match new presets

### Community Screen
- Add stagger animations to post cards appearing in the feed
- Ensure haptics on like button and category filter

### Profile Screen
- Upgrade `sectionFadeIn` modifier to use premium spring parameters matching the rest of the app

### Content View (Tab Bar)
- Add `.sensoryFeedback(.selection)` on tab changes for haptic on every tab switch
