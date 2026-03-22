# iOS Widgets for MoneyMind — Home Screen & Lock Screen

## Features

- **Small Widget**: Shows daily budget remaining with a mini progress ring and personality color accent
- **Medium Widget**: Left side shows remaining budget + progress ring; right side lists top 3 spending categories with mini bars; bottom hint text
- **Large Widget**: Hero balance at top, weekly spending bar chart (7 days, today highlighted), top 3 categories with progress bars
- **Lock Screen Circular Widget**: Budget ring showing percentage used with remaining amount
- **Lock Screen Rectangular Widget**: No-spend streak counter with flame emoji
- **Lock Screen Inline Widget**: "Budget: $X remaining" text
- **Data Sharing**: App writes budget/spending data to a shared App Group so widgets can read it
- **Deep Linking**: Tapping any widget opens the relevant screen in the app
- **Personality Theming**: Widgets use the user's Money Personality accent color
- **Privacy Redaction**: Amounts show placeholder when widget is redacted

## Design

- Dark background (#111827) matching the app's card color for all Home Screen widgets
- Personality-colored accent dot and progress ring gradients (purple → cyan by default)
- SF Pro Rounded typography consistent with the main app
- Progress rings use the same gradient stroke as the app (accent → secondary)
- Lock Screen widgets use the system accessory widget styling (automatic)
- Over-budget state turns amounts and rings red (#FF5252)
- Clean, minimal layouts — no clutter, just key numbers at a glance
- Weekly bar chart in the large widget mirrors the dashboard style

## Screens / Components

- **Widget Extension Target**: New "MoneyMindWidgets" extension added to the project
- **App Group**: Shared data container (`group.app.rork.moneymind.shared`) for app↔widget communication
- **Shared Data Writer** (in main app): Writes budget totals, category spending, streak info, and personality color to the shared container whenever data changes
- **Timeline Provider**: Refreshes widget data every 30 minutes; also refreshes on-demand when the app updates data
- **Widget Bundle**: Groups all widget families (small, medium, large, lock screen variants) into one extension
