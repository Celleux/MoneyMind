# 3-Day Full Access Trial + Paywall Redesign

## Features

- **3-day free trial for all users** — Every feature is fully unlocked for 3 days after first app launch, no sign-up required
- **Trial countdown banner** — On days 2-3, a subtle banner appears at the top of the Home screen: "Your free trial ends in X days" with a "See Plans" link
- **No more PRO badges during trial** — Ghost Budget, Budget Analytics, and all other premium-locked features show without the gold "PRO" crown badge while the trial is active
- **Redesigned paywall after trial ends** — When the 3 days expire, the paywall shows a personalized message with the user's savings stats
- **Premium status aware everywhere** — The Profile settings section updates to show trial status ("3-Day Trial Active" with remaining time) instead of just "Free Plan"

## Design

- **Trial banner**: A slim, glass-style card at the top of the Home screen with emerald accent text showing days remaining and a small "See Plans" link — appears only on day 2 and 3
- **Paywall hero**: Crown icon with emerald glow, headline "Your 3-Day Trial Has Ended", personalized subtitle showing how much the user saved during the trial
- **Paywall CTA**: Emerald button reading "Continue My Journey" (replaces "Start 7-Day Free Trial")
- **Paywall pricing**: Monthly ($4.99/mo) and Annual ($39.99/yr, "BEST VALUE") cards remain, with emerald selection borders
- **PRO badges**: Completely hidden when user has full access (trial or premium). Only shown after trial expires for non-premium users
- **Profile premium section**: Shows "3-Day Trial" with remaining days during trial, "Premium Active" when subscribed, or "Free Plan" after trial expires

## Changes by Screen

- **PremiumManager** — Add trial logic: `isInTrial` (checks if within 3 days of install), `hasFullAccess` (premium OR in trial), `trialDaysRemaining`, `trialEndDate`. Reads `installDate` from UserProfile via SwiftData
- **Home screen** — Add a subtle trial expiry banner that only appears on days 2-3 of the trial period
- **PaywallView** — New hero text ("Your 3-Day Trial Has Ended"), personalized savings stat, CTA changed to "Continue My Journey", pricing footer updated
- **GhostBudgetView** — PRO badge hidden when `hasFullAccess` is true (2 locations: header + analytics card)
- **BudgetAnalyticsView** — PRO badge on Ghost Budget card hidden when `hasFullAccess` is true
- **ProfileView** — Premium section shows trial status with days remaining, "Upgrade" button only shows after trial expires
- **ContentView** — Trial banner overlay added for days 2-3
