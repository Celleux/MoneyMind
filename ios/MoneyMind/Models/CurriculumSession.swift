import Foundation
import SwiftData

@Model
class CurriculumSession {
    var sessionNumber: Int
    var completedDate: Date?
    var notes: String
    var isCompleted: Bool

    init(sessionNumber: Int, notes: String = "") {
        self.sessionNumber = sessionNumber
        self.completedDate = nil
        self.notes = notes
        self.isCompleted = false
    }
}
