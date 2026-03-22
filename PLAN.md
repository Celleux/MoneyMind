# Comprehensive Notification System with In-App Notification Center

## Features

- **Budget Alerts**: Automatic notifications when spending hits 50%, 80%, and 100% of any budget category — yellow warning at 80%, red alert at 100%
- **Bill Reminders**: "Netflix ($15.99) is due tomorrow" with configurable lead time (already partially built, will be integrated into the unified system)
- **Savings Celebrations**: Confetti-worthy notifications for milestones like "$50 saved today!" and "10-day no-spend streak!" 🎉
- **Daily Check-In**: Evening reflection prompt at a configurable time — "How was your spending today?"
- **Weekly Digest**: Sunday morning summary — "Last week: spent $X, saved $Y, top category: Z"
- **Smart JITAI Nudges**: Pattern-based alerts like "It's Friday evening — your spending tends to increase. Set a weekend budget?" using existing HighRiskPattern data
- **In-App Notification Center**: Bell icon on the dashboard with unread count badge, scrollable list of all recent notifications, swipe to dismiss, tap to navigate to the relevant screen
- **Quiet Hours**: Respected across all notification types (default 10pm–8am)
- **Frequency Cap**: Maximum 3 push notifications per day to avoid overwhelming users

## Design

- **Bell Icon**: Appears in the dashboard top bar next to the personality icon — subtle unread count badge in the app's accent color with a bounce animation when new notifications arrive
- **Notification Center Sheet**: Dark card-based list matching the existing MoneyMind design system (#111827 cards on #0A0F1E background). Each notification shows an icon, color-coded by type, title, body, and relative timestamp ("2h ago")
- **Color Coding**: Budget alerts use yellow (#FF9100) at 80% and red (#FF5252) at 100%. Savings celebrations use green (#00E676). Bill reminders use teal (#00D2FF). JITAI nudges use the existing teal brain icon style
- **Swipe Actions**: Swipe left to dismiss a notification, with a smooth spring animation
- **Empty State**: Friendly "All caught up!" message with a checkmark icon when no notifications exist
- **Celebration Notifications**: Savings milestones show with confetti-style star icons and the accent gradient

## Screens & Components

- **In-App Notification Center (new sheet)**: Presented from the bell icon on the dashboard — a scrollable list of `InAppNotification` items grouped by today / earlier, with swipe-to-dismiss and tap-to-navigate deep linking
- **Dashboard Top Bar (updated)**: Bell icon with unread badge added next to the existing personality icon
- **NotificationService (enhanced)**: New methods for budget threshold checking, savings celebration triggers, daily check-in scheduling, weekly digest scheduling, and frequency cap enforcement
- **InAppNotification Model (new)**: SwiftData model storing notification type, title, body, timestamp, read status, and deep link destination
- **NotificationSettingsView (enhanced)**: Budget alert threshold toggles and daily check-in time picker integrated into the existing notification settings (some already exist in Profile settings — will wire them into the scheduling engine)
- **Deep Linking**: Tapping a notification navigates to the relevant screen (budget → budget analytics, bill → recurring expenses, savings → wallet, etc.)
