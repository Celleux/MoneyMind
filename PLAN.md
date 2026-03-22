# Onboarding Screens 4–7: Personalized Loss Visualization, First Win, Social Proof & Intention Setup

## What's Changing

Complete the evidence-based onboarding rewrite by updating screens 4–7 with personality-driven personalization, adding testimonials, counter animations, notification priming, and removing unused screens.

---

### **Screen 4 — Loss Visualization (personalized)**
- Header changes from generic "Drag to see the real cost" to personality-aware: *"Here's what impulse spending costs a Hustler"* (or whatever type the user got)
- Slider default changes based on personality: Hustler/Generous start at $15/day, Saver/Minimalist at $5/day, Builder at $10/day
- New "Ghost Budget" preview card appears below the cost numbers showing what you could buy with that money in a year (weekend getaway, MacBook, month in Thailand, used car)
- Button text changes from "That's eye-opening" to **"I want to change this"**
- Slider track tinted with the user's personality color

### **Screen 5 — First Win (personality prompts)**
- Title changes from "Your First Win" to **"Log Your First Save"**
- Subtitle changes to "Think of something you resisted buying recently. How much was it?"
- Personality-specific example prompts appear below the subtitle (e.g. Hustler sees *"That impulse Amazon order? The 2 AM Uber Eats?"*, Generous sees *"That gift you almost bought? The extra round of drinks?"*)
- Coin animation and celebration kept as-is

### **Screen 6 — Social Proof (testimonials + animated counters)**
- Two testimonial cards added below the stats — one from a "Hustler" user, one from a "Generous" user
- Stat numbers now animate counting up from 0 to their final value over 1.5 seconds
- Button text changes from "Join the Community" to personalized: **"Join 2,847 Hustlers like you"** (matches the user's personality type)

### **Screen 7 — Intention Setup (merged with account creation)**
- Header changes from "One Last Thing" to **"Almost there, 🔥"** (personality emoji)
- Name field and intention picker kept as-is
- New notification permission card added: bell icon, benefit text *"Get a gentle nudge when your spending patterns spike"*, personality-specific stat (*"Hustlers who enable notifications save 34% more"*), and an "Enable Smart Nudges" button
- Main button changes to **"Start My Splurj Journey"**
- "Free forever. Premium unlocks deeper tools." text below the button
- Small "Skip for now" link at the very bottom
- Email field, Create Account button, and Sign in with Apple button removed (this is an offline-first app)

### **Flow Updates**
- Personality type now passed through from the quiz to all remaining screens (4–7) for personalized copy
- `AccountCreationScreen.swift` deleted — merged into Intention screen
- `SplashOnboardingScreen.swift` deleted — replaced by the Welcome screen from previous task
- `BranchingScreen.swift` kept in codebase but removed from onboarding flow (available for later contextual use)
