# Splurj Onboarding V2 — Premium Interactive Personality Engine

## Overview

A complete replacement of the old onboarding flow with a 10-screen premium Financial DNA assessment. The old 1-dimensional personality quiz (5 questions → 1 of 5 labels) is replaced by a 4-axis system creating 256 unique combinations.

---

## Phase 1: Financial DNA Model ✅

- [x] `FinancialDNA` — 4-axis personality system (Spending, Emotion, Risk, Social) on 0.0–1.0 spectrums
- [x] `FinancialArchetype` — 5 archetypes (Guardian, Strategist, Adventurer, Empath, Visionary)
- [x] `FinancialDNAResult` — SwiftData model persisting all axis scores, answers, and trigger ratings
- [x] Backward compatibility mapping on `MoneyPersonality.toArchetype`
- [x] Registered in app's model container

## Phase 2: Cinematic Splash (Screen 1) ✅

- [x] 3-second cinematic intro with timed animation phases
- [x] Logo fade-in, scale-up with spring physics, tagline, gradient shift
- [x] Auto-advances to next screen

## Phase 3: Financial DNA Intro (Screen 2) ✅

- [x] 4 animated DNA axis preview cards with shimmer effect
- [x] Reusable `DNAAxisPreviewCard` component (used again in reveal screen)
- [x] "Start My Scan" emerald gradient button with pulse

## Phase 4: Spending Pattern Cards (Screen 3) ✅

- [x] 8 Tinder-style swipeable scenario cards
- [x] Drag rotation, stamp overlays, snap-back physics
- [x] Each swipe adjusts DNA axis by ±0.15 with haptic feedback

## Phase 5: Emotional Triggers Wheel (Screen 4) ✅

- [x] 6 emotional triggers arranged in a ring around central hub (Stress, Boredom, Celebration, Social Pressure, Sadness, FOMO)
- [x] Tap a trigger → expands with description and slider to rate intensity (0-100%)
- [x] Trigger glow/size reflects current value
- [x] "Next" button appears after rating all 6
- [x] Ratings feed DNA axes (Stress+Sadness → emotional, FOMO+Social → spending)

## Phase 6: Money Memory Explorer (Screen 5) ✅

- [x] 4 rapid-fire prompts about childhood money beliefs
- [x] Large rounded pill options, selection fills with color and auto-advances after 0.5s
- [x] Progress dots, subtle background gradient shifts between prompts
- [x] Each answer nudges DNA axes based on psychological scoring

## Phase 7: Risk Tolerance Meter (Screen 6) ✅

- [x] Interactive coin-stacking challenge ($100 → $10,000)
- [x] Rising risk bar (thermometer), shake animation as risk increases
- [x] "Lock In My Gains" button with pulse animation
- [x] Coin explosion with particles + heavy haptics if they wait too long
- [x] Lock-in level maps directly to riskAxis score
- [x] Result message: locked-in gets "Smart move", explosion gets "You like to push the limits"

## Phase 8: Financial DNA Reveal (Screen 7) ✅

- [x] Cinematic 4-act reveal sequence (build-up → axes fill → archetype drop → scrollable deep cut)
- [x] `DNARadarShape` — Canvas-based radar chart with animated fill
- [x] Superpower + Blind Spot + Blend sections with empathetic copy
- [x] 4 axis detail cards (reuses `DNAAxisPreviewCard` with filled values)
- [x] `FinancialDNACardView` — Shareable card with radar chart, archetype, tagline
- [x] Share button via `ShareLink`
- [x] "How This Personalizes Splurj" teaser section

## Phase 9: Personalized Plan Preview (Screen 8) ✅

- [x] 3 archetype-specific insight cards showing how app adapts
- [x] Cards stagger in with spring animation
- [x] Dynamic content based on DNA archetype

## Phase 10: First Quest Assignment (Screen 9) ✅

- [x] DNA-based first quest assignment (Guardian→Mirror, Strategist→Archaeology, etc.)
- [x] Quest card with XP preview, difficulty badge, estimated time
- [x] "Accept Quest" button with confetti burst on acceptance
- [x] Bridges onboarding → game loop immediately

## Phase 11: Launch Screen (Screen 10) ✅

- [x] Name input with elegant underlined field
- [x] DNA Card mini-preview (archetype icon + name + axis dots)
- [x] Notification permission toggle for quest reminders
- [x] "Enter Splurj" CTA with glow, skip option
- [x] Creates UserProfile and saves FinancialDNAResult to SwiftData

## Phase 12: Wire New Onboarding Flow ✅

- [x] New `OnboardingScreenV2` enum with 10 screens
- [x] Replaced `OnboardingView.swift` with new flow
- [x] SOS button (floating, top-right) available on every screen except splash
- [x] Skip button (top-left, muted) from screen 3 onward → jumps to launch with default DNA
- [x] Deleted old onboarding files: SplurjWelcomeScreen, ChooseYourPathScreen, MoneyPersonalityQuizView, SplurjPersonalityRevealScreen, BranchingScreen, LossVisualizationScreen, SocialProofScreen, IntentionScreen, CurrencySelectionScreen, FirstWinScreen, SetupCompleteScreen, QuizWelcomeScreen

## Phase 13: DNA-Driven Personalization ✅

- [x] `MoneyPersonality.toArchetype` mapping for backward compatibility (Saver→Guardian, Builder→Visionary, Hustler→Adventurer, Minimalist→Strategist, Generous→Empath)
- [x] Existing views continue to work with old `QuizResult`/`MoneyPersonality` data
- [x] New users get `FinancialDNAResult` from the new onboarding flow

---

## Files Created

1. `Views/Onboarding/EmotionalTriggersView.swift` — Screen 4: Emotion wheel + slider ratings
2. `Views/Onboarding/MoneyMemoryView.swift` — Screen 5: Childhood money memory prompts
3. `Views/Onboarding/RiskToleranceView.swift` — Screen 6: Coin-stacking risk game
4. `Views/Onboarding/FinancialDNARevealView.swift` — Screen 7: Cinematic DNA reveal + radar chart
5. `Views/Onboarding/FinancialDNACardView.swift` — Shareable DNA card component
6. `Views/Onboarding/PersonalizedPlanView.swift` — Screen 8: Archetype-specific plan preview
7. `Views/Onboarding/FirstQuestScreen.swift` — Screen 9: DNA-based first quest assignment
8. `Views/Onboarding/LaunchScreenView.swift` — Screen 10: Name + notifications + launch

## Files Modified

1. `Views/OnboardingView.swift` — Complete rewrite with 10-screen V2 flow
2. `Models/MoneyPersonality.swift` — Added `toArchetype` backward compatibility mapping

## Files Deleted (12 old onboarding screens)

SplurjWelcomeScreen, ChooseYourPathScreen, MoneyPersonalityQuizView, SplurjPersonalityRevealScreen, BranchingScreen, LossVisualizationScreen, SocialProofScreen, IntentionScreen, CurrencySelectionScreen, FirstWinScreen, SetupCompleteScreen, QuizWelcomeScreen
