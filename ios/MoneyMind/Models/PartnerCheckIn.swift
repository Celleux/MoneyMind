import Foundation
import SwiftData

@Model
class PartnerCheckIn {
    var weekRating: Int
    var biggestWin: String
    var biggestChallenge: String
    var nextGoal: String
    var date: Date

    init(weekRating: Int, biggestWin: String, biggestChallenge: String, nextGoal: String) {
        self.weekRating = weekRating
        self.biggestWin = biggestWin
        self.biggestChallenge = biggestChallenge
        self.nextGoal = nextGoal
        self.date = Date()
    }
}
