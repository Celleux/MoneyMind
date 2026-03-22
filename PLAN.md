# Premium Paywall Screen with Personality Theming

## Features

- **Full-screen paywall** that appears when tapping premium features, presented as a cover that can only be closed via the X button
- **Personality-aware design** — colors, icon, and messaging adapt to the user's Money Personality (e.g. "As a Builder, you need these tools")
- **Animated feature list** — 5 premium features stagger in from the left with icons in the user's personality color
- **Social proof section** — overlapping avatar circles, "10,000+ members" text, and a 4.8-star rating display
- **Two pricing cards side by side** — Monthly ($4.99) and Annual ($39.99/yr) with a gold "BEST VALUE" badge on annual
- **"Start 7-Day Free Trial" call-to-action** button in the user's personality color with compliance text below
- **Restore Purchases and legal links** at the bottom (Terms, Privacy)
- **Premium state tracking** — a simple flag so the app knows if the user is premium (no real payments yet — RevenueCat will be connected later)

## Design

- **Dark OLED background** (#0A0F1E) consistent with the rest of the app
- **Top area**: Close (X) button top-right in muted gray. MoneyMind icon with a glowing pulse animation in the user's personality color. Bold headline and personality-referenced subtext
- **Feature list**: Each row has an SF Symbol icon in personality color, feature name in white, and a one-line description in gray. Items animate in with a staggered slide-from-left effect
- **Social proof**: Five small overlapping colored circles simulating avatars, star rating in gold, member count
- **Pricing cards**: Two dark cards (#111827) side by side. Annual card is slightly taller with a gold "BEST VALUE" badge and a green "Save 33%" pill. Selected card gets a glowing personality-color border
- **CTA button**: Full-width, personality-colored, with bold white text. Subtle compliance text ("Then $X/month. Cancel anytime.") below in small muted text
- **Bottom links**: "Restore Purchases", "Terms", "Privacy" in small muted text
- **Haptic feedback** on plan selection and CTA tap
- **Spring animations** throughout, matching the app's existing motion language

## Screens

- **PaywallView** — the full-screen premium paywall described above. Scrollable if content overflows. Reads the user's personality from SwiftData to theme everything dynamically
- **Trigger points wired in** — a "show paywall" state added to the main content area so any screen can present it (initially triggered from Profile and anywhere premium features are gated)
