# Phase 4: Scratch-to-Reveal Experience + Full Vault Game Screen

**What this phase adds:**

The core interactive scratch card experience — users physically scratch their finger across a card to reveal which gacha card they pulled, plus the full Vault game screen with collection browsing, pity tracking, and celebration effects.

---

### **Features**

- **Scratch-to-reveal interaction** — drag your finger across a card to "erase" the cover and reveal the gacha card underneath
- **Auto-reveal at ~55% scratched** — once enough is scratched, the full card is revealed with a spring animation
- **Haptic feedback while scratching** — light taps as you scratch, heavy impact on reveal
- **Rarity hint glow** — Epic and Legendary scratch cards glow before you scratch them, building anticipation
- **Confetti celebration** — Epic and Legendary pulls trigger a particle confetti burst
- **"NEW!" badge** on freshly revealed cards
- **Duplicate handling** — pulling a card you already own adds to its duplicate count and awards Essence
- **Full Vault screen** — stats bar (Collected / Pending / Pity counter), scratch area, collection button, recent pulls
- **Card Collection browser** — grid of all 55 cards organized by set, with filter chips, progress bar, collected vs silhouette states
- **Card Detail inspector** — full-screen card view with 3D drag-to-tilt rotation effect
- **Pity Info sheet** — transparent tracker showing how close you are to guaranteed Epic/Legendary pulls, plus stats and "How it works" explanation
- **Recent Pulls section** — shows your last few card pulls with rarity colors

---

### **Design**

- Dark luxury palette throughout (matching existing Splurj theme)
- Scratch overlay uses a dark gradient cover that gets "erased" via Canvas clear blend mode
- Revealed cards use the existing CardArtView with rarity-based glow borders
- Confetti particles in emerald, gold, white, purple, and blue
- Collection grid: collected cards in full color, uncollected as dark silhouettes with a "?" icon
- Card detail: large card with rarity-colored drop shadow, draggable 3D tilt effect
- Pity tracker uses progress rings showing distance to guaranteed pulls
- All glass card styling and emerald/gold accent colors consistent with existing app

---

### **New Screens / Components**

1. **ScratchCardView** — the interactive scratch-to-reveal card (Canvas + DragGesture)
2. **VaultGameView** — replaces current placeholder with full game screen (stats, scratch area, collection link, recent pulls)
3. **CardCollectionView** — sheet showing all cards in a filterable grid by set
4. **CardDetailView** — full-screen card inspection with 3D tilt
5. **PityInfoSheet** — pity counter, pull stats, and explanation
6. **RecentPullsSection** — horizontal scroll of recent card pulls
7. **VaultConfettiView** — dedicated confetti particle system for the Vault (separate from the existing Wallet confetti)
8. **SetProgressView** — per-set completion progress with milestone rewards
9. **FilterChip** — reusable pill-style filter button for the collection view
