# Add Games Tab + Games Hub Screen

## What's changing

Adding a new **Games** tab to the main navigation bar, positioned between Wallet and Tools (center of the tab bar). This tab leads to a **Games Hub** screen that showcases "The Vault" game and teases upcoming games.

---

### **Features**

- New "Games" tab with a game controller icon in the main tab bar
- Games Hub screen showing available games as cards
- "The Vault" card navigates to the Vault game screen (placeholder for now — built in Phase 2+)
- Two "Coming Soon" locked game cards: Savings Roulette and Battle Pass
- Stats bar at top showing pending scratch cards count and collection count
- Reusable GameCard and StatPill components for consistent styling

---

### **Design**

- Tab bar goes from 5 tabs to 6: Home / Wallet / **Games** / Tools / Community / Profile
- Games icon: game controller SF Symbol, emerald tint when active
- Games Hub uses the dark luxury palette with glass-material cards
- Game cards have icon circles, badge counts, gradient stroke borders
- Locked "Coming Soon" cards appear dimmed with a lock icon
- StatPill components use ultra-thin material capsules with colored icons
- All text follows the existing 4-level text hierarchy (primary → muted)

---

### **Screens**

- **Games Hub** — scrollable list with stats bar at top, The Vault game card (tappable), and two locked placeholder game cards
- **Vault Game View** — a minimal placeholder screen for now (will be fully built in Phase 2+)

---

### **Data**

- New SwiftData models: `ScratchCard` and `CollectedCard` (registered in the app's model container) — these are created now so the Games Hub can query them for stats, even though they'll be empty until Phase 2+
- New `GachaState` model to persist pity counters
- New `AppTab` case `.games` added to the tab enum
