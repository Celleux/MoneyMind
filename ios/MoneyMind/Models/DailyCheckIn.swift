import Foundation
import SwiftData

@Model
class DailyCheckIn {
    var date: Date
    var mood: Int
    var urgeLevel: Int
    var didResist: Bool
    var note: String

    init(mood: Int = 3, urgeLevel: Int = 1, didResist: Bool = true, note: String = "") {
        self.date = Date()
        self.mood = mood
        self.urgeLevel = urgeLevel
        self.didResist = didResist
        self.note = note
    }
}
