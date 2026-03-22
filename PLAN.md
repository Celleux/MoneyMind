# Phase 2: Card System — Enums, Database, Art View & Gacha Engine

## What's Being Built

The complete card system data layer for The Vault game — rarity tiers, themed card sets, a database of 50 financial literacy cards, the visual card art component, and the gacha pull engine with pity system.

### New Files

**Models:**
- **CardRarity** — 5 rarity tiers (Common → Legendary) with colors, glow effects, and star labels
- **CardSet** — 5 themed collections (Savers Guild, Compound Interest, Budget Warriors, Debt Slayers, Impulse Defenders) with icons and accent colors
- **CardDefinition** — Data structure for each card (name, financial tip, set, rarity)
- **CardDatabase** — Master database of all 50 cards across 5 sets, with lookup helpers

**Services:**
- **GachaEngine** — Pull mechanics with soft/hard pity system (guaranteed Epic every 20 pulls, guaranteed Legendary every 50 pulls), syncs with the existing GachaState SwiftData model

**Components:**
- **CardArtView** — Beautiful card rendering with rarity-based gradient backgrounds, glow borders, SF Symbol set icons, holographic overlay for Legendaries, and card info text

### Card Distribution (per set)
- 4 Common (★) — gray, no glow
- 3 Uncommon (★★) — emerald glow border
- 2 Rare (★★★) — blue glow border
- 1 Epic (★★★★) — purple glow border with pulse
- 1 Legendary (★★★★★) — gold animated border with holographic shimmer

### Design
- Card art uses the dark luxury palette (deep blues/blacks) with rarity-colored gradients
- Higher rarity = stronger glow, richer colors, more visual effects
- Legendary cards get a holographic angular gradient overlay
- All text uses the existing Splurj typography and color hierarchy
- Cards render entirely in SwiftUI — no external image assets needed
