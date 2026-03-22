# Apply Glassmorphism Cards + Depth Across the Entire App

## What's Changing

The glass card modifier and premium button style already exist — this update applies them across every screen so all flat dark cards become glass-style cards with depth, light refraction borders, and subtle shadows.

**Note:** The `PressableButtonStyle` already has the premium depth effect (shadow, scale, brightness spring) — no button style changes needed.

---

## Cards Being Upgraded (~80+ card instances)

Every card that currently has a flat dark background + thin border will get the glass treatment with gradient highlights, refraction border, and drop shadow.

### Reusable Component
- **MMCard** — updated to use glass style instead of flat background

### Home Screen (4 cards)
- Quick Actions grid card
- Spending Timeline card  
- Budget summary card
- Stats card

### Wallet Screen (6+ cards)
- Savings summary cards
- Period stat cards
- Transaction list cards
- Action buttons

### Tools / Toolkit Screen (7+ cards)
- All tool cards (Urge Surf, HALT Check, Cooling Off, etc.)
- Section containers

### Community Screen (5+ cards)
- Post cards
- Filter pills
- New post card
- Guidelines card

### Profile Screen (5+ cards)
- Stats hero card
- Settings section cards
- Character card
- Recovery section

### Budget & Analytics (15+ cards)
- Budget category cards
- Analytics chart containers
- Template selection cards
- Budget detail cards

### Challenges (6+ cards)
- Challenge hub cards
- No-Spend challenge cards
- Round-up race cards
- Envelope challenge cards
- Week savings cards

### Ghost Budget (5 cards)
- Scenario cards
- Comparison cards
- Share card

### Vibe Check Analytics (6 cards)
- Mood distribution card
- Trend cards
- Transaction grid cards

### Other Screens
- Recurring expenses cards
- Recurring detail cards
- Notification settings cards
- Curriculum section/session cards
- DNS Blocking wizard cards
- Breathing guide cards
- Referral cards
- Badge gallery cards
- Coach chat input area
- Money Wrapped cards
- Spending trend chart container
- Donut chart container
- Dashboard skeleton cards
- Onboarding cards (quiz, social proof, loss visualization, personality reveal, first win, intention)

### What Won't Change
- Small UI elements (capsule pills, circle badges, toggle backgrounds, text field backgrounds) keep their current flat style — glass is for **card containers** only
- The `PressableButtonStyle` already has the premium shadow + spring effect — no changes needed
- Sheet/modal backgrounds stay as-is (system-provided)

---

## Design Result
- Every card gets a frosted glass look with a subtle top-edge light gradient
- Thin gradient border (bright top-left → dim bottom-right) replaces flat borders  
- Drop shadow adds perceived depth
- The overall feel shifts from "flat dark developer project" to "premium fintech glass UI"
