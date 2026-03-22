import Foundation
import SwiftData

@Model
class ChallengeGroup {
    var name: String
    var hashtag: String
    var groupDescription: String
    var startDate: Date
    var endDate: Date
    var participantCount: Int
    var collectiveSavings: Double
    var savingsGoal: Double
    var isJoined: Bool
    var iconName: String

    init(
        name: String,
        hashtag: String,
        groupDescription: String,
        startDate: Date,
        endDate: Date,
        participantCount: Int,
        collectiveSavings: Double,
        savingsGoal: Double,
        iconName: String
    ) {
        self.name = name
        self.hashtag = hashtag
        self.groupDescription = groupDescription
        self.startDate = startDate
        self.endDate = endDate
        self.participantCount = participantCount
        self.collectiveSavings = collectiveSavings
        self.savingsGoal = savingsGoal
        self.isJoined = false
        self.iconName = iconName
    }

    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0)
    }

    var progress: Double {
        guard savingsGoal > 0 else { return 0 }
        return min(1.0, collectiveSavings / savingsGoal)
    }
}
