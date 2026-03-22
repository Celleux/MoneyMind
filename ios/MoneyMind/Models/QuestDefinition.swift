import Foundation

nonisolated struct QuestStep: Codable, Identifiable, Sendable {
    let id: String
    let instruction: String
    let verification: VerificationType
    let xpReward: Int
}

nonisolated struct QuestDefinition: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let category: QuestCategory
    let archetype: QuestArchetype
    let difficulty: QuestDifficulty
    let cadence: QuestCadence
    let estimatedImpact: String
    let estimatedTime: String
    let verification: VerificationType
    let baseXP: Int
    let scratchCardChance: Double
    let essenceReward: Int
    let bossHP: Int?
    let steps: [QuestStep]
    let zone: QuestZone
    let chainID: String?
    let chainIndex: Int?
    let prerequisiteQuestID: String?
    let seasonalMonths: [Int]?
    let tiktokMoment: String?
}
