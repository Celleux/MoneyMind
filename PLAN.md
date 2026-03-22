# Create Quest Database with 110+ Quest Definitions

## What Will Be Built

A single new file (`QuestDatabase.swift`) containing the complete static quest library — the data that powers the entire quest engine.

### Features

- **55 standalone quests** across 6 categories:
  - 10 Money Recovery quests (cancel subs, negotiate bills, reverse fees, etc.)
  - 11 Spending Defense quests (no-spend days, cooking challenges, app purges, etc.)
  - 10 Income & Earning quests (sell items, raise conversations, freelancing, etc.)
  - 11 Financial Literacy quests (credit checks, budgeting, savings automation, etc.)
  - 8 Social & Accountability quests (loud budgeting, partner talks, buddy check-ins)
  - 5 Generosity quests (paying it forward, volunteering, teaching)

- **6 seasonal quests** that appear only in specific months (January sub audit, tax season, Black Friday, etc.)

- **50 chain quests** (5 story chains × 10 sequential quests each):
  - The Saver's Journey — from $0 saved to emergency fund
  - The Compound Path — from understanding interest to investing
  - The Budget Battle — from tracking expenses to zero-based budgeting
  - Debt Freedom Road — from listing debts to first debt payoff
  - Impulse Mastery — from identifying triggers to 30-day streak

- Each chain quest has proper `chainID`, `chainIndex`, and `prerequisiteQuestID` linking
- Each quest includes RPG-flavored title, difficulty, XP rewards, scratch card chances, zone assignment, multi-step instructions, and estimated real-world financial impact
- A static helper method to look up quests by ID, category, zone, chain, or cadence
- A `totalQuests` count property for UI display

### Design

- Pure data file — no UI, no views
- All quests follow the progressive difficulty curve within chains (awareness → action → sustained behavior → social → milestone)
- Matches existing `QuestDefinition` struct exactly (uses `nonisolated` pattern)
