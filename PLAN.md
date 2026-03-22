# Part 1: Premium Visual Overhaul — New "Dark Luxury" Design System

## What Changes

### New Color Palette
- **Backgrounds:** Deeper, richer dark tones with a 3-tier depth system (deepest background → surface → elevated)
- **Single Accent:** Emerald/mint green replaces the current mix of purple, teal, cyan, and green
- **Gold:** Kept only for badges, streaks, and premium indicators — not used on buttons
- **Text:** 4-level hierarchy (white → slate → gray → dark gray) for clear readability
- **Semantic colors:** Warning (amber) and danger (red) used subtly — small dots or text only, never big red cards
- **Glass effects:** New subtle white-opacity layers for card depth and premium feel
- **Personality colors:** Kept as-is for quiz results and personality-specific moments

### New Card Style — "Glass Card"
- A reusable glass-style card with ultra-thin material, a top-to-bottom highlight gradient, a subtle border with light-to-dark gradient, and a soft drop shadow
- Replaces all flat dark cards (applied to views in later parts)

### New Button Style — "Premium Button"
- Adds an emerald glow shadow beneath buttons that disappears on press
- Subtle scale-down (0.97) and brightness shift on press
- Spring animation for natural feel
- Replaces the current basic scale-only button style

### New Gradients
- **Accent gradient:** Emerald to darker green — for primary action buttons only
- **Premium gradient:** Gold to amber — for pro/premium badges only
- Old purple-to-cyan and rainbow gradients removed

### Backward Compatibility
- `Theme.card` and `Theme.cardSurface` will map to the new `elevated` color for more contrast
- `Theme.accentGreen`, `Theme.teal`, `Theme.secondary` will map to the new emerald accent
- `Theme.emergency` will map to `Theme.danger`
- `Theme.tabBarBg` and `Theme.unselectedTab` updated to match new palette
- Existing `PressableButtonStyle` kept (still used in 100+ places) but updated with the new premium behavior
- All existing code continues to compile — no view files are changed in this part

### Files Changed
- **Theme.swift** — Complete color palette replacement, new gradients, updated button style, new GlassCard modifier, updated mesh background to use emerald tones instead of purple/cyan
