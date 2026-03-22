# Build the Quest Engine — Selection, Rotation, Rewards, and Level-Up Logic


## What's Being Built

The Quest Engine is the brain behind the quest system — it selects which quests to show each day/week, handles quest completion with XP and rewards, manages leveling up, and connects to the existing gacha/scratch card system.

---

### Features

- **Daily quest rotation**: Each morning (or on first app open), 3 daily quests are selected based on the player's level and zone, with one marked as "lucky" for bonus rewards
- **Weekly quest rotation**: Every Monday, 2 harder weekly quests appear — these always guarantee a scratch card
- **Smart quest selection**: Quests are chosen based on the player's current zone, avoiding already-completed quests and respecting seasonal availability
- **Sawtooth difficulty**: After completing a hard quest, the engine favors easier quests next — creating a satisfying challenge rhythm
- **Quest completion with rewards**: Completing a quest awards XP (with streak and lucky bonuses), essence, boss damage, and a chance at a scratch card
- **Level-up system**: XP accumulates and triggers level-ups (50 levels across 5 zones), with avatar evolution every 10 levels
- **Streak tracking**: Consecutive days of completing at least one quest are tracked, with bonus multipliers at 7-day and 30-day streaks
- **Boss damage integration**: Every quest deals damage to the current zone's boss (XP ÷ 10 = damage)
- **Gacha integration**: Scratch cards are created through the existing gacha engine when earned from quests
- **Quest step progression**: Multi-step quests can be advanced one step at a time
- **Quest archiving**: The "Write-Off Decision" — users can gracefully archive a quest without penalty
- **Expired quest cleanup**: Daily/weekly quests that weren't completed are automatically marked as expired

---

### How It Works

- A new `QuestEngine` service file handles all quest logic
- A `QuestReward` data type captures everything earned from completing a quest (XP, scratch card, essence, level-up info, boss damage, shareable moment)
- The engine reads from the existing quest database (110+ quests already created) and player profile
- It writes to existing models: `DailyQuestSlot`, `QuestProgress`, `PlayerProfile`, `ScratchCard`, `GachaState`
- The engine is created with a SwiftData model context so it can read and write data directly
