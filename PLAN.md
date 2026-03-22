# Savings Challenges Hub — Gamified Money Challenges


## Features

- **Challenges Hub screen** accessible from the Home tab or Tools tab, showing all available and active challenges
- **Active challenge card** displayed prominently at the top with animated progress ring and key stats
- **"Start New Challenge" button** when no challenge is active, opening the challenge picker

### 100 Envelope Challenge
- A 10×10 grid of numbered envelopes (1–100), totaling $5,050
- Tap an envelope to mark it as saved — it flips with a satisfying animation and turns your personality color
- A random un-saved envelope is highlighted daily as a suggestion
- Progress ring showing total saved out of $5,050

### 52-Week Savings Challenge
- Calendar-style weekly grid, each week increasing by $1 ($1, $2, $3… up to $52 = $1,378 total)
- Tap to check off each week with a satisfying checkmark animation
- Visual progress bar and total saved counter

### No-Spend Challenge
- Calendar view with tappable day cells
- Mark each day as no-spend (green) or spent (red)
- Streak counter: "12 days without non-essential spending"
- Streak milestones at 3, 7, 14, and 30 days with achievement badges

### Round-Up Race
- Every transaction automatically rounds up to the nearest dollar
- Animated piggy bank filling up as round-ups accumulate
- Running counter: "You've saved $X from round-ups"

### Social & Sharing
- Invite friends via share link to join the same challenge
- Shared leaderboard showing who's saved the most / longest streak
- Shareable achievement milestone cards when hitting key milestones
- Full-screen celebratory animation on challenge completion (confetti burst)

---

## Design

- **Dark theme** consistent with the existing MoneyMind design system — deep navy backgrounds, purple/cyan accents
- **Active challenge card**: large card with gradient accent border, animated progress ring, and key stats (days remaining, amount saved, streak)
- **Envelope grid**: 10×10 grid of small rounded squares, numbered 1–100 — unmarked envelopes are dark/muted, saved ones flip and glow in the personality color with a subtle shimmer
- **Weekly grid**: compact row layout with week numbers and dollar amounts, checked weeks get a green checkmark with spring animation
- **No-Spend calendar**: month calendar with colored day circles — green for no-spend, red for spent, gray for future
- **Round-Up piggy bank**: playful animated piggy bank icon that fills up, with a coin-drop animation when new round-ups are added
- **Challenge cards** in the picker: each card shows title, description, progress ring, duration, and difficulty (flame emojis), with a purple "Start Challenge" button
- **Haptic feedback** on all taps — light impact for envelope/day marking, medium for starting a challenge, celebration haptic on milestones
- **Spring animations** throughout for natural, satisfying motion

---

## Screens

1. **Challenges Hub** — scrollable list with active challenge at top (if any), then available challenges below as tappable cards
2. **100 Envelope Challenge** — full screen with the 10×10 interactive grid, progress stats, and daily suggestion highlight
3. **52-Week Savings** — full screen with scrollable weekly grid, progress bar, and total saved
4. **No-Spend Challenge** — full screen calendar view with streak counter and milestone badges
5. **Round-Up Race** — full screen with animated piggy bank, counter, and transaction round-up history
6. **Challenge Detail Sheet** — bottom sheet for each challenge showing description, stats, leaderboard, invite/share options, and start button
