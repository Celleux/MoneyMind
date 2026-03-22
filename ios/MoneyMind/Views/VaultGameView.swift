import SwiftUI
import SwiftData

struct VaultGameView: View {
    @Query(filter: #Predicate<ScratchCard> { $0.scratchedAt == nil },
           sort: \ScratchCard.earnedAt)
    private var pendingCards: [ScratchCard]

    @Query private var collection: [CollectedCard]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    VaultStat(label: "Collected", value: "\(collection.count)", color: Theme.accent)
                    VaultStat(label: "Pending", value: "\(pendingCards.count)", color: Theme.gold)
                }

                Spacer()

                if pendingCards.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.textMuted)
                        Text("No scratch cards")
                            .font(.headline)
                            .foregroundStyle(Theme.textSecondary)
                        Text("Resist an impulse to earn a scratch card")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textMuted)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 56))
                            .foregroundStyle(Theme.accent)
                            .shadow(color: Theme.accent.opacity(0.3), radius: 12)
                        Text("\(pendingCards.count) card\(pendingCards.count == 1 ? "" : "s") ready to scratch")
                            .font(.title3.bold())
                            .foregroundStyle(Theme.textPrimary)
                        Text("Full scratch experience coming soon")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("The Vault")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

private struct VaultStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard()
    }
}
