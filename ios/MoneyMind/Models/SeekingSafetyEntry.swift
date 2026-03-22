import Foundation
import SwiftData

@Model
class SeekingSafetyEntry {
    var id: UUID
    var topicID: String
    var reflections: [String]
    var journalEntry: String
    var completedDate: Date

    init(topicID: String, reflections: [String] = [], journalEntry: String = "") {
        self.id = UUID()
        self.topicID = topicID
        self.reflections = reflections
        self.journalEntry = journalEntry
        self.completedDate = Date()
    }
}
