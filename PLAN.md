# Monthly Money Wrapped — Tap-Through Story Experience


## Features

- **Tap-through story format** — Full-screen immersive slides that advance on tap (left side = back, right side = forward), like Instagram Stories
- **7 story slides** with unique animations per slide:
  1. **Intro** — "Your [Month] Money Story" with pulsing personality icon and animated gradient background
  2. **Total Spent** — Giant animated counter rolling up from $0, with month-over-month comparison percentage
  3. **Top Category** — Animated pie chart that assembles segment by segment, top category highlighted with glow, fun "cups of coffee" comparison
  4. **Spending Mood Map** — Grid of all Vibe Check emojis used during the month, most common mood highlighted with stats
  5. **Savings Progress** — Large animated ring filling to show savings goal progress, confetti burst if goal was met
  6. **Financial Fortune** — Mystical fortune-card style prediction for next month based on spending habits, with glowing personality-colored border
  7. **Share Card** — Compact summary of all key stats with personality badge, "Share Your Wrapped" and "Set Next Month's Goal" buttons
- **Story progress bar** at the top (thin segmented bar showing current position, auto-fills as you view)
- **Auto-pause on long press** (like Instagram Stories)
- **Share image generation** at 1080×1920 (Instagram Story size) with dark background, personality color accents, MoneyMind branding, and "Get MoneyMind" text at bottom
- **Confetti particle animation** when savings goal is reached on slide 5
- **Counting number animations** on slides 2, 3, and 5
- **Haptic feedback** on slide transitions and key moments

## Design

- **Full-screen dark experience** — No navigation bar, immersive feel like Spotify Wrapped
- **Story progress indicators** — 7 thin segmented bars at the top, current segment fills with personality color gradient
- **Each slide** has a unique MeshGradient background using the personality accent color
- **Typography** — Large bold rounded numbers (48–72pt), tracking-spaced category headers, secondary text in muted slate
- **Pie chart** on slide 3 uses category colors from the existing transaction system
- **Fortune card** on slide 6 styled with a glowing border, slight rotation, and mystical vibe
- **Share card** renders with MoneyMind logo top-left, key stats in a clean grid, personality color accents, and branding at bottom
- **Smooth spring transitions** between slides with crossfade

## Screens

- **MoneyWrappedView** — Complete redesign of the existing wrapped view into a full-screen tap-through story with 7 slides, progress bar, gesture handling, and share functionality
- **Replaces** the current swipeable TabView implementation with the story-style experience
- **Keeps** existing integration points in ProfileView (monthly + annual wrapped sheets)
