import SwiftUI

nonisolated enum CardSet: String, Codable, CaseIterable, Sendable {
    case saversGuild = "The Savers Guild"
    case compoundInterest = "Masters of Compound Interest"
    case budgetWarriors = "Budget Warriors"
    case debtSlayers = "Debt Slayers"
    case impulseDefenders = "Impulse Defenders"

    var icon: String {
        switch self {
        case .saversGuild: return "shield.checkered"
        case .compoundInterest: return "chart.line.uptrend.xyaxis"
        case .budgetWarriors: return "figure.fencing"
        case .debtSlayers: return "bolt.shield.fill"
        case .impulseDefenders: return "hand.raised.fill"
        }
    }

    @MainActor
    var accentColor: Color {
        switch self {
        case .saversGuild: return Theme.accent
        case .compoundInterest: return Theme.gold
        case .budgetWarriors: return Color(hex: 0x60A5FA)
        case .debtSlayers: return Color(hex: 0xF87171)
        case .impulseDefenders: return Color(hex: 0xA78BFA)
        }
    }

    var totalCards: Int { 10 }
}
