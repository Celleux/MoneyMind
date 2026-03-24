# Phase 1: Complete Color Palette + Theme.swift Overhaul

**Goal:** Replace the "gambling green" (#34D399) palette with warm gold (#E8B94E) for prosperity and muted teal (#4ECDC4) for growth across the entire Splurj app.

---

### Step 1 — Rewrite Theme.swift Color Tokens

Replace all color definitions in `Utilities/Theme.swift`:

- **Backgrounds:** Warm charcoal tones (`#141416`, `#1E1E22`, `#262630`) replacing the cold blue-black (`#0B0E14`, `#12161F`, `#1A1F2E`). Add new `modal` color (`#303040`).
- **Primary accent:** Gold `#E8B94E` replacing emerald `#34D399`, with pressed state (`#C49A3A`) and glow variant
- **Secondary accent:** Teal `#4ECDC4` for health/growth features, with dim variant (`#3BADA5`)
- **Tertiary accent:** Indigo `#6366F1` for AI coach and premium features
- **Text:** Off-white `#E5E5E7` (not pure white), updated secondary `#8E8E93`, muted `#555560`
- **Borders:** Updated to `#2A2A35` with gold-tinted accent border
- **Semantic colors:** Success → teal (not green), Warning → warm amber `#F0A030`, Danger → soft coral `#F08389`
- **Neon colors:** `neonEmerald` → renamed to `neonGold` using `#E8B94E`, `neonPurple` stays as indigo `#6366F1`
- **Gradients:** `accentGradient` → gold gradient, `premiumGradient` → gold, `goldGradient` → gold, `successGradient` → teal
- **MeshGradient:** Update mesh color points to use gold at 3–4% opacity and teal at 2–3% opacity
- **Glass materials:** Update white opacity overlays to use off-white tones
- **Legacy aliases:** `accentGreen` → gold, `teal` → secondary teal, `tabBarBg` → new background

### Step 2 — Fix All Hardcoded Hex Colors Across ~30 Files

Replace every hardcoded `Color(hex: 0x34D399)` and `Color(hex: 0x0B0E14)` etc. with Theme tokens:

- **Onboarding views** (7 files): `ScenarioCardView`, `SpendingPatternCardsView`, `UrgeSurfSheet`, `EmotionalTriggersView`, `FinancialDNACardView`, `FinancialDNAIntroView`, `FinancialDNARevealView`, `LaunchScreenView`, `MoneyMemoryView`
- **Game views** (8 files): `Quest3DRewardSequence`, `QuestRewardCelebration`, `BossBattleView`, `BossDefeatCelebration`, `Card3DRevealSequence`, `ChallengeInviteView`, `VaultGameView`, `GamesHubView`
- **Component views** (10 files): `ScratchCardView`, `ShareableAchievementCard`, `LevelUpCeremony`, `MicroQuestView`, `Parallax3DCard`, `QuestCard`, `BossBattleCard`, `CardLootOpeningView`, `ReferralMilestoneCelebration`, `GameCard`
- **Main views** (8+ files): `ProfileView`, `PaywallView`, `WalletView`, `QuestChainDetailView`, `QuestMapView`, `CommunityView`, `OperationGetPaidView`, `PGSIAssessmentView`, `MoneyWrappedView`
- **Models** (2 files): `QuestZone.swift`, `SpendingScenario.swift`
- **Services/Utils** (2 files): `ShareCardRenderer`, `ReferralRewardManager`

### Step 3 — Update All Gradient Definitions

- Savings-related gradients → gold progression
- Health/breathing gradients → teal progression
- Premium/AI gradients → indigo progression
- Achievement gradients → gold → amber progression
- All `neonEmerald` references in gradients → `neonGold`

### Step 4 — Update MeshGradient Colors in 6 Files

- `GamesHubView` — gold/teal ambient mesh
- `LevelUpCeremony` — gold ceremony mesh
- `MoneyWrappedView` — personality-colored mesh (update green fallback)
- `ShareCharacterCardView` — character card mesh
- `ShareableQuestCard` — quest card mesh
- `ShareableAchievementCard` — achievement card mesh
- `ShareCardRenderer` — export mesh

### Step 5 — Update Neon/Glow Effects

- All `Theme.neonEmerald` → `Theme.neonGold` across celebration views, particle effects, and holographic sheens
- Shadow colors using green → gold at 15% opacity
- `PressableButtonStyle` shadow → gold accent

### Step 6 — Verify Every Screen

After all changes, ensure correct color mapping:
- **Home:** Gold on savings, teal on health metrics
- **Games Hub:** Gold on achievements/rewards, teal on breathing exercises
- **Quest Hub:** Gold on quest rewards, indigo on AI recommendations
- **Wallet:** Gold on transaction highlights
- **Profile:** Gold on level/streak badges
- **Paywall:** Gold gradient on premium CTA
- **Onboarding:** Warm palette throughout
- **Tab bar tint:** Gold
