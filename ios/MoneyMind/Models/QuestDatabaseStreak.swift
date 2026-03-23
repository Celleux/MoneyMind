import Foundation

extension QuestDatabase {

    static let streakQuests: [QuestDefinition] = streakMilestoneQuests + comebackQuests

    // MARK: - Streak Milestone Quests (12)

    static let streakMilestoneQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "streak_3", title: "Spark Ignited", subtitle: "You've completed quests 3 days in a row!",
            description: "Three days of consistency. The spark is lit. Keep going — momentum is building.",
            category: .financialLiteracy, archetype: .escort, difficulty: .easy, cadence: .daily,
            estimatedImpact: "+50 bonus XP", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 50, scratchCardChance: 0.3, essenceReward: 5,
            steps: [QuestStep(id: "streak3_1", instruction: "Celebrate your 3-day streak!", verification: .selfReport, xpReward: 50)],
            zone: .awakening),
        QuestDefinition(
            id: "streak_7", title: "Week Warrior", subtitle: "7-day quest streak achieved!",
            description: "A full week of financial quests. You're officially in the habit-forming zone. Research shows 7 days makes users 3.6x more likely to stay.",
            category: .financialLiteracy, archetype: .escort, difficulty: .easy, cadence: .daily,
            estimatedImpact: "Rare scratch card", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 100, scratchCardChance: 1.0, essenceReward: 10,
            steps: [QuestStep(id: "streak7_1", instruction: "Claim your 7-day streak reward!", verification: .selfReport, xpReward: 100)],
            zone: .awakening),
        QuestDefinition(
            id: "streak_14", title: "Fortnight Financial", subtitle: "14-day streak — two solid weeks!",
            description: "Two weeks of daily financial action. You're building real habits. The neural pathways are forming.",
            category: .financialLiteracy, archetype: .escort, difficulty: .easy, cadence: .daily,
            estimatedImpact: "+100 essence", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 150, scratchCardChance: 0.5, essenceReward: 100,
            steps: [QuestStep(id: "streak14_1", instruction: "Claim your 14-day streak reward!", verification: .selfReport, xpReward: 150)],
            zone: .budgetForge),
        QuestDefinition(
            id: "streak_21", title: "Habit Formed", subtitle: "21 days — the habit is real!",
            description: "21 days to form a habit. Your financial awareness is now automatic. This is who you are now.",
            category: .financialLiteracy, archetype: .escort, difficulty: .medium, cadence: .daily,
            estimatedImpact: "Epic scratch card", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 200, scratchCardChance: 1.0, essenceReward: 20,
            steps: [QuestStep(id: "streak21_1", instruction: "Claim your 21-day streak reward!", verification: .selfReport, xpReward: 200)],
            zone: .budgetForge),
        QuestDefinition(
            id: "streak_30", title: "Monthly Master", subtitle: "30-day streak — a full month of quests!",
            description: "A full month. Every single day. You've proven that financial growth is a daily practice, not a one-time event.",
            category: .financialLiteracy, archetype: .escort, difficulty: .medium, cadence: .daily,
            estimatedImpact: "Title: Disciplined", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 300, scratchCardChance: 1.0, essenceReward: 30,
            steps: [QuestStep(id: "streak30_1", instruction: "Claim your 30-day streak reward and 'Disciplined' title!", verification: .selfReport, xpReward: 300)],
            zone: .savingsCitadel),
        QuestDefinition(
            id: "streak_50", title: "Half Century", subtitle: "50-day streak — relentless!",
            description: "50 days of daily financial action. You're in the top 1% of app users. Your consistency is building real wealth.",
            category: .financialLiteracy, archetype: .escort, difficulty: .medium, cadence: .daily,
            estimatedImpact: "Epic card + 200 essence", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 400, scratchCardChance: 1.0, essenceReward: 200,
            steps: [QuestStep(id: "streak50_1", instruction: "Claim your 50-day streak reward!", verification: .selfReport, xpReward: 400)],
            zone: .savingsCitadel),
        QuestDefinition(
            id: "streak_75", title: "Diamond Hands", subtitle: "75-day streak — unshakeable!",
            description: "Diamond hands don't just apply to stocks. You've held your financial habits through 75 days of life's chaos. That's diamond-level discipline.",
            category: .financialLiteracy, archetype: .escort, difficulty: .hard, cadence: .daily,
            estimatedImpact: "Title: Diamond Hands", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 500, scratchCardChance: 1.0, essenceReward: 50,
            steps: [QuestStep(id: "streak75_1", instruction: "Claim your 75-day streak reward and 'Diamond Hands' title!", verification: .selfReport, xpReward: 500)],
            zone: .incomeFrontier),
        QuestDefinition(
            id: "streak_100", title: "Centurion", subtitle: "100-day streak — legendary!",
            description: "100 days. A century of daily financial growth. You've transformed from someone who thinks about money to someone who masters it.",
            category: .financialLiteracy, archetype: .escort, difficulty: .hard, cadence: .daily,
            estimatedImpact: "Legendary scratch card", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 750, scratchCardChance: 1.0, essenceReward: 100,
            steps: [QuestStep(id: "streak100_1", instruction: "Claim your 100-day streak reward!", verification: .selfReport, xpReward: 750)],
            zone: .incomeFrontier, tiktokMoment: "100-day financial quest streak. Centurion status unlocked."),
        QuestDefinition(
            id: "streak_150", title: "Legend in the Making", subtitle: "150-day streak — the stuff of legends!",
            description: "150 days of unwavering commitment. You're not just building wealth — you're building the person who creates wealth.",
            category: .financialLiteracy, archetype: .escort, difficulty: .hard, cadence: .daily,
            estimatedImpact: "500 essence + title", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 1000, scratchCardChance: 1.0, essenceReward: 500,
            steps: [QuestStep(id: "streak150_1", instruction: "Claim your 150-day streak reward and 'Legend' title!", verification: .selfReport, xpReward: 1000)],
            zone: .legacy),
        QuestDefinition(
            id: "streak_200", title: "Unstoppable", subtitle: "200-day streak — nothing can stop you!",
            description: "200 days. You've completed more financial quests than 99.9% of people will in their entire lives. You are unstoppable.",
            category: .financialLiteracy, archetype: .escort, difficulty: .legendary, cadence: .daily,
            estimatedImpact: "2 Legendary scratch cards", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 1500, scratchCardChance: 1.0, essenceReward: 200,
            steps: [QuestStep(id: "streak200_1", instruction: "Claim your 200-day streak reward!", verification: .selfReport, xpReward: 1500)],
            zone: .legacy),
        QuestDefinition(
            id: "streak_250", title: "Quarter Millennium", subtitle: "250-day streak — quarter of a thousand!",
            description: "250 days of daily dedication. Your financial habits are as natural as breathing. The compound effect of this consistency is staggering.",
            category: .financialLiteracy, archetype: .escort, difficulty: .legendary, cadence: .daily,
            estimatedImpact: "1000 essence", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 2000, scratchCardChance: 1.0, essenceReward: 1000,
            steps: [QuestStep(id: "streak250_1", instruction: "Claim your 250-day streak reward!", verification: .selfReport, xpReward: 2000)],
            zone: .legacy),
        QuestDefinition(
            id: "streak_365", title: "Year of Financial Freedom", subtitle: "365-day streak — a full year!",
            description: "One year. 365 days. You did it. Every single day for an entire year, you took action on your finances. This is the ultimate achievement.",
            category: .financialLiteracy, archetype: .bossBattle, difficulty: .legendary, cadence: .daily,
            estimatedImpact: "Ultra-rare Phoenix card", estimatedTime: "Instant", verification: .selfReport,
            baseXP: 5000, scratchCardChance: 1.0, essenceReward: 2000,
            steps: [QuestStep(id: "streak365_1", instruction: "Claim the ultimate reward: the Phoenix card!", verification: .selfReport, xpReward: 5000)],
            zone: .legacy, tiktokMoment: "365-day financial quest streak. One year. Every single day. The Phoenix rises."),
    ]

    // MARK: - Comeback Quests (3)

    private static let comebackQuests: [QuestDefinition] = [
        QuestDefinition(
            id: "comeback_easy", title: "The Comeback", subtitle: "Welcome back — let's restart your streak",
            description: "You missed a day. That's okay. Everyone does. The only thing that matters is coming back. Complete one easy quest to restart your streak.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .easy, cadence: .daily,
            estimatedImpact: "Streak restart", estimatedTime: "2 minutes", verification: .selfReport,
            baseXP: 30, scratchCardChance: 0.3, essenceReward: 3,
            steps: [QuestStep(id: "comeback_easy_1", instruction: "Check your bank balance right now — that's it, you're back!", verification: .selfReport, xpReward: 30)],
            zone: .awakening),
        QuestDefinition(
            id: "comeback_medium", title: "Rising Phoenix", subtitle: "Streaks break. Legends restart.",
            description: "The difference between successful people and everyone else isn't perfection — it's the speed of recovery. You're here. That's what matters.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .easy, cadence: .daily,
            estimatedImpact: "Streak restart", estimatedTime: "3 minutes", verification: .selfReport,
            baseXP: 40, scratchCardChance: 0.4, essenceReward: 5,
            steps: [
                QuestStep(id: "comeback_med_1", instruction: "Name one financial goal you're still working toward", verification: .selfReport, xpReward: 15),
                QuestStep(id: "comeback_med_2", instruction: "Set one intention for this week", verification: .selfReport, xpReward: 25)
            ],
            zone: .awakening),
        QuestDefinition(
            id: "comeback_motivational", title: "The Second Wind", subtitle: "Every champion has fallen. It's the getting up that counts.",
            description: "A broken streak isn't a failure — it's a chance to prove your resilience. The app didn't forget your progress. Pick up where you left off.",
            category: .financialLiteracy, archetype: .interaction, difficulty: .easy, cadence: .daily,
            estimatedImpact: "Streak restart", estimatedTime: "2 minutes", verification: .selfReport,
            baseXP: 35, scratchCardChance: 0.3, essenceReward: 3,
            steps: [QuestStep(id: "comeback_mot_1", instruction: "Open your budget app or bank app — just look. You're back in the game.", verification: .selfReport, xpReward: 35)],
            zone: .awakening),
    ]

    // MARK: - Streak Milestone Lookup

    static let streakMilestones: [Int] = [3, 7, 14, 21, 30, 50, 75, 100, 150, 200, 250, 365]

    static func streakQuest(forMilestone streak: Int) -> QuestDefinition? {
        streakMilestoneQuests.first { $0.id == "streak_\(streak)" }
    }

    static func randomComebackQuest() -> QuestDefinition {
        comebackQuests.randomElement() ?? comebackQuests[0]
    }
}
