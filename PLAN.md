# Fast Transaction Entry with FAB, Custom Numpad & Vibe Check


## Features

- **Floating Action Button (FAB)** on the Home tab — a glowing purple circle in the bottom-right corner that bounces on tap with haptic feedback
- **Quick Transaction Sheet** slides up from the bottom with a spring animation when tapping the FAB
- **Large Amount Display** — big centered dollar amount that updates as you type, with a blinking cursor effect
- **Custom Dark Numpad** — 4×3 grid of dark keys (0–9, decimal, backspace) with press animations and haptic on every key tap
- **Horizontal Category Scroller** — swipeable row of emoji + label pills (Food, Transport, Shopping, Bills, Entertainment, Health, Education, Other); selected pill glows purple with a subtle scale-up
- **Recent Categories** — your last 3 used categories appear as a pinned "Recent" row above all categories for faster selection
- **Smart Category Suggestion** — when you type a common amount (e.g. $4–5 range), a suggestion like "Coffee?" appears that you can tap to auto-select
- **Expense / Income Toggle** — segmented control at the top to switch between expense and income mode; changes the save button color (red vs green)
- **Quick Date Picker** — defaults to "Today" with a one-tap "Yesterday" shortcut and a calendar button for other dates
- **Note Field** — single-line dark input with placeholder text
- **Vibe Check** — row of 5 emoji mood buttons (🤑 Worth it, 😐 Meh, 😬 Regret, ✅ Necessary, 💪 Flex); tapped emoji bounces up with haptic
- **Save Button** — full-width purple button; on save plays a success haptic and the sheet dismisses with a satisfying animation
- **Dismiss Protection** — swiping down on the sheet asks for confirmation if any data has been entered

## Design

- Dark theme matching the existing MoneyMind design system (#0A0F1E background, #111827 cards, #6C5CE7 purple accent)
- FAB: 56pt purple circle with a soft purple glow shadow, white "+" icon, positioned above the existing SOS button area
- Sheet has a subtle drag handle at the top, dark card-style numpad keys with rounded corners
- Category pills use the existing MMCategoryPill style with emoji icons and color coding
- Vibe Check emojis are large and spaced evenly; selected one scales up with a spring bounce
- All animations use the app's standard spring (response: 0.35, damping: 0.7)
- Custom numpad replaces the system keyboard for a faster, more immersive feel

## Screens / Sections

- **Home Tab** — gains a new FAB (floating purple "+" button) in the bottom-right area, replacing the current separate "Expense" quick action approach
- **Transaction Entry Sheet** — a single bottom sheet that handles both expenses and income via a toggle, containing: amount display → numpad → category row → date shortcuts → note → vibe check → save button
- The existing Add Expense and Add Income sheets remain available from other entry points but this new FAB sheet becomes the primary fast-entry path
