# Budget Rings & Analytics Screen

## Features

- **Month navigation** — Swipe or tap arrows to browse budgets by month (e.g. "< March 2026 >")
- **Overall budget ring** — Large animated ring showing total spent vs. total budget, with remaining amount in the center and "X days left" below
- **Category budget grid** — 2-column grid of cards, each with a mini progress ring color-coded by category, showing spent/budget amounts
- **Over-budget warnings** — Categories exceeding their limit turn red with a danger ring; a vibration haptic fires if any category is over budget
- **Donut chart breakdown** — "Where Your Money Goes" animated donut chart with clockwise segment animation, tap a segment to highlight it and show the amount
- **6-month spending trend** — Line chart showing monthly spending totals with gradient stroke, filled circles at data points, and a dashed projection for the current month
- **Empty states** — "Set Your First Budget" card with a suggested 50/30/20 template when no budgets exist; motivational message when budgets exist but no transactions yet
- **Edit budgets** — Tap any category card to open the existing budget detail sheet; long-press to edit the monthly limit inline
- **Add new budget category** — "+" button in the category grid header to create a custom budget category

## Design

- **Dark theme** — Consistent with the existing MoneyMind OLED-optimized dark design system (#0A0F1E background, #111827 cards)
- **Large overview ring** — 120pt diameter with purple-to-cyan gradient stroke, remaining amount in 28pt Bold white centered inside
- **Category cards** — MMCard style with subtle border, mini 48pt progress rings colored per category (green under 50%, gradient 50–100%, red over 100%)
- **Donut chart** — Segments animate clockwise from 12 o'clock with 0.8s staggered timing; legend below with color dots, names, amounts, and percentages
- **Trend line** — Gradient stroke from purple to cyan, filled circle data points, current month shown as a dashed line projection
- **Staggered entrance** — Each section fades in and slides up sequentially on appear, matching the existing dashboard animation pattern
- **Haptics** — Warning vibration when over-budget banner appears; light impact on month change

## Screens

- **Budget & Analytics screen** — Accessed via a "See All" or "Budgets" link from the dashboard's budget rings section, or from a new navigation path
  - Top: Month selector with left/right arrows
  - Hero: Large total budget progress ring with remaining amount and days left
  - Category grid: 2-column LazyVGrid of budget category cards with mini rings
  - Donut chart: Animated spending breakdown with tappable segments and legend
  - Trend section: 6-month line chart with gradient stroke and current-month projection
  - Empty state: Onboarding card when no budgets are configured
