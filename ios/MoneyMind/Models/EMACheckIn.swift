import Foundation
import SwiftData

nonisolated enum EMACheckInType: String, Codable, Sendable {
    case morning
    case afternoon
    case evening
}

@Model
class EMACheckIn {
    var typeRaw: String
    var timestamp: Date
    var urgeLevel: Float
    var mood: String
    var spendingIntention: String
    var stuckToIntention: Bool

    var type: EMACheckInType {
        get { EMACheckInType(rawValue: typeRaw) ?? .morning }
        set { typeRaw = newValue.rawValue }
    }

    init(type: EMACheckInType, urgeLevel: Float = 0, mood: String = "", spendingIntention: String = "", stuckToIntention: Bool = true) {
        self.typeRaw = type.rawValue
        self.timestamp = Date()
        self.urgeLevel = urgeLevel
        self.mood = mood
        self.spendingIntention = spendingIntention
        self.stuckToIntention = stuckToIntention
    }
}
