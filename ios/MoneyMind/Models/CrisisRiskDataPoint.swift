import Foundation
import SwiftData

@Model
class CrisisRiskDataPoint {
    var date: Date
    var hrvAvg: Double
    var urgeFrequency: Int
    var haltHungryScore: Int
    var haltAngryScore: Int
    var haltLonelyScore: Int
    var haltTiredScore: Int
    var sleepHours: Double
    var streakActive: Bool
    var socialActivityCount: Int

    init(
        date: Date = Date(),
        hrvAvg: Double = 0,
        urgeFrequency: Int = 0,
        haltHungryScore: Int = 0,
        haltAngryScore: Int = 0,
        haltLonelyScore: Int = 0,
        haltTiredScore: Int = 0,
        sleepHours: Double = 0,
        streakActive: Bool = true,
        socialActivityCount: Int = 0
    ) {
        self.date = date
        self.hrvAvg = hrvAvg
        self.urgeFrequency = urgeFrequency
        self.haltHungryScore = haltHungryScore
        self.haltAngryScore = haltAngryScore
        self.haltLonelyScore = haltLonelyScore
        self.haltTiredScore = haltTiredScore
        self.sleepHours = sleepHours
        self.streakActive = streakActive
        self.socialActivityCount = socialActivityCount
    }
}
