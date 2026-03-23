import Foundation

nonisolated struct DynamicQuestTemplate: Sendable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let category: QuestCategory
    let difficulty: QuestDifficulty
    let baseXP: Int
    let scratchCardChance: Double
    let essenceReward: Int
    let zone: QuestZone
    let instruction: String
    let impact: String

    func toQuestDefinition(for date: Date = Date()) -> QuestDefinition {
        QuestDefinition(
            id: "\(id)_\(Calendar.current.component(.dayOfYear, from: date))",
            title: title,
            subtitle: subtitle,
            description: description,
            category: category,
            archetype: .interaction,
            difficulty: difficulty,
            cadence: .daily,
            estimatedImpact: impact,
            estimatedTime: "5 minutes",
            verification: .selfReport,
            baseXP: baseXP,
            scratchCardChance: scratchCardChance,
            essenceReward: essenceReward,
            steps: [QuestStep(id: "\(id)_step", instruction: instruction, verification: .selfReport, xpReward: baseXP)],
            zone: zone
        )
    }

    func isAvailable(on date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let hour = calendar.component(.hour, from: date)

        switch id {
        case "dynamic_payday":
            return day == 1 || day == 15
        case "dynamic_weekend":
            return weekday == 6 || weekday == 7 || weekday == 1
        case "dynamic_monday":
            return weekday == 2
        case "dynamic_end_of_month":
            let range = calendar.range(of: .day, in: .month, for: date)
            let lastDay = range?.count ?? 30
            return day >= lastDay - 2
        case "dynamic_evening":
            return hour >= 18
        case "dynamic_morning":
            return hour < 10
        case "dynamic_first_of_month":
            return day == 1
        case "dynamic_tax_day":
            return month == 4 && day >= 1 && day <= 15
        case "dynamic_new_year":
            return (month == 12 && day >= 28) || (month == 1 && day <= 7)
        default:
            return false
        }
    }
}

extension QuestDatabase {

