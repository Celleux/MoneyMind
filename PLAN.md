# Redesigned Settings & Profile Screen


## Features

- **Personality hero card** at the top showing your personality icon, name, type, trait tags, and a "Retake Quiz" link — styled like the quiz result card
- **Member since date** displayed beneath the personality card
- **Appearance settings** — Dark Only theme badge, personality color preview swatch, and app icon selector with 5 personality-themed icons
- **Notification settings** — Bill reminders toggle, budget alert thresholds (50%/80%/100%), daily check-in toggle, weekly digest toggle — all persisted
- **Budget settings** — Default currency picker, default budget method (50/30/20, Zero-Based, Envelope), first day of month picker
- **Data management** — Export Transactions as CSV, Export Monthly Report as PDF, Import Transactions, Clear All Data with double-confirmation dialog
- **Premium section** — Shows current plan status, Manage Subscription button, Restore Purchases link
- **About section** — App version, Rate on App Store, Share MoneyMind, Privacy Policy, Terms, Contact Support
- **Danger Zone** — Red-bordered card with Delete Account and Clear All Data buttons, each requiring a double-confirmation alert
- **All toggles persist** their state through the user profile model
- **Smooth scrolling** with grouped card sections and subtle dividers

## Design

- Dark OLED background (#0A0F1E) consistent with the app's design system
- **Personality hero card**: large card at the top with the personality icon (e.g. flame for Hustler) in a glowing circle using the personality accent color, personality name in bold white, trait tags as small capsule pills in the personality color
- **Grouped settings sections**: each group is an elevated dark card (#111827) with rounded corners, a section header with an SF Symbol icon and title, and rows separated by subtle dividers
- **Settings rows**: each row has a colored icon badge (SF Symbol in a rounded square), title text, and either a toggle, chevron, or value indicator on the right
- **Danger Zone card**: distinguished by a red (#FF5252) border stroke, with destructive-styled buttons inside
- **Animations**: staggered fade-in on appear for each section; haptic feedback on toggle changes
- **Typography**: section headers in semibold, row titles in regular weight, subtitles in secondary gray (#94A3B8)

## Screens

- **Settings & Profile** (replaces the current Profile tab) — single scrollable screen with sections:
  1. Personality hero card with avatar, name, type, traits, "Retake Quiz" link, member since date
  2. Stats grid (streak, total saved, wins) — kept from current design
  3. Character companion card — kept from current design
  4. Appearance settings group
  5. Notifications settings group (with inline toggles, links to detailed notification settings)
  6. Budget preferences group
  7. Data management group
  8. Premium status group
  9. About group
  10. Danger Zone group
- **Export flow**: tapping Export CSV or Export PDF generates and presents a share sheet
- **Delete confirmations**: first tap shows an alert, confirming shows a second "Are you sure?" alert before executing
- Existing sections (referral, badges, sharing, PGSI, goals) are preserved and reorganized within the flow
