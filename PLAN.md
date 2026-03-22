# Home Screen Cleanup — Focused Dashboard with Glass Cards

## What's Changing

The Home screen is being simplified from a cluttered feature menu into a clean, focused dashboard with only the essentials: stats, quick actions, spending chart, and recent activity.

---

### **Features**

- **Personalized greeting** at the top — "Good evening, [Name]" with personality emoji and level
- **Total Saved This Month** hero card — large emerald number with comparison to last month
- **2×2 Quick Actions grid** — Log Save, Budget Check, Wrapped, Coach — all in emerald (monochrome icons)
- **"Wrapped" hides automatically** if the user has less than 7 days of data
- **Budget progress bars** replace the old ring charts — slim horizontal bars inside glass cards, easier to read
- **Weekly spending chart** stays with accent-colored bars
- **Recent Activity** shows last 3 transactions (down from 5)
- **Daily Pledge** card stays on the home screen

### **What's Removed from Home**

- ❌ "Breathe" quick action → moved to Tools tab
- ❌ Day Streak card → moved to Profile tab
- ❌ Vibe Check card → moved to Tools tab
- ❌ Ghost Budget card → moved to Tools tab
- ❌ Money Challenges card → moved to Tools tab
- ❌ Splurj Coach shortcut card → replaced by Coach quick action button
- ❌ Daily Insight quote → removed from home entirely

### **Design**

- Greeting + personality type in a single compact header row
- Hero "Total Saved" in a glass card with large emerald amount and a small "▲ $XX from last month" comparison line
- Quick actions in a tight 2×2 grid — all icons use the emerald accent color (no multicolor)
- Budget section uses slim horizontal progress bars with emerald fill, inside a glass card
- Spending chart bars all use the emerald accent gradient
- Recent transactions limited to 3 items for a cleaner scroll
- All cards use the existing `.glassCard()` modifier for consistent depth
- Staggered spring entrance animations preserved
- Haptic feedback on all interactive elements

### **Screens Affected**

- **Home screen** — complete restructure of the dashboard layout
- **Skeleton loading view** — updated to match the new simpler layout (no rings, fewer cards)
- **Quick action component** — updated to use 2×2 grid with uniform emerald color
- **Budget section** — rings replaced with horizontal progress bars
