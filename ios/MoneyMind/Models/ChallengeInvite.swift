import Foundation
import SwiftData

@Model
class ChallengeInvite {
    var id: String
    var challengeType: String
    var creatorName: String
    var status: String
    var createdAt: Date
    var expiresAt: Date
    var opponentName: String?
    var creatorProgress: Double
    var opponentProgress: Double
    var xpReward: Int

    init(
        id: String = UUID().uuidString,
        challengeType: String,
        creatorName: String,
        status: String = "pending",
        createdAt: Date = Date(),
        expiresAt: Date = Date().addingTimeInterval(7 * 86400),
        opponentName: String? = nil,
        creatorProgress: Double = 0,
        opponentProgress: Double = 0,
        xpReward: Int = 250
    ) {
        self.id = id
        self.challengeType = challengeType
        self.creatorName = creatorName
        self.status = status
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.opponentName = opponentName
        self.creatorProgress = creatorProgress
        self.opponentProgress = opponentProgress
        self.xpReward = xpReward
    }

    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day ?? 0)
    }

    var isExpired: Bool {
        Date() > expiresAt
    }

    var statusIcon: String {
        switch status {
        case "active": return "bolt.fill"
        case "completed": return "checkmark.circle.fill"
        case "pending": return "clock.fill"
        default: return "questionmark.circle"
        }
    }

    var statusColor: String {
        switch status {
        case "active": return "neonGold"
        case "completed": return "gold"
        case "pending": return "textSecondary"
        default: return "textMuted"
        }
    }
}

nonisolated enum FriendChallengeType: String, CaseIterable, Sendable {
    case noSpend7Day = "7-Day No-Spend"
    case save100 = "Save $100 This Week"
    case complete5Quests = "Complete 5 Quests"

    var icon: String {
        switch self {
        case .noSpend7Day: return "nosign"
        case .save100: return "dollarsign.circle.fill"
        case .complete5Quests: return "star.fill"
        }
    }

    var description: String {
        switch self {
        case .noSpend7Day: return "Go 7 days without any impulse purchases. Stay strong!"
        case .save100: return "Save at least $100 this week through avoided purchases."
        case .complete5Quests: return "Race to complete 5 quests before your friend does."
        }
    }

    var duration: TimeInterval {
        switch self {
        case .noSpend7Day: return 7 * 86400
        case .save100: return 7 * 86400
        case .complete5Quests: return 14 * 86400
        }
    }

    var xpReward: Int {
        switch self {
        case .noSpend7Day: return 300
        case .save100: return 250
        case .complete5Quests: return 500
        }
    }

    var color: String {
        switch self {
        case .noSpend7Day: return "neonRed"
        case .save100: return "neonGold"
        case .complete5Quests: return "neonPurple"
        }
    }
}
