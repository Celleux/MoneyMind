import SwiftUI

struct EvolveCardView: View {
    let card: CollectedCard
    let essenceAvailable: Int
    let onEvolve: () -> Void

    private var currentRarity: CardRarity? {
        CardRarity(rawValue: card.rarity)
    }

    private var essenceCost: Int {
        guard let rarity = currentRarity else { return 999 }
        switch rarity {
        case .common: return 15
        case .uncommon: return 30
        case .rare: return 60
        case .epic: return 100
        case .legendary: return 999
        }
    }

    private var canEvolve: Bool {
        !card.isMaxEvolved
        && currentRarity != .legendary
        && essenceAvailable >= essenceCost
    }

    private var isMaxed: Bool {
        card.isMaxEvolved || currentRarity == .legendary
    }

    private var nextName: String {
        GachaEngine.nextRarityName(from: card.rarity)
    }

    private var nextColor: Color {
        GachaEngine.nextRarity(from: card.rarity)?.color ?? Theme.textMuted
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.gold)
                Text("Evolve")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
            }

            if isMaxed {
                Text("This card is at maximum evolution")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
            } else {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Current")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Theme.textMuted)
                        Text(card.rarity)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(currentRarity?.color ?? .white)
                    }

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.accent)

                    VStack(spacing: 4) {
                        Text("Evolved")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Theme.textMuted)
                        Text(nextName)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(nextColor)
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.gold)
                    Text("\(essenceCost) Essence")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                    Text("(You have: \(essenceAvailable))")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(essenceAvailable >= essenceCost ? Theme.accent : Theme.textMuted)
                }

                Button {
                    onEvolve()
                } label: {
                    Text("EVOLVE")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(canEvolve ? Theme.background : Theme.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(canEvolve ? Theme.accent : Theme.surface, in: .rect(cornerRadius: 12))
                }
                .disabled(!canEvolve)
            }
        }
        .padding(16)
        .glassCard()
    }
}
