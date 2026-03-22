import Foundation
import SwiftData

nonisolated enum CoachMessageRole: String, Codable, Sendable {
    case user
    case assistant
    case system
}

@Model
class CoachMessage {
    var id: UUID
    var roleRaw: String
    var content: String
    var timestamp: Date
    var sessionID: UUID

    var role: CoachMessageRole {
        get { CoachMessageRole(rawValue: roleRaw) ?? .system }
        set { roleRaw = newValue.rawValue }
    }

    init(role: CoachMessageRole, content: String, sessionID: UUID) {
        self.id = UUID()
        self.roleRaw = role.rawValue
        self.content = content
        self.timestamp = Date()
        self.sessionID = sessionID
    }
}
