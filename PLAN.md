# Recurring Expense Tracker with Detection, Calendar & Notifications

## Features

- **Automatic Detection**: Scans your transaction history for repeating patterns — same merchant, similar amount, regular intervals (weekly, biweekly, monthly, quarterly, yearly). Flags as "possible recurring" after 2 occurrences and shows a confirmation card
- **Recurring Expenses Screen**: Accessible from the Budget Analytics screen. Shows total monthly recurring cost prominently, with a scrollable list of all recurring items — each showing merchant name, amount, next due date, category color, and frequency
- **Sortable List**: Sort recurring expenses by next due date (default), amount, or category
- **Calendar View**: Month calendar with color-coded category dots on due dates. Tap any date to see all expenses due that day. Current week is highlighted
- **Bill Reminder Notifications**: Configurable reminders — 1 day, 3 days, or 1 week before a bill is due. Plus a monthly summary notification: "You have X recurring expenses totaling $Y this month"
- **Usage-Based Suggestions**: Flags items you haven't logged a transaction for in 30+ days with a "Consider cancelling?" suggestion
- **Quick Actions**: Swipe left on any recurring item to Mark as Paid, Skip This Month, or Remove. Tap to see full payment history for that item
- **Empty State**: Personality-themed empty state when no recurring expenses are detected yet

## Design

- **Dark theme** consistent with the existing MoneyMind design system (#0A0F1E background, #111827 cards)
- **Header area** with a large total monthly recurring amount in personality color, with a subtitle showing what percentage of income this represents
- **Segmented control** at the top to switch between List view and Calendar view
- **Each recurring item card** styled as an MMCard with category color dot, merchant name, amount in bold rounded font, frequency pill badge, and next due date in muted text
- **Calendar** uses a clean grid layout with small colored dots for each due date, matching the category color. Today highlighted with accent ring. Tapping a date slides up a detail panel
- **Confirmation cards** for newly detected recurring expenses appear as a compact banner with Accept/Dismiss actions
- **Swipe actions** use the standard iOS swipe-to-reveal pattern with green (Paid), orange (Skip), and red (Remove) actions
- **Stagger-in animations** on appear, consistent with other screens

## Screens / Sections

- **Recurring Expenses Screen** — Main screen with segmented List/Calendar toggle, total header, detection banners, and the recurring items list or calendar view
- **Recurring Detail Sheet** — Bottom sheet showing full history of a single recurring expense: all past payments, average amount, total spent to date, and edit options
- **Detection Banner** — Inline card that appears when a new recurring pattern is detected, asking the user to confirm
- **Calendar Day Detail** — Expandable section showing all expenses due on a tapped calendar date

## New Files

- **RecurringExpense model** — SwiftData model storing merchant, amount, frequency, category, next due date, reminder preference, active status, and payment history
- **RecurringExpenseDetector service** — Scans transactions to find recurring patterns, generates suggestions
- **RecurringExpenseViewModel** — Business logic for the screen, sorting, filtering, calendar data
- **RecurringExpensesView** — Main screen with list and calendar views
- **RecurringDetailSheet** — Detail sheet for individual recurring expenses
- Model container updated to include the new RecurringExpense model
- Notification scheduling extended for bill reminders
- Navigation link added from Budget Analytics screen
