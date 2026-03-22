# Profile Redesign + Monthly Recap Fix + Gamified Journey

## Overview
Four changes: fix Monthly Recap navigation, fix Profile title, split Profile from Settings into separate screens, and add a gamified "My Journey" section.

---

## Bug Fixes

### Monthly Recap — Tap & Exit Fix
- **Tap anywhere to advance**: Replace the invisible left/right split tap zones with a single full-screen tap that advances to the next slide
- **Swipe right to go back**: Add a swipe-right gesture to go back one slide instead of the left-half tap
- **Exit button always works**: Move the X close button to the highest layer so it's never blocked by the tap overlay, and make it always dismiss regardless of pause state

### Profile Title
- Change the navigation title from "Settings" to "Profile"

---

## Profile vs Settings Split

### Profile Screen (main tab view)
The Profile tab becomes a personal dashboard showing:
1. **Hero Card** — Name, personality type, level, trait pills, retake quiz, member since
2. **Stats Row** — Day streak, total saved, wins logged (3 cards)
3. **My Journey** — Gamified section (see below)
4. **Share & Celebrate** — Weekly Summary, Monthly Recap, Splurj Wrapped
5. **Referral** — Invite code + copy button
6. **Recovery Progress** — Only for gambling/impulse path users (PGSI)
7. **Premium** — Current plan status + upgrade button
8. **Settings link** — A card at the bottom that navigates to the new Settings screen

### New Settings Screen (separate page, reached via Profile)
All configuration/toggles move here:
- **Appearance** — Theme, personality color, gentle view, simple mode, ADHD mode, high contrast
- **Notifications** — Bill reminders, budget alerts, daily check-in, weekly digest, advanced settings
- **Budget Preferences** — Currency, budget method, first day of month
- **Account** — Export CSV, monthly PDF report, restore purchases
- **About** — Version, rate, share, privacy, terms, support
- **Data Management** — Clear all data, delete account (with confirmation dialogs)

---

## Gamified "My Journey" Section

A rich, engaging section on the Profile screen with four parts:

### Character + Level Card
- Large character avatar with a personality-colored glow ring
- Character name (Seedling, Sprout, Guardian, etc.) and level
- XP progress bar with a glowing fill and shadow
- XP counter showing current/next level

### Milestone Timeline
- Horizontal scrollable cards for key achievements
- Milestones: First Save, 7-Day Streak, $100 Club, $500 Saver, $1,000 Legend, 30-Day Warrior
- Completed milestones glow with color; uncompleted ones are dimmed silhouettes
- Each card shows icon, title, subtitle, and a checkmark when completed

### Badge Collection Preview
- Shows first 10 badges in a 5×2 grid
- Earned badges glow with their category color; unearned are faded silhouettes
- Header shows "X/Y" earned count with a chevron to open the full Badge Gallery

### Share Character Card
- A button to share the character card (uses existing share functionality)

---

## Files Changed
- **Monthly Recap screen** — Fix tap gesture, exit button layering, add swipe-back
- **Profile screen** — New title, remove settings sections, add Journey section, add Settings link
- **New Settings screen** — All settings/toggles/account/about sections moved here
- **New Milestone Card component** — Reusable card for the milestone timeline
