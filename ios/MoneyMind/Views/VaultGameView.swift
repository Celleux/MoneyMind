import SwiftUI
import SwiftData

struct VaultGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<ScratchCard> { $0.scratchedAt == nil },
           sort: \ScratchCard.earnedAt)
    private var pendingCards: [ScratchCard]

    @Query private var collection: [CollectedCard]
    @Query private var gachaStates: [GachaState]

    @State private var showCollection: Bool = false
    @State private var showPityInfo: Bool = false
    @State private var showConfetti: Bool = false
    @State private var currentScratchID: UUID?

    private var gachaState: GachaState? { gachaStates.first }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    statsBar
                    scratchArea
                    collectionButton
                    RecentPullsSection(collection: Array(collection))
                }
                .padding(.vertical)
            }

            if showConfetti {
                VaultConfettiView()
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
        .navigationTitle("The Vault")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showPityInfo = true } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showCollection) {
            CardCollectionView()
        }
        .sheet(isPresented: $showPityInfo) {
            PityInfoSheet()
        }
    }

    private var statsBar: some View {
        HStack(spacing: 8) {
            VaultStat(
                label: "Collected",
                value: "\(collection.count)/\(CardDatabase.totalCards)",
                color: Theme.accent
            )
            VaultStat(
                label: "Pending",
                value: "\(pendingCards.count)",
                color: Theme.gold
            )
            VaultStat(
                label: "Essence",
                value: "\(gachaState?.totalEssence ?? 0)",
                color: Theme.gold
            )
            VaultStat(
                label: "Pity",
                value: "\(gachaState?.pullsSinceLastLegendary ?? 0)/50",
                color: Theme.gold
            )
        }
        .padding(.horizontal)
    }

    private var scratchArea: some View {
        Group {
            if let card = pendingCards.first {
                VStack(spacing: 12) {
                    ScratchCardView(scratchCard: card) { revealed in
                        handleReveal(scratchCard: card, revealed: revealed)
                    }
                    .id(card.id)

                    Text("\(pendingCards.count) card\(pendingCards.count == 1 ? "" : "s") remaining")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.vertical, 12)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.textMuted)
                    Text("No scratch cards")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                    Text("Resist an impulse to earn a scratch card")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 60)
            }
        }
    }

    private var collectionButton: some View {
        Button { showCollection = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.stack.fill")
                    .foregroundStyle(Theme.accent)
                Text("View Collection")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(collection.count)/\(CardDatabase.totalCards)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(16)
            .glassCard()
        }
        .padding(.horizontal)
    }

    private func handleReveal(scratchCard: ScratchCard, revealed: CardDefinition) {
        scratchCard.scratchedAt = Date()

        if let existing = collection.first(where: { $0.cardID == revealed.id }) {
            existing.duplicateCount += 1
            let essenceReward: Int
            switch revealed.rarity {
            case .common: essenceReward = 5
            case .uncommon: essenceReward = 10
            case .rare: essenceReward = 25
            case .epic: essenceReward = 50
            case .legendary: essenceReward = 100
            }
            if let state = gachaState {
                state.totalEssence += essenceReward
            }
        } else {
            let newCard = CollectedCard(
                cardID: revealed.id,
                rarity: revealed.rarity.rawValue,
                setName: revealed.set.rawValue
            )
            modelContext.insert(newCard)
        }

        if revealed.rarity == .epic || revealed.rarity == .legendary {
            showConfetti = true
            Task {
                try? await Task.sleep(for: .seconds(3))
                showConfetti = false
            }
        }
    }
}

private struct VaultStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCard()
    }
}
