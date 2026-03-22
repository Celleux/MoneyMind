# Global Rebrand: MoneyMind → Splurj

## What's Changing

A complete text rebrand across the entire app — every place the user sees or shares "MoneyMind" will now say **"Splurj"**.

---

### **User-Facing Text Updates (29 files)**

All screens, share cards, exports, and Siri shortcuts will be updated:

- **Home screen** — "MoneyMind" header and coach label → "Splurj"
- **Coach chat** — "MoneyMind Coach" → "Splurj Coach"
- **Wallet** — "Without/With MoneyMind" comparison → "Without/With Splurj"
- **Community** — community branding and guidelines → "Splurj community"
- **Profile / Settings** — "Share MoneyMind" → "Share Splurj"
- **Paywall** — "Join 10,000+ MoneyMind Premium members" → "Splurj Premium"
- **Money Wrapped** — "MoneyMind" branding → "Splurj" throughout
- **Share cards** (Milestone, Character, Ghost Budget, Weekly Summary) — all footers → "Splurj" / "splurj.app"
- **Badge descriptions** — "MoneyMind Program" → "Splurj Program"
- **Challenges** — share text references → "Splurj"
- **Character** — community stat text → "Splurj community"
- **Referral** — invite links and share text → "Splurj" + splurj.app URLs
- **Curriculum content** — all 10+ educational text references → "Splurj"
- **Curriculum section header** — "Your MoneyMind Program" → "Your Splurj Program"
- **Session details** — share text and program name → "Splurj Program"
- **Badge gallery** — share text → "Splurj"
- **Onboarding screens** — Social proof stats, intention option, quiz share text → "Splurj"
- **Breathing guide** — setup instructions → "Splurj"
- **DNS Wizard** — description text → "Splurj"
- **Referral gate** — disclaimer → "Splurj Coach"
- **Export service** — CSV filename and PDF headers/footers → "Splurj"
- **Siri shortcuts** — intent name, description, and phrases → "Splurj"

---

### **Code-Level Renames**

- `MoneyMindApp` struct → `SplurjApp`
- `MoneyMindWidgetsBundle` struct → `SplurjWidgetsBundle`
- `MoneyMindBudgetWidget` → `SplurjBudgetWidget`
- `MoneyMindWidgetView` → `SplurjWidgetView`
- `MoneyMindEntry` → `SplurjEntry`
- `MoneyMindProvider` → `SplurjProvider`
- `MoneyMindCheckInIntent` → `SplurjCheckInIntent`
- `MoneyMindShortcuts` → `SplurjShortcuts`
- Widget kind string: `"MoneyMindBudget"` → `"SplurjBudget"`
- Widget display name: `"MoneyMind Budget"` → `"Splurj Budget"`
- Widget deep link URLs: `moneymind://` → `splurj://` (5 links)

---

### **What Stays the Same**

- `MoneyPersonality.swift` — "Money Personality" is a feature name, not the app
- `MoneyPersonalityQuizView.swift` — same reason
- `MoneyWrappedView.swift` — file name stays, only internal strings change
- All visual design (colors, fonts, animations, layout) — untouched
- All app logic and data models — untouched
