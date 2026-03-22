# Path-Based Onboarding — 7-Screen "Choose Your Journey" Flow

## Overview

Replace the current 7-screen onboarding (Welcome → Quiz → Reveal → Loss → FirstWin → SocialProof → Intention) with a new 7-screen flow that adds path selection and currency choice, while removing the loss visualization and social proof screens.

---

## New Onboarding Flow

**Screen 1 → Screen 2 → Screen 3 → Screen 4 → Screen 5 → Screen 6 → Screen 7**
Welcome → Choose Your Path → Personality Quiz → Personality Reveal → Currency Selection → First Win → Setup Complete

---

## Features

### Screen 1: Splurj Welcome (updated)
- Redesigned with the word "Splurj" as a glowing emerald logo text instead of an SF Symbol icon
- Tagline: "Don't splurge. Splurj." in muted text
- Animated emerald particles floating upward in the background
- "Get Started" button with emerald gradient and depth shadow
- Below button: "Takes 2 minutes · 100% free for 3 days"
- Staggered fade-in animations for logo, tagline, and button

### Screen 2: Choose Your Path (new)
- Header: "What brings you to Splurj?"
- Subtitle: "Pick the one that resonates most. You'll get access to everything."
- 4 glass-style path cards stacked vertically:
  - 💸 "I spend too much" — Impulse buying, emotional spending
  - 🎰 "Gambling is affecting my finances" — Sports betting, online gambling
  - 🧠 "ADHD makes money hard" — Forgetting bills, impulsive purchases
  - 🌱 "I just want to save more" — Smarter habits, better tools
- Selected card gets an emerald border glow and checkmark
- "Continue" button appears after selecting a path
- Small note: "You can change this anytime in Settings"

### Screen 3: Money Personality Quiz (visual refresh)
- Same 5 questions and logic, but answer cards now use glass styling
- Selected answer gets emerald border with slight scale-up effect
- Progress bar uses a thin emerald fill on a dark track
- Emoji backgrounds use a subtle emerald tint instead of multiple colors

### Screen 4: Personality Reveal (kept as-is)
- Same confetti burst, trait cards, and share functionality
- Personality-specific colors still used here as a special moment

### Screen 5: Currency Selection (new)
- Header: "Choose Your Currency"
- Search bar to filter currencies
- Popular currencies pinned at top: USD, EUR, GBP, THB, JPY, AUD, CAD, INR
- Full scrollable list with flag emoji, currency code, and name
- Selected currency shows emerald checkmark
- "Continue" button at bottom

### Screen 6: First Win (kept as-is)
- Same personality-specific prompts and coin animation
- Uses selected currency symbol instead of hardcoded "$"

### Screen 7: Setup Complete (replaces Intention + Account Creation)
- Confetti burst on appear
- "You're all set!" header with personality emoji in emerald
- Glass card summary showing: path, personality, currency, first save amount
- Name input field
- Notification priming card with path-specific benefit text:
  - Impulse: "We'll remind you to pause before big purchases"
  - ADHD: "Bill reminders so nothing slips through the cracks"
  - Gambling: "Check-in reminders to stay on track"
  - General: "Weekly savings updates and streak reminders"
- "Enable Smart Nudges" button for notification permission
- "Start Using Splurj" emerald CTA button
- Below: "Everything is free for 3 days. Explore everything."

---

## Data Changes

- New "user path" field added to the user profile (impulse shopper, gambling, ADHD, general saver)
- New currency code and currency symbol fields added to the user profile
- New install date field for tracking the 3-day trial period
- Path, currency, and personality flow through all onboarding screens

---

## Screens Removed from Onboarding
- Loss Visualization — removed from onboarding flow (file kept for potential reuse)
- Social Proof — removed from onboarding flow (file kept for potential reuse)
- Intention Screen — replaced by Setup Complete

---

## Files Created
- Choose Your Path screen
- Currency Selection screen
- Setup Complete screen
- UserPath data model

## Files Modified
- Welcome screen — redesigned with text logo and new copy
- Onboarding flow controller — new 7-screen sequence
- Quiz view — glass card styling, emerald-only colors
- First Win screen — uses selected currency symbol
- User profile model — new path, currency, and install date fields
