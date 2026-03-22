import Foundation
import SwiftData

@Model
class QuestBuddy {
    var buddyName: String = ""
    var inviteCode: String = ""
    var matchDate: Date = Date()
    var buddyQuestStreak: Int = 0
    var buddyWeeklyCompletions: Int = 0
    var buddyActiveZone: String = "The Awakening"
    var lastCelebrationDate: Date?
    var reactionsData: Data = Data()
    var isActive: Bool = true

    @Transient
    var reactions: [BuddyReaction] {
        get { (try? JSONDecoder().decode([BuddyReaction].self, from: reactionsData)) ?? [] }
        set { reactionsData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    init(buddyName: String, inviteCode: String) {
        self.buddyName = buddyName
        self.inviteCode = inviteCode
        self.matchDate = Date()
        self.buddyQuestStreak = Int.random(in: 1...30)
        self.buddyWeeklyCompletions = Int.random(in: 0...7)
        self.buddyActiveZone = QuestZone.allCases.randomElement()?.rawValue ?? "The Awakening"
    }
}

nonisolated struct BuddyReaction: Codable, Identifiable, Sendable {
    let id: String
    let emoji: String
    let questTitle: String
    let sentAt: Date

    init(emoji: String, questTitle: String) {
        self.id = UUID().uuidString
        self.emoji = emoji
        self.questTitle = questTitle
        self.sentAt = Date()
    }
}
