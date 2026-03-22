# Budget Templates Screen with 5 Template Options & Setup Flow

## Features

- **Template Selection Screen** — A scrollable list of 5 beautifully designed budget template cards, each with a unique visual preview
- **Personality Recommendations** — Each template shows a colored pill tag like "Recommended for Savers" based on the user's money personality
- **50/30/20 Rule Template** — Enter income, auto-splits into Needs (50%), Wants (30%), Savings (20%) with a 3-ring visual display
- **Zero-Based Template** — Assign every dollar to a category; a live "Unassigned" counter counts down to $0
- **Envelope Method Template** — Digital envelopes for each category with visual envelope icons that show fill levels
- **Pay Yourself First Template** — Set a savings percentage first, then budget the remainder; savings ring shown prominently
- **Custom Template** — Blank slate where all categories and amounts are set manually
- **Setup Flow** — Select template → Enter monthly income → Review auto-generated categories → Adjust amounts → Confirm & create budgets
- **Animated Transitions** — Smooth spring animations between setup steps with staggered card entry

## Design

- **Dark theme** matching the existing MoneyMind design system (#0A0F1E background, #111827 cards)
- Each template card has a large header area with a unique visual preview illustration using SF Symbols
- Template name in 22pt Semibold rounded white, description in 13pt muted gray
- Personality recommendation pill in the personality's accent color (green for Saver, purple for Builder, etc.)
- Income input uses a large bold rounded number style with the personality accent color
- Category allocation rows with colored dots, editable amounts, and progress indicators
- The Zero-Based template features a prominent "Unassigned: $X" counter that animates down to $0
- The 50/30/20 template shows three concentric rings for Needs/Wants/Savings
- The Pay Yourself First template has a large savings goal ring above the remaining budget breakdown
- The Envelope template shows mini envelope icons with fill-level indicators
- Confirm button uses the accent gradient (purple → cyan) in capsule style

## Screens

1. **Template Selection Screen** — Full-screen with "Budget Templates" header. 5 vertical cards, each showing template name, brief description, visual preview, and personality recommendation tag. Tapping a card opens the setup flow.
2. **Income Entry Step** — Large centered income input field with the template's visual style shown above. "Next" button at the bottom.
3. **Category Review Step** — Shows auto-generated budget categories with amounts. Each row is editable. For Zero-Based, a live unassigned counter is shown. For 50/30/20, the three rings update in real-time. Adjust amounts with inline text fields.
4. **Confirmation Step** — Summary of all categories and amounts with the template's signature visual. "Create Budget" button saves all categories to SwiftData and dismisses the flow.

The screen is accessible from the Budget Analytics empty state and from the Profile/Settings budget method selector.