    static let dynamicTemplates: [DynamicQuestTemplate] = [
        DynamicQuestTemplate(
            id: "dynamic_payday",
            title: "The Windfall",
            subtitle: "Allocate your paycheck before midnight",
            description: "Payday is the most dangerous day for your budget. Before the money burns a hole in your account, allocate every dollar intentionally.",
            category: .financialLiteracy, difficulty: .easy, baseXP: 100, scratchCardChance: 0.6, essenceReward: 8, zone: .budgetForge,
            instruction: "Allocate your paycheck: bills, savings, fun, debt — before spending anything", impact: "Intentional allocation"),
        DynamicQuestTemplate(
            id: "dynamic_weekend",
            title: "Weekend Fortress",
            subtitle: "No-spend weekend challenge",
            description: "Weekends account for 40% of discretionary spending. Challenge yourself to a zero-spend weekend — free activities, home cooking, no online orders.",
            category: .spendingDefense, difficulty: .medium, baseXP: 200, scratchCardChance: 0.8, essenceReward: 12, zone: .savingsCitadel,
            instruction: "Complete the entire weekend without any non-essential spending", impact: "$50-150 saved"),
        DynamicQuestTemplate(
            id: "dynamic_monday",
            title: "Fresh Start Monday",
            subtitle: "Set 3 financial intentions for this week",
            description: "Monday sets the tone. Three clear financial intentions — one saving, one earning, one learning — create a framework for a productive financial week.",
            category: .financialLiteracy, difficulty: .easy, baseXP: 80, scratchCardChance: 0.4, essenceReward: 5, zone: .awakening,
            instruction: "Write down 3 financial intentions for this week", impact: "Weekly structure"),
        DynamicQuestTemplate(
            id: "dynamic_end_of_month",
            title: "Month-End Reckoning",
            subtitle: "Review this month's spending vs budget",
            description: "The month is ending. How did you do? Compare actual spending to your budget. Celebrate wins, note overages, and adjust for next month.",
            category: .financialLiteracy, difficulty: .easy, baseXP: 120, scratchCardChance: 0.6, essenceReward: 8, zone: .budgetForge,
            instruction: "Compare this month's actual spending to your budget in each category", impact: "Monthly accountability"),
        DynamicQuestTemplate(
            id: "dynamic_evening",
            title: "Evening Audit",
            subtitle: "Rate today's spending 1-5",
            description: "A quick end-of-day financial check-in. Rate your spending decisions today. Were they intentional? Any regrets? This 30-second habit builds awareness.",
            category: .spendingDefense, difficulty: .easy, baseXP: 60, scratchCardChance: 0.3, essenceReward: 3, zone: .awakening,
            instruction: "Rate today's spending decisions from 1 (regret) to 5 (intentional)", impact: "Daily reflection"),
        DynamicQuestTemplate(
            id: "dynamic_morning",
            title: "Morning Intention",
            subtitle: "What's your money goal today?",
            description: "Start the day with one clear financial intention. 'I will not buy coffee out.' 'I will review my budget.' One sentence changes the trajectory of your day.",
            category: .financialLiteracy, difficulty: .easy, baseXP: 50, scratchCardChance: 0.3, essenceReward: 3, zone: .awakening,
            instruction: "Write one sentence about your financial intention for today", impact: "Daily intention"),
        DynamicQuestTemplate(
            id: "dynamic_first_of_month",
            title: "Rent Day Ritual",
            subtitle: "Confirm all bills are paid",
            description: "First of the month — rent, utilities, subscriptions all hit at once. Verify everything is covered and no surprise charges slipped in.",
            category: .financialLiteracy, difficulty: .easy, baseXP: 80, scratchCardChance: 0.4, essenceReward: 5, zone: .budgetForge,
            instruction: "Check that all monthly bills are paid or scheduled", impact: "Bill management"),
        DynamicQuestTemplate(
            id: "dynamic_tax_day",
            title: "The Tax Sprint",
            subtitle: "Have you filed your taxes yet?",
            description: "Tax Day is approaching. If you haven't filed yet, today is the day to at least START. Gather documents, open TurboTax, or call your accountant.",
            category: .financialLiteracy, difficulty: .medium, baseXP: 200, scratchCardChance: 0.8, essenceReward: 15, zone: .savingsCitadel,
            instruction: "Take one action toward filing your taxes today", impact: "Tax compliance"),
        DynamicQuestTemplate(
            id: "dynamic_new_year",
            title: "Year in Review",
            subtitle: "Calculate your net worth change this year",
            description: "The year is changing. Calculate your net worth now and compare to last year. This single number tells you if you're moving forward or backward.",
            category: .financialLiteracy, difficulty: .medium, baseXP: 200, scratchCardChance: 0.8, essenceReward: 15, zone: .savingsCitadel,
            instruction: "Calculate your current net worth and compare to 12 months ago", impact: "Annual progress"),
        DynamicQuestTemplate(
            id: "dynamic_birthday",
            title: "Birthday Budget",
            subtitle: "Treat yourself within a set budget",
            description: "Happy birthday! You deserve to celebrate. Set a budget for your birthday spending and enjoy it guilt-free within that limit.",
            category: .spendingDefense, difficulty: .easy, baseXP: 100, scratchCardChance: 0.6, essenceReward: 8, zone: .budgetForge,
            instruction: "Set a birthday spending budget and celebrate within it", impact: "Guilt-free enjoyment"),
        DynamicQuestTemplate(
            id: "dynamic_anniversary",
            title: "Splurj Anniversary",
            subtitle: "See your year of progress",
            description: "It's your Splurj anniversary! Review everything you've accomplished: quests completed, money saved, streaks achieved, cards collected.",
            category: .financialLiteracy, difficulty: .easy, baseXP: 150, scratchCardChance: 0.8, essenceReward: 15, zone: .savingsCitadel,
            instruction: "Review your total progress since installing Splurj", impact: "Celebration"),
        DynamicQuestTemplate(
            id: "dynamic_rainy_day",
            title: "Rainy Day Fund Check",
            subtitle: "How's your emergency fund?",
            description: "Rainy days happen. When they do, your emergency fund is your umbrella. Check how many months of expenses it covers and set a target to grow it.",
            category: .financialLiteracy, difficulty: .easy, baseXP: 80, scratchCardChance: 0.4, essenceReward: 5, zone: .savingsCitadel,
            instruction: "Check your emergency fund and calculate how many months it covers", impact: "Safety awareness"),
    ]

    static func availableDynamicQuests(for date: Date = Date()) -> [QuestDefinition] {
        dynamicTemplates.filter { $0.isAvailable(on: date) }.map { $0.toQuestDefinition(for: date) }
    }
}
