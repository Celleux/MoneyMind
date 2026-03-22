# Ghost Budget Mode — "What If?" Parallel Financial Timeline


## Features

- **Habit Toggle System** — See a list of your spending categories with their monthly averages; toggle any category on to "eliminate" it and instantly see the impact
- **Split Comparison Chart** — Animated dual-line visualization showing your real balance trajectory vs. your "ghost" balance without the eliminated spending
- **Dramatic Savings Callout** — Large animated number showing how much more you'd have, with fun rotating equivalents ("That's X iPhones", "X months of rent", "X round-trip flights")
- **Timeline Projections** — Switch between 1 month, 3 months, 6 months, and 1 year views to see long-term impact
- **Shareable Ghost Card** — Generate a beautiful 1080×1920 share image with "If I stopped [habit], I'd have $X,XXX in [timeframe]" and MoneyMind branding
- **Premium Gate** — Free users see a preview with blurred projections and a prompt to upgrade; full access for premium users

## Design

- **Dark OLED theme** consistent with the rest of MoneyMind — deep navy background (#0A0F1E), dark cards (#111827)
- **Ghost emoji (👻) + "What if?" tagline** at the top in muted text, with a premium badge if locked
- **Toggle switches** in rows with category icon, name, and average monthly spend — toggled items glow with the accent purple
- **Dual-line chart** uses red-to-white gradient for "Reality" and a vivid green gradient for "Ghost" — lines animate drawing left-to-right over 1.5 seconds
- **Big green savings number** in 34pt bold with a counting animation, surrounded by a subtle green glow
- **Fun equivalents** fade in and out in a cycling carousel below the savings number
- **Timeline tabs** (1M / 3M / 6M / 1Y) as segmented pill selectors with spring animation on switch
- **Staggered fade-in** on all sections matching the app's existing animation pattern
- **Haptic feedback** on toggle changes and timeline tab switches

## Screens

- **Ghost Budget View** — A full scrollable screen accessible from the Budget Analytics screen (new tab/section) and from a card on the Home dashboard
  - Top: Header with ghost emoji, title, and premium badge
  - Habit toggles section: scrollable list of expense categories with toggle switches
  - Comparison chart: side-by-side or overlaid line chart with "Reality" vs "Ghost" labels
  - Savings callout: large animated number with rotating fun equivalents
  - Timeline selector: 1M / 3M / 6M / 1Y pill tabs
  - Share button at the bottom that generates a branded share card
- **Ghost Budget Share Card** — A rendered 1080×1920 image with the dramatic stat, personality color accents, and MoneyMind watermark (uses the existing share card renderer)
- **Dashboard Integration** — A new "Ghost Budget" card on the Home screen showing a teaser ("What if you stopped X?") that navigates into the full Ghost Budget view
