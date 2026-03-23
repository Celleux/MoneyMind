# New Onboarding Phases 1–4: Financial DNA Model + First 3 Screens

## Overview

Build the foundation for the new premium onboarding: the 4-axis Financial DNA personality model and the first 3 interactive screens (Cinematic Splash, DNA Intro, and Spending Pattern Card Sort).

The old onboarding files are kept for now — they'll be replaced when the full flow is wired in a later phase.

---

## Phase 1: Financial DNA Model

- **FinancialDNA** — A 4-axis personality system (Spending Style, Money Emotion, Risk Profile, Social Money), each on a 0.0–1.0 spectrum
- **FinancialArchetype** — 5 archetypes (Guardian, Strategist, Adventurer, Empath, Visionary) with icons, colors, taglines, descriptions, strengths, blind spots, and quest preferences
- **FinancialDNAResult** — Stored result that saves all 4 axis scores, archetype names, raw answers, and trigger ratings
- A helper Color extension for string-based hex codes (e.g. `"#34D399"`) since the project currently only has the integer-based version
- Register the new model in the app's data container

---

## Phase 2: Cinematic Splash Screen

- A 3-second cinematic intro with timed animation phases
- "SPLURJ" logo fades in, scales up with spring physics
- Tagline "Your money. Unmasked." fades in below in emerald
- Background shifts from pure dark to a subtle emerald-tinted gradient
- Everything fades up and out, then auto-advances to the next screen

---

## Phase 3: Financial DNA Intro Screen

- Headline: "Discover Your Financial DNA"
- Subhead: "A 2-minute deep scan of how your brain handles money"
- 4 animated preview cards showing the DNA axes (Spending Style, Money Emotions, Risk Profile, Social Money) with empty spectrum bars that shimmer
- Cards stagger in from below with spring animation
- Bottom text about behavioral economics research
- "Start My Scan" emerald gradient button with gentle pulse
- The axis preview card is built as a reusable component (used again in the reveal screen later)

---

## Phase 4: Spending Pattern Card Sort

- 8 real-world financial scenario cards presented one at a time, Tinder-style swipe interaction
- Each card shows a scenario icon, text, and axis label
- Drag left or right to choose a response — card rotates with drag, shows response stamp overlay
- Swipe past threshold animates card off-screen, advances to next
- Snap-back spring animation if released before threshold
- Progress dots at top (emerald for completed, white for current, dark for upcoming)
- Next card visible behind current card (dimmed, slightly smaller)
- Swipe hint labels at bottom that light up based on drag direction
- Each swipe adjusts the relevant DNA axis by ±0.15
- Haptic feedback on card swipe confirmation
- After all 8 cards, calls completion handler to advance

---

## Files Created (9 new files)

1. `Models/FinancialDNA.swift` — DNA struct + FinancialArchetype enum
2. `Models/FinancialDNAResult.swift` — SwiftData model for persisting results
3. `Utilities/Color+HexString.swift` — String hex color extension
4. `Views/Onboarding/CinematicSplashView.swift` — Screen 1
5. `Views/Onboarding/FinancialDNAIntroView.swift` — Screen 2
6. `Views/Onboarding/DNAAxisPreviewCard.swift` — Reusable axis card component
7. `Views/Onboarding/SpendingPatternCardsView.swift` — Screen 3
8. `Views/Onboarding/ScenarioCardView.swift` — Swipeable card component
9. `Models/SpendingScenario.swift` — Scenario data model + supporting types

## Files Modified (1 file)

1. `MoneyMindApp.swift` — Add `FinancialDNAResult.self` to the model container
