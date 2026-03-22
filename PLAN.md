# MoneyMind Design System Overhaul

## Overview
Replace the existing theme with a comprehensive premium design system — new color palette, typography, spacing constants, and 7 reusable components. Dark mode only, OLED-optimized.

---

### **Color System**
- **Backgrounds:** Deep navy primary (#0A0F1E), dark card (#111827), elevated surface (#1A2236)
- **Accents:** Rich purple (#6C5CE7) as primary, electric cyan (#00D2FF) as secondary, vibrant green (#00E676) for success
- **Status:** Amber warning (#FF9100), coral danger (#FF5252), gold for premium (#FFD700)
- **Text:** White primary, slate secondary (#94A3B8), muted (#64748B)
- **Borders:** Dark slate (#1E293B)
- **Gradients:** Purple-to-cyan accent gradient, gold gradient, mesh background updated to match new palette

### **Typography**
- SF Pro Rounded used throughout for a premium feel
- Full hierarchy: largeTitle (34pt Bold) → caption (12pt Regular)
- Special `amountXL` style at 48pt Bold for hero balance displays

### **Spacing & Sizing**
- Consistent spacing scale: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64 points
- Corner radii: buttons 12pt, cards 16pt, modals 20pt, pills 8pt

### **7 Reusable Components**

1. **MMCard** — Dark card with subtle border and shadow, consistent across all screens
2. **MMButton** — Primary (purple fill) and secondary (outlined) variants with haptic feedback on tap
3. **MMTextField** — Dark input field with floating label animation
4. **MMProgressRing** — Circular progress indicator with purple-to-cyan gradient stroke
5. **MMAmountDisplay** — Large dollar amount with smooth counting animation (0.8s ease-in-out)
6. **MMCategoryPill** — Rounded pill with color dot and label for tags/categories
7. **MMTabBar** — (Handled via existing TabView with new tint) Spring animation on selection

### **Migration**
- Existing `Theme.*` color names will be mapped to the new palette so all 50+ views continue working without changes
- Old names like `Theme.accentGreen` → mapped to the new success green, `Theme.teal` → mapped to secondary cyan, `Theme.cardSurface` → mapped to new card color
- New canonical names also available (e.g. `Theme.accent`, `Theme.secondary`, `Theme.card`)
- Default animation spring updated to response: 0.35, damping: 0.7

### **What Won't Change**
- No view files are modified in this step — this is the foundation layer only
- The existing `PressableButtonStyle` is kept and updated to use the new spring values
