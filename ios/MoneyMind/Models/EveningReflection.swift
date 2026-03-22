import Foundation
import SwiftData

@Model
class EveningReflection {
    var date: Date
    var starRating: Int
    var triggers: [String]
    var urgeIntensity: Double
    var moneySavedToday: Double
    var note: String

    init(starRating: Int = 3, triggers: [String] = [], urgeIntensity: Double = 0, moneySavedToday: Double = 0, note: String = "") {
        self.date = Date()
        self.starRating = starRating
        self.triggers = triggers
        self.urgeIntensity = urgeIntensity
        self.moneySavedToday = moneySavedToday
        self.note = note
    }
}
