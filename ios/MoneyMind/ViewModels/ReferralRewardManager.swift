import SwiftUI
import SwiftData

@Observable
@MainActor
class ReferralRewardManager {
    var showMilestoneCelebration: Bool = false
    var currentMilestone: ReferralMilestone?
    var pendingRewards: [ReferralReward] = []

    func processReferralRedemption(
        referralCount: Int,
        profile: UserProfile?,
        playerProfile: PlayerProfile?,
        modelContext: ModelContext
    ) {
        guard let profile, let playerProfile else { return }

        profile.xpPoints += 500

        for _ in 0..<3 {
            let card = ScratchCard(resistedAmount: 0, currency: profile.defaultCurrency)
            modelContext.insert(card)
        }

        pendingRewards = [
            ReferralReward(icon: "star.fill", label: "+500 XP", color: Theme.neonPurple),
            ReferralReward(icon: "creditcard.fill", label: "+3 Scratch Cards", color: Theme.accent),
            ReferralReward(icon: "crown.fill", label: "+7 Days Premium", color: Theme.gold)
        ]

        let milestone = ReferralMilestone.forCount(referralCount)
        if let milestone {
            currentMilestone = milestone
            showMilestoneCelebration = true
        }

        try? modelContext.save()
    }

    func checkMilestone(for count: Int) -> ReferralMilestone? {
        ReferralMilestone.forCount(count)
    }

    var connectorCardSet: [ConnectorCard] {
        [
            ConnectorCard(name: "The Networker", icon: "person.3.fill", rarity: "Rare"),
            ConnectorCard(name: "The Mentor", icon: "lightbulb.fill", rarity: "Rare"),
            ConnectorCard(name: "The Ally", icon: "shield.fill", rarity: "Rare"),
            ConnectorCard(name: "The Motivator", icon: "flame.fill", rarity: "Epic"),
            ConnectorCard(name: "The Legend", icon: "crown.fill", rarity: "Legendary")
        ]
    }
}

nonisolated struct ReferralReward: Identifiable, Sendable {
    let id = UUID()
    let icon: String
    let label: String
    let color: Color
}

nonisolated struct ConnectorCard: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let icon: String
    let rarity: String
}

nonisolated enum ReferralMilestone: Sendable {
    case first
    case fifth
    case tenth

    var title: String {
        switch self {
        case .first: return "Your Network is Growing!"
        case .fifth: return "Connector Card Set Unlocked!"
        case .tenth: return "1 Month Premium Unlocked!"
        }
    }

    var subtitle: String {
        switch self {
        case .first: return "Your first friend just joined Splurj"
        case .fifth: return "5 friends joined — you've unlocked an exclusive card set"
        case .tenth: return "10 friends joined — you've earned 1 month of free Premium"
        }
    }

    var icon: String {
        switch self {
        case .first: return "person.badge.plus"
        case .fifth: return "rectangle.stack.fill"
        case .tenth: return "crown.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .first: return Theme.accent
        case .fifth: return Theme.neonPurple
        case .tenth: return Theme.gold
        }
    }

    static func forCount(_ count: Int) -> ReferralMilestone? {
        switch count {
        case 1: return .first
        case 5: return .fifth
        case 10: return .tenth
        default: return nil
        }
    }
}
