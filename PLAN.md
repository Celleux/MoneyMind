# Profile/Settings Cleanup + Global Splurj Rebrand

## Part 11: Profile / Settings Cleanup

**Profile Hero Redesign:**
- Remove the large personality icon with concentric circles from the top of the profile
- Replace with a clean glass card showing: Name, Personality Type, and Level on one line
- Below that, three stat pills in a row: Total Saved, Current Streak, Wins Logged — all using accent (emerald) color instead of mixed orange/green/gold
- "Retake Quiz" link stays but moves below the stats
- "Member since" date stays as muted text at the bottom

**Character Section → Sub-page:**
- Replace the prominent "Your Companion" card with a compact navigation row: "My Character → Level X" with a small character preview
- Tapping navigates to a dedicated Character detail page (reusing existing CharacterView content)

**Grouped Expandable Settings:**
- **Appearance** — Theme, Personality Color, Gentle View, Simple Mode, ADHD Mode, High Contrast (same content, just in this group)
- **Notifications** — Bill Reminders, Budget Alerts, Daily Check-In, Weekly Digest, Advanced Settings link (same content)
- **My Journey** — My Character (nav link), Badges (nav link), Weekly Summary, Monthly Recap, Splurj Wrapped, Referral section, Recovery Progress (PGSI — only visible for gambling/impulseShopper paths)
- **Account** — Currency picker, Budget Method, First Day of Month, Export CSV, Monthly Report, Premium status, Restore Purchases, Data Management (Clear Data, Delete Account)
- **About** — Version, Rate on App Store, Share Splurj, Privacy Policy, Terms of Service, Contact Support

**Recovery/PGSI Visibility:**
- PGSI trend chart and monthly check-in prompt only shown for users with `gambling` or `impulseShopper` path
- Hidden entirely for `generalSaver` and `adhd` paths

**Stats Grid Color Fix:**
- Day Streak icon: emerald (was orange)
- Total Saved icon: emerald (unchanged alias)
- Wins Logged icon: emerald (was gold)

**Referral Code Prefix:**
- Change `"MM-"` to `"SP-"` in the referral code generator
- Update fallback display from `"MM-XXXXX"` to `"SP-XXXXX"`

---

## Part 12: Global Rebrand — MoneyMind → Splurj

**User-facing string replacements:**
- `"Money Wrapped"` → `"Splurj Wrapped"` in Profile sharing section
- `"moneymind.app/privacy"` → `"splurj.app/privacy"`
- `"moneymind.app/terms"` → `"splurj.app/terms"`
- `"support@moneymind.app"` → `"support@splurj.app"`
- `"MM-XXXXX"` fallback → `"SP-XXXXX"`

**Code-level references (test files — cosmetic only, no functional impact):**
- Update comments in test files that still say "MoneyMindTests" / "MoneyMindUITests"

**Note:** The app entry point (`SplurjApp`), ExportService filenames, share cards, widget data, and most user-facing strings are already rebranded to "Splurj" from previous work. Only the items listed above remain.
