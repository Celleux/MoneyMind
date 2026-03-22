import SwiftUI

nonisolated enum QuestCategory: String, Codable, CaseIterable, Sendable {
    case moneyRecovery = "Money Recovery"
    case spendingDefense = "Spending Defense"
    case incomeEarning = "Income & Earning"
    case financialLiteracy = "Financial Literacy"
    case socialQuests = "Social & Accountability"
    case generosity = "Generosity & Pay It Forward"

    @MainActor
    var color: Color {
        switch self {
        case .moneyRecovery: return Theme.accent
        case .spendingDefense: return Color(hex: 0x60A5FA)
        case .incomeEarning: return Theme.gold
        case .financialLiteracy: return Color(hex: 0xA78BFA)
        case .socialQuests: return Color(hex: 0xFB923C)
        case .generosity: return Color(hex: 0xF472B6)
        }
    }

    var icon: String {
        switch self {
        case .moneyRecovery: return "arrow.uturn.backward.circle.fill"
        case .spendingDefense: return "shield.checkered"
        case .incomeEarning: return "arrow.up.circle.fill"
        case .financialLiteracy: return "book.closed.fill"
        case .socialQuests: return "person.2.fill"
        case .generosity: return "heart.circle.fill"
        }
    }
}

nonisolated enum QuestArchetype: String, Codable, Sendable {
    case kill = "Kill"
    case fetch = "Fetch"
    case escort = "Escort"
    case delivery = "Delivery"
    case interaction = "Interact"
    case exploration = "Explore"
    case bossBattle = "Boss"
}

nonisolated enum QuestDifficulty: String, Codable, CaseIterable, Sendable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case legendary = "Legendary"

    var xpMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        case .legendary: return 3.0
        }
    }

    @MainActor
    var color: Color {
        switch self {
        case .easy: return Theme.accent
        case .medium: return Color(hex: 0x60A5FA)
        case .hard: return Color(hex: 0xA78BFA)
        case .legendary: return Theme.gold
        }
    }

    var glowRadius: CGFloat {
        switch self {
        case .easy: return 0
        case .medium: return 4
        case .hard: return 8
        case .legendary: return 16
        }
    }
}

nonisolated enum VerificationType: String, Codable, Sendable {
    case selfReport = "Self Report"
    case screenshot = "Screenshot"
    case inAppAction = "In-App Action"
    case photoProof = "Photo Proof"
}

nonisolated enum QuestCadence: String, Codable, Sendable {
    case daily
    case weekly
    case story
    case seasonal
    case boss
}

nonisolated enum QuestStatus: String, Codable, Sendable {
    case locked
    case available
    case active
    case completed
    case claimed
    case expired
    case archived
}
