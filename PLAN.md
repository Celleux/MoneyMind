# Add Set Completion Bonuses & Card Evolution System

## Features

- **Set completion milestones** — Already exists via `SetProgressView`. Will be enhanced to show milestone rewards visually.
- **Card evolution** — Spend Essence (earned from duplicate pulls) to evolve a collected card to a higher rarity tier visually.
- **Evolution UI on Card Detail** — When viewing a collected card, see an "Evolve" button if the card is eligible and you have enough Essence.
- **Essence display** — Show current Essence balance in the Vault and Card Detail screens.
- **Evolution visual feedback** — Evolved cards show an evolution badge and enhanced glow in the collection grid.

## Design

- **Evolve Card section** appears at the bottom of the Card Detail sheet, showing current rarity → next rarity with the Essence cost.
- **Evolve button** uses the emerald accent when affordable, muted gray when not. Disabled for Legendary or max-evolved cards.
- **Evolution badge** — Small "Evo +1" or "Evo +2" pill on cards in the collection grid, using the next rarity's color.
- **Confetti/haptic** on successful evolution for satisfying feedback.
- **Essence counter** shown in the Vault stats bar (replacing or alongside existing stats).

## Changes

1. **New file: `EvolveCardView.swift`** — The evolution UI component showing current → evolved rarity, Essence cost, and evolve button.
2. **Update `CardDetailView.swift`** — Add the EvolveCardView at the bottom, pass Essence from GachaState, handle evolution logic (spend Essence, increment evolutionLevel, update rarity string).
3. **Update `CardCollectionView.swift`** — Show evolution level badge on evolved cards in the grid.
4. **Update `VaultGameView.swift`** — Add Essence to the stats bar so users always know their balance.
5. **Update `GachaEngine.swift`** — Add a helper to get the next rarity string for evolution.
