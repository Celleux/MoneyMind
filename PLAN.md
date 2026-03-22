# Adaptive Notification System + Re-engagement + Gentle View + JITAI Timing

## Features

### Notification Service
- A central notification manager that handles all scheduling, permissions, and notification types
- Request notification permission after the user's first avoided purchase, with a friendly prompt card
- Schedule all recurring notifications via the system notification center (works even when app is closed)

### Scheduled Notifications (7 types)
- **Morning Pledge** — Configurable time (default 8am): "Time for your daily pledge"
- **Evening Reflection** — Configurable time (default 9pm): "How was your day? Reflect on your journey"
- **Weekly Paycheck** — Sunday 10am: "You earned $XX this week by staying mindful. Real money."
- **Streak Maintenance** — 6pm if app not opened: "Your X-day streak is still going strong"
- **Milestone Approaching** — When within $50 of a savings milestone ($100, $500, $1K, etc.)
- **EMA Micro Check-Ins** — 9am, 1pm, 7pm (configurable): Quick actionable check-in reminders
- **Mid-Day Spending Intention** — 12:30pm (configurable): "Any spending planned? Set your intention"

### JITAI Adaptive Timing
- Reads detected high-risk patterns from existing data (day of week + hour + trigger type)
- Schedules a proactive notification 15 minutes before each detected risky time
- Example: If the user reports "Boredom" at 8pm on Fridays → 7:45pm Friday: "Friday evening. Usually tough. Urge surf one tap away."

### Re-engagement Campaign
- Tracks last app open date
- **Day 3 missed**: "Your character misses you. [Name] is waiting."
- **Day 7**: "You're $X from your next milestone. Come claim it."
- **Day 14**: "327 members surfed urges today. Your community is here."
- **Day 21–30**: "Your streak is waiting. Day 1 is the bravest day."
- Re-schedules itself each time the app opens

### Curriculum Reminders
- If the user hasn't completed the next curriculum session within 10 days, sends a nudge
- "Session 4 is waiting: Problem-Solving High-Risk Situations. 15 minutes that could change your week."

### Gentle View Mode for Notifications
- When Gentle View is enabled, notifications use rounded amounts and softer language
- "Great week!" instead of "You saved $487.32 this week"
- No exact dollar figures in notification text

### Notification Settings Screen (full page from Profile)
- Opens from the existing "Notifications" row in Profile
- Toggle each notification type on/off individually
- Set custom times for Morning Pledge and Evening Reflection
- Set custom times for EMA check-ins (morning, afternoon, evening)
- Set custom time for Mid-Day Spending Intention
- Custom quiet hours with start/end time pickers (no notifications during this window)
- Notification style picker: "Supportive" (longer, warmer messages) or "Minimal" (brief, to the point)
- Master on/off toggle at the top

---

## Design

### Notification Permission Prompt
- Appears as a card on the Home tab after the first avoided purchase is logged
- Teal gradient accent with a bell icon
- "Want weekly savings reports and streak reminders?" headline
- Green "Enable Notifications" button
- Dismissible with a subtle "Not now" link

### Notification Settings Screen
- Dark background matching the app theme (#0A0A0F)
- Grouped sections with dark card surfaces (#1A1A25)
- Each notification type shows an icon, title, subtitle, and toggle
- Time pickers use inline wheel style for a native iOS feel
- Quiet Hours section with two time pickers (start and end)
- Style selector as a segmented control: Supportive / Minimal

---

## Screens

### Notification Permission Card (on Home tab)
- Shows once after first avoided purchase if notifications not yet authorized
- Taps "Enable Notifications" → system permission dialog
- After granting, schedules all default notifications automatically

### Notification Settings (pushed from Profile)
- **Master Toggle** section at top
- **Daily Reminders** section: Morning Pledge time, Evening Reflection time, Mid-Day Intention time
- **Check-Ins** section: EMA morning/afternoon/evening times with toggles
- **Weekly & Milestones** section: Weekly Paycheck toggle, Milestone Approaching toggle, Streak Maintenance toggle
- **Smart Notifications** section: JITAI Adaptive toggle, Curriculum Reminders toggle, Re-engagement toggle
- **Quiet Hours** section: Toggle + custom start/end time pickers
- **Style** section: Supportive vs Minimal segmented picker
