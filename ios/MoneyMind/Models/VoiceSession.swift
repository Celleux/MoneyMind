import Foundation
import SwiftData

@Model
class VoiceSession {
    var id: UUID
    var timestamp: Date
    var duration: Double
    var transcriptText: String

    init(duration: Double = 0, transcriptText: String = "") {
        self.id = UUID()
        self.timestamp = Date()
        self.duration = duration
        self.transcriptText = transcriptText
    }
}
