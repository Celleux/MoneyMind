# Dashboard Redesign — Premium Finance + Wellness Home Screen


## Overview
Completely redesign the Home tab into a premium "data storytelling" dashboard that combines new personal finance tracking with the existing wellness features. The curated layout keeps the most important wellness sections while adding full finance capabilities.

---

## Features

### New Finance Tracking
- **Add expenses** with category, amount, and optional note
- **Add income** entries to track earnings
- **Budget categories** with spending limits and visual progress rings
- **Recent transactions** list showing both expenses and resisted impulse purchases
- **Weekly spending timeline** — horizontal bar chart showing daily spending (Mon–Sun)

### Redesigned Dashboard Sections (top to bottom)
1. **Top Bar** — "MoneyMind" left-aligned, personality icon avatar on the right (tappable → Profile tab)
2. **Hero Balance** — Large animated total balance (income minus expenses plus saved), trend arrow with percentage, subtle personality-color glow behind the number
3. **Quick Actions Row** — 4 circular buttons in a horizontal scroll: Log a Win, Add Expense, Breathing Pause, Coach Chat — each with press-down animation and haptic
4. **Budget Progress Rings** — 3 category rings in a row (e.g. Food, Shopping, Entertainment) showing spent vs. budget, tappable for detail sheet
5. **Spending Timeline** — "This Week" bar chart with 7 animated bars growing from bottom, current day highlighted in purple
6. **Recent Transactions** — Last 5 entries (expenses + resisted purchases) with category dot, name, amount, time, swipe-to-delete
7. **Streak Card** — Day streak with flame icon, best streak, grace availability (kept from current)
8. **Daily Pledge** — Morning pledge card (kept from current)
9. **Coach Shortcut** — Quick-tap card to open AI Coach (kept from current)
10. **Daily Insight** — Rotating CBT/wellness quote (kept from current)

### Moved to Other Tabs
- Character/XP section → Profile tab
- EMA Check-In card → Tools tab
- HRV/JITAI cards → Tools tab
- Evening Reflection prompt → Tools tab
- Curriculum section → Tools tab
- Community social proof → Community tab
- Notification permission card → Profile settings

### States
- **Loading** — Shimmer skeleton animation across all sections
- **Empty** — Friendly illustration with "Add your first transaction" call-to-action
- **Populated** — Full dashboard with staggered fade-in animations (each section 0.1s after the previous)

---

## Design

- **Dark-only OLED theme** — True black background (#0A0F1E), dark cards (#111827)
- **Hero balance** — 48pt bold white number with smooth counting animation (0→actual in 0.8s), personality color at 5% opacity as a large soft circle behind it
- **Trend indicator** — Green up-arrow or red down-arrow with percentage, 15pt
- **Quick action circles** — 56pt dark circles with purple SF Symbol icons, 12pt labels below, scale-down press animation with light haptic
- **Budget rings** — Gradient stroke from purple (#6C5CE7) to cyan (#00D2FF), category icon centered, spent/total label below
- **Bar chart** — 7 thin rounded bars, current day highlighted purple, others use muted border color, bars animate growing from bottom with stagger
- **Transaction rows** — Category color dot, merchant name in white, amount in semibold, time in muted gray, swipe-left for edit/delete
- **Staggered appear animation** — Each section fades in and slides up 0.1s after the previous
- **Pull-to-refresh** — Custom rotation animation on the MoneyMind icon

---

## New Data Models

- **Transaction** — Amount, category, note, date, type (expense/income), optional mood emoji
- **BudgetCategory** — Name, icon, color, monthly limit, current spent amount

---

## New Files
- Transaction data model
- BudgetCategory data model
- Add Expense sheet (amount, category picker, note)
- Add Income sheet (amount, source, note)
- Budget Detail sheet (tapped from a progress ring — shows category breakdown)
- Spending Timeline chart component (weekly bar chart)
- Skeleton Loading view component
- Redesigned Home view (replaces current HomeView)
