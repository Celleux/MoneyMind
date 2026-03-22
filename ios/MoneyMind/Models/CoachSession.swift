import Foundation
import SwiftData

@Model
class CoachSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var sessionNumber: Int
    var xpAwarded: Bool

    init(sessionNumber: Int = 1) {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = nil
        self.sessionNumber = sessionNumber
        self.xpAwarded = false
    }
}
