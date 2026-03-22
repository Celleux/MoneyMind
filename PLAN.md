# Quest System Phase 1A — Quest Data Models

**What this does**

Adds the foundational data models for the Quest System — the enums, structs, and database models that everything else will be built on.

**New files created:**

- **QuestCategory, QuestArchetype, QuestDifficulty, VerificationType, QuestCadence enums** — Define quest types, difficulty tiers, how quests are verified, and how often they refresh. Each has colors, icons, and multipliers matching the app's dark luxury palette.

- **QuestZone enum** — The 5 zones spanning 50 levels (The Awakening → The Legacy), each with a level range, boss name, boss HP, theme colors, and description.

- **QuestDefinition struct** — The static quest blueprint containing title, subtitle, description, category, difficulty, XP rewards, scratch card chance, steps, zone, chain info, and seasonal availability.

- **QuestStep struct** — Individual steps within multi-step quests, each with instructions and partial XP rewards.

- **QuestProgress model** — Tracks per-user progress on each quest (status, current step, completion date, XP earned). Stored in the device database.

- **QuestStatus enum** — Quest lifecycle states: locked → available → active → completed → claimed (plus expired and archived for graceful exits).

- **PlayerProfile model** — The RPG character: level, total XP, current zone, quest streak, bosses defeated, badges, active title, avatar stage. Includes the 1.4x exponential XP curve for 50 levels.

- **DailyQuestSlot model** — Tracks which 3 daily and 2 weekly quests are offered each day, including which one is the "lucky quest" with enhanced rewards.

**Design details:**

- All enums follow the existing pattern: `nonisolated`, `Codable`, `Sendable`
- Colors use `Color(hex: 0x...)` UInt format matching Theme.swift
- Color-returning properties use `@MainActor` annotation (matching CardRarity/CardSet pattern)
- Database models use `@Model class` with default values (matching ScratchCard/CollectedCard pattern)
- New SwiftData models are registered in the app's model container

**No UI changes in this phase** — this is purely the data foundation.