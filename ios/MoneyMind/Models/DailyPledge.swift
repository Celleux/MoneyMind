import Foundation
import SwiftData

@Model
class DailyPledge {
    var date: Date
    var quoteShown: String
    var completed: Bool

    init(quoteShown: String = "", completed: Bool = false) {
        self.date = Date()
        self.quoteShown = quoteShown
        self.completed = completed
    }
}
