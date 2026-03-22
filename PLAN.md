# Evidence-Based Onboarding Rewrite — Screens 1-3

## What's Changing

Replacing the current onboarding flow (Splash → Loss → FirstWin → Branching → Quiz → Social → Account → Intention) with a new evidence-based 7-screen flow. **This prompt covers screens 1–3 only** — the remaining screens will be updated in the next prompt.

---

### **Screen 1: Welcome (New)**
- **What it does:** Hooks the user with a curiosity-driven question — "What's your Money Personality?" — instead of a feature tour
- **Design:** Dark background with floating particle animation (reusing the existing Canvas particle effect from the quiz). Animated Splurj logo icon scales in with a bouncy spring. Large bold heading and subtitle fade in after. Green full-width "Discover Mine" button slides up from below
- **Copy:** "Are you a Saver, Builder, Hustler, Minimalist, or Generous? Find out in 60 seconds." Below the button: "Takes less than a minute · No signup needed"
- **Animations:** Logo spring (0.8 response, 0.6 damping), text fade 0.3s delay, button slide 0.3s after text, continuous floating particles

### **Screen 2: Money Personality Quiz (Modified)**
- **What changes:** The existing quiz is already great — only minor enhancements:
  - Progress bar already exists and works well — keep as-is
  - Haptic feedback on selection already exists — keep as-is
  - The quiz now passes the computed personality forward to the new Personality Reveal screen (screen 3) instead of showing the built-in result screen
  - The quiz's internal welcome screen is **skipped** since Screen 1 (Welcome) replaces it — quiz starts directly in question mode

### **Screen 3: Personality Reveal (New)**
- **What it does:** The "AHA moment" — shows the user their personality type with rich personalization
- **Design:**
  - Full-screen with personality-colored gradient background (15% opacity)
  - Large personality icon scales in from zero with a spring + confetti burst
  - "You're a [TYPE]" in large bold text with personality color
  - 3 trait cards animate in from the right, staggered 0.15s each:
    - "Your Strength" — first trait from personality
    - "Watch Out For" — a personality-specific vulnerability
    - "Your Splurj Plan" — personalized one-liner (e.g. Hustler: "Splurj will make sure impulse buys don't eat your hustle")
  - Share button with personality-branded share text
  - Green CTA: "See What This Costs You →"
- **Confetti:** Reuses the confetti pattern from FirstWinScreen — colorful dots burst outward when the personality icon appears

### **Updated Flow Controller**
- New screen order: Welcome → Quiz → Reveal → Loss → FirstWin → Social → Intention
- The old Splash screen, Account Creation screen, and Branching screen are **removed from the flow**
  - Branching screen file is kept (not deleted) for potential reuse as a contextual modal post-onboarding
  - Splash and Account Creation files are kept but no longer referenced
- Quiz result (personality type) is now passed through to all subsequent screens for personalization
- The quiz skips its internal welcome/result screens — it completes after the last question and hands off the personality to the Reveal screen

### **Files Created**
- `SplurjWelcomeScreen.swift` — Screen 1
- `SplurjPersonalityRevealScreen.swift` — Screen 3

### **Files Modified**
- `OnboardingView.swift` — New flow enum, new screen routing, personality state passed through
- `MoneyPersonalityQuizView.swift` — Skip internal welcome screen, skip internal result screen, hand off personality after last question

### **No Files Deleted**
- Old screens (Splash, AccountCreation, Branching) remain in the project but are no longer in the onboarding flow
