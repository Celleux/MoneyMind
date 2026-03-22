import Foundation
import SwiftData

nonisolated enum JITAIToolType: String, Codable, Sendable {
    case urgeSurf
    case haltCheck
    case coolingOff
    case eveningReflection
    case breathing
    case implementationIntention
}

@Model
class JITAIRecommendation {
    var toolTypeRaw: String
    var message: String
    var contextTrigger: String
    var createdAt: Date
    var dismissed: Bool

    var toolType: JITAIToolType {
        get { JITAIToolType(rawValue: toolTypeRaw) ?? .urgeSurf }
        set { toolTypeRaw = newValue.rawValue }
    }

    init(toolType: JITAIToolType, message: String, contextTrigger: String = "") {
        self.toolTypeRaw = toolType.rawValue
        self.message = message
        self.contextTrigger = contextTrigger
        self.createdAt = Date()
        self.dismissed = false
    }
}
