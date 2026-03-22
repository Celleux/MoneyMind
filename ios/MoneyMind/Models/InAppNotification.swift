import Foundation
import SwiftData
import SwiftUI

nonisolated enum NotificationType: String, Codable, Sendable {
    case budgetWarning
    case budgetCritical
    case budgetExceeded
    case billReminder
    case savingsCelebration
    case streakCelebration
    case dailyCheckIn
    case weeklyDigest
    case jitaiNudge
    case milestone
    case general

    var icon: String {
        switch self {
        case .budgetWarning: "chart.bar.fill"
        case .budgetCritical: "exclamationmark.triangle.fill"
        case .budgetExceeded: "xmark.octagon.fill"
        case .billReminder: "creditcard.fill"
        case .savingsCelebration: "star.fill"
        case .streakCelebration: "flame.fill"
        case .dailyCheckIn: "moon.stars.fill"
        case .weeklyDigest: "newspaper.fill"
        case .jitaiNudge: "brain.head.profile.fill"
        case .milestone: "trophy.fill"
        case .general: "bell.fill"
        }
    }

    var color: Color {
        switch self {
        case .budgetWarning: Color(hex: 0xFF9100)
        case .budgetCritical: Color(hex: 0xFF5252)
        case .budgetExceeded: Color(hex: 0xFF5252)
        case .billReminder: Color(hex: 0x00D2FF)
        case .savingsCelebration: Color(hex: 0x00E676)
        case .streakCelebration: Color(hex: 0xFFD700)
        case .dailyCheckIn: Color(hex: 0x6C5CE7)
        case .weeklyDigest: Color(hex: 0x00D2FF)
        case .jitaiNudge: Color(hex: 0x00D2FF)
        case .milestone: Color(hex: 0xFFD700)
        case .general: Color(hex: 0x6C5CE7)
        }
    }
}

nonisolated enum NotificationDeepLink: String, Codable, Sendable {
    case budgetAnalytics
    case recurringExpenses
    case wallet
    case challenges
    case ghostBudget
    case profile
    case eveningReflection
    case home
    case none
}

@Model
class InAppNotification {
    var typeRaw: String
    var title: String
    var body: String
    var timestamp: Date
    var isRead: Bool
    var isDismissed: Bool
    var deepLinkRaw: String
    var metadata: String

    init(
        type: NotificationType,
        title: String,
        body: String,
        deepLink: NotificationDeepLink = .none,
        metadata: String = ""
    ) {
        self.typeRaw = type.rawValue
        self.title = title
        self.body = body
        self.timestamp = Date()
        self.isRead = false
        self.isDismissed = false
        self.deepLinkRaw = deepLink.rawValue
        self.metadata = metadata
    }

    var type: NotificationType {
        NotificationType(rawValue: typeRaw) ?? .general
    }

    var deepLink: NotificationDeepLink {
        NotificationDeepLink(rawValue: deepLinkRaw) ?? .none
    }

    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
