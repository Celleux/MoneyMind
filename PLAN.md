# Quest Hub UI — RPG Command Center (Phase 4)


## What's Being Built

The full Quest Hub UI — the RPG command center inside the Games tab. This is where the app transforms into a game, with dark moody backgrounds, glowing elements, animated quest cards, and dramatic boss previews.

---

## Features

- **Hero Header** with evolving avatar icon, level display, animated XP progress bar with shimmer effect, and a streak flame counter
- **Zone Banner** showing the player's current zone name, level range, theme description, and a zone icon — tappable to open a quest map (placeholder for now)
- **Quest Tab Bar** with animated underline switching between Daily, Weekly, Chains, and Boss tabs
- **Daily Quest Cards** — expandable cards showing quest title, category icon, difficulty badge, XP reward, estimated impact, time estimate, quest steps, reward chips, and a glowing "Complete Quest" button. Lucky quests get a golden border and sparkle badge
- **Weekly Quest Cards** — same style as daily, pulled from weekly quest slots
- **Quest Chain Grid** — 2-column grid of the 5 story chains showing progress bars and chain names
- **Boss Battle Preview Card** — shows current zone boss name, HP bar with damage progress, and a "Fight Boss" button when enough damage is dealt
- **All Quests Complete** empty state — motivational card when all daily/weekly quests are done
- **Quest Reward Celebration** — full-screen animated overlay showing XP earned, scratch card drops, essence gains, boss damage, level-up announcements, and streak updates
- **Updated Games Hub** — adds a Quests entry point card alongside The Vault, with a badge showing pending quest count

---

## Design

- Dark RPG aesthetic using the Splurj dark luxury palette (backgrounds #0B0E14, #12161F, #1A1F2E)
- Zone-specific gradient backgrounds that shift color based on the player's current zone
- Emerald (#34D399) for actions and progress, gold (#F5C542) for achievements and lucky quests
- Animated XP bar with a moving shimmer highlight
- Quest cards with glass-like dark surfaces, category-colored icon rings, and spring expand/collapse animations
- Lucky quest cards glow gold with a pulsing sparkle badge
- Boss HP bar that changes color as it drains (red → yellow → green)
- Haptic feedback on card taps, quest completion, and boss interactions
- Matched geometry animated tab indicator
- Quest reward celebration with sequential fade-in animations for each reward element

---

## Screens / Views

- **GamesHubView** (updated) — adds a "Quests" navigation card with pending quest badge count
- **QuestHubView** — main quest screen with hero header, zone banner, tab bar, and quest content
- **QuestHeroHeader** — avatar ring, level, XP bar, streak flame
- **ZoneBanner** — current zone info card with gradient border
- **QuestTabBar** — 4-tab selector with animated underline
- **DailyQuestStack** — list of today's quest cards with section header
- **WeeklyQuestStack** — list of this week's quest cards
- **QuestChainGrid** — 2-column grid of 5 story chain cards with progress
- **BossBattleCard** — boss preview with HP bar and fight button
- **QuestCard** — expandable quest card with steps, rewards, and complete button
- **QuestStepRow** — individual step inside an expanded quest card
- **RewardChip** — small pill showing reward type (XP, card, essence)
- **AllQuestsCompleteCard** — empty state when all quests are done
- **QuestRewardCelebration** — full-screen reward animation overlay
