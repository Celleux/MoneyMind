# Personality-Themed Empty States for All Screens


## Overview
Replace all existing generic empty states and add new ones across 9 screens. Each empty state features a unique personality-themed illustration built from SF Symbols, a gentle floating animation, and a clear call-to-action button.

---

### **Features**

- Each empty state shows a unique character illustration using SF Symbols, tinted with the user's Money Personality color (Saver = green, Builder = purple, Hustler = orange, Minimalist = cyan, Generous = gold)
- Personality-specific character variations: Saver sees a piggy bank, Builder sees a growth chart, Hustler sees flames, Minimalist sees a meditation figure, Generous sees a sharing/heart figure
- Every illustration gently floats up and down in a subtle looping animation to feel alive
- Each screen has a unique headline, supporting text, and action button that navigates to the right creation flow
- All 9 empty states follow a consistent visual structure but with distinct content per screen

---

### **Design**

- Dark background (#0A0F1E) matching the app's existing theme
- Centered layout with personality-colored accent circles behind the illustration
- Illustration: layered SF Symbols composing a character scene (40–60pt), personality color accented
- Headline: bold white text, one line
- Subtext: muted gray (#94A3B8), up to two lines, centered
- CTA button: full-width purple (#6C5CE7) rounded button with action-specific label
- Floating animation: smooth 2-second up/down cycle, 4pt travel range

---

### **Screens Getting Empty States**

1. **Dashboard** (no transactions) — Character with a rocket/sparkle. "Start Your Journey" → "Add Your First Transaction"
2. **Budget** (no budgets set) — Character with pie chart. "Set Your First Budget" → "Create a Budget" (keeps existing 50/30/20 template)
3. **Analytics** (no data) — Character with magnifying glass on chart. "Nothing to Analyze Yet" → "Add a Transaction"
4. **Wallet / Transactions List** (empty) — Character with empty wallet. "Your Wallet Awaits" → "Log a Win"
5. **Savings Goals** (none created in Challenges Hub) — Character with target/flag. "Ready to Challenge Yourself?" → "Start a Challenge"
6. **Challenges Hub** (none active) — Character with trophy. "No Active Challenges" → "Browse Challenges"
7. **Community** (no posts in feed) — Character with speech bubbles. "Be the First to Share" → "Create a Post"
8. **Money Wrapped** (first month not complete) — Character with calendar/clock. "Your First Wrapped Is Coming" → informational, no destructive action
9. **Ghost Budget** (no data) — Character with ghost/parallel lines. "Not Enough Data Yet" → "Add Transactions"

---

### **Shared Component**

- A reusable empty state component that all 9 screens use, accepting: illustration icon, personality color, headline, subtext, button label, and button action
- This keeps the design perfectly consistent while allowing unique content per screen
