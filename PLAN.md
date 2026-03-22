# Connect Scratch Card Earning to Impulse Resistance + Home Screen Prompt

**What's already done (from previous phases):**
- Confetti celebration effects ✅
- Pity info sheet with tracker ✅
- The full Vault game, scratch cards, collection, gacha engine ✅

**What this plan adds:**

### Features
- Every time you log a resisted impulse ("Log a Win"), you automatically earn a scratch card with a hidden gacha pull inside
- A maximum of 5 unscratched cards can be held at once — if you already have 5, you'll see a message to go scratch them first
- The Home screen shows a small card prompting you to scratch pending cards when you have them (tapping takes you to The Vault)
- A small toast-style notification appears after earning a scratch card, with a special glowing version for rare pulls

### Design
- The "scratch card earned" toast slides in from the top with the app's emerald accent color
- If the hidden card is Epic or Legendary, the toast shows "You earned a GLOWING scratch card" with a shimmer effect
- The Home screen prompt is a compact card with the sparkles icon, showing "X card(s) to scratch" with a chevron to navigate to The Vault
- Sits between the greeting header and the quick actions grid on the Home screen

### Screens affected
- **Wallet Log Win sheet** — after saving a win, a scratch card is created behind the scenes
- **Home Log Win sheet** — same scratch card creation logic added here
- **Home screen** — new pending scratch cards prompt card added to the dashboard
