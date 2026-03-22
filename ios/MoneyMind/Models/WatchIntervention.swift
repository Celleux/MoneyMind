import Foundation
import SwiftData

nonisolated enum WatchInterventionType: String, Codable, Sendable {
    case breathing
    case grounding
    case callPartner
}

@Model
class WatchIntervention {
    var typeRaw: String
    var triggeredAt: Date
    var completedAt: Date?

    var type: WatchInterventionType {
        get { WatchInterventionType(rawValue: typeRaw) ?? .breathing }
        set { typeRaw = newValue.rawValue }
    }

    init(type: WatchInterventionType, triggeredAt: Date = Date()) {
        self.typeRaw = type.rawValue
        self.triggeredAt = triggeredAt
        self.completedAt = nil
    }
}
