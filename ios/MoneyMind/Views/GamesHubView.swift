import SwiftUI
import SwiftData

struct GamesHubView: View {
    @Query private var scratchCards: [ScratchCard]
    @Query private var cardCollection: [CollectedCard]

    private var pendingCards: Int {
        scratchCards.filter { !$0.isScratched }.count
    }

    private var collectionCount: Int {
        cardCollection.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        StatPill(
                            icon: "sparkles.rectangle.stack",
                            value: "\(pendingCards)",
                            label: "To Scratch",
                            color: Theme.accent
                        )
                        StatPill(
                            icon: "rectangle.stack.fill",
                            value: "\(collectionCount)",
                            label: "Collected",
                            color: Theme.gold
                        )
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: VaultGameView()) {
                        GameCard(
                            title: "The Vault",
                            subtitle: "Scratch & Collect",
                            description: "Resist impulses, earn scratch cards, reveal gacha pulls, collect financial literacy cards",
                            icon: "sparkles.rectangle.stack",
                            badgeCount: pendingCards,
                            accentColor: Theme.accent
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    GameCard(
                        title: "Savings Roulette",
                        subtitle: "Coming Soon",
                        description: "Daily spin wheel with savings challenges",
                        icon: "arrow.trianglehead.2.clockwise.rotate.90.circle",
                        badgeCount: 0,
                        accentColor: Theme.textMuted,
                        isLocked: true
                    )
                    .padding(.horizontal)

                    GameCard(
                        title: "Battle Pass",
                        subtitle: "Coming Soon",
                        description: "30-day seasons with 50 tiers of rewards",
                        icon: "flag.checkered",
                        badgeCount: 0,
                        accentColor: Theme.textMuted,
                        isLocked: true
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Theme.background)
            .navigationTitle("Games")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
