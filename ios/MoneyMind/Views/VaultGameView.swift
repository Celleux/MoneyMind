import SwiftUI
import SwiftData

struct VaultGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(filter: #Predicate<ScratchCard> { $0.scratchedAt == nil },
           sort: \ScratchCard.earnedAt)
    private var pendingCards: [ScratchCard]

    @Query private var collection: [CollectedCard]
    @Query private var gachaStates: [GachaState]

    @State private var showCollection: Bool = false
    @State private var showPityInfo: Bool = false
    @State private var showConfetti: Bool = false
    @State private var showLootOpening: Bool = false
    @State private var lootCard: CardDefinition?
    @State private var currentScratchIndex: Int = 0
    @State private var cardTransition: Bool = false

    private var gachaState: GachaState? { gachaStates.first }

    private var collectionProgress: Double {
        guard CardDatabase.totalCards > 0 else { return 0 }
        return Double(collection.count) / Double(CardDatabase.totalCards)
    }

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
        .fullScreenCover(isPresented: $showLootOpening) {
            if let card = lootCard {
                CardLootOpeningView(card: card) {
                    showLootOpening = false
                    lootCard = nil
                }
            }
        }
    }

    private var statsBar: some View {
        HStack(spacing: 8) {
            VaultStat(
                label: "Collected",
                value: "\(collection.count)/\(CardDatabase.totalCards)",
                color: Theme.accent,
                icon: "rectangle.stack.fill"
            )
            VaultStat(
                label: "Pending",
                value: "\(pendingCards.count)",
                color: pendingCards.isEmpty ? Theme.textMuted : Theme.neonGold,
                icon: "sparkles.rectangle.stack"
            )
            VaultStat(
                label: "Essence",
                value: "\(gachaState?.totalEssence ?? 0)",
                color: Theme.gold,
                icon: "diamond.fill"
            )
            VaultStat(
                label: "Pity",
                value: "\(gachaState?.pullsSinceLastLegendary ?? 0)/50",
                color: Theme.neonPurple,
                icon: "star.circle"
            )
        }
        .padding(.horizontal)
    }

    private var scratchArea: some View {
        Group {
            if !pendingCards.isEmpty {
                VStack(spacing: 16) {
                    fannedCardStack
                    cardCountLabel
                }
                .padding(.vertical, 12)
            } else {
                emptyState
            }
        }
    }

    private var fannedCardStack: some View {
        ZStack {
            let visibleCount = min(pendingCards.count, 4)
            ForEach((0..<visibleCount).reversed(), id: \.self) { index in
                if index == 0 {
                    ScratchCardView(scratchCard: pendingCards[0]) { revealed in
                        handleReveal(scratchCard: pendingCards[0], revealed: revealed)
                    }
                    .id(pendingCards[0].id)
                    .zIndex(10)
                    .opacity(cardTransition ? 0 : 1)
                    .scaleEffect(cardTransition ? 0.9 : 1.0)
                } else {
                    let card = pendingCards[index]
                    let offsetY = CGFloat(index) * 5
                    let scale = 1.0 - CGFloat(index) * 0.03
                    let rarityColor = CardRarity(rawValue: card.cardRarity)?.color ?? Theme.textMuted
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Theme.elevated, Theme.surface],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(rarityColor.opacity(0.2), lineWidth: 1)
                        )
                        .frame(width: 280, height: 400)
                        .scaleEffect(scale)
                        .offset(y: offsetY)
                        .zIndex(Double(visibleCount - index))
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(height: 420)
    }

    private var cardCountLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 11))
                .foregroundStyle(Theme.textMuted)
            Text("\(pendingCards.count) card\(pendingCards.count == 1 ? "" : "s") remaining")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 48))
                .foregroundStyle(Theme.textMuted)
            Text("No scratch cards")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
            Text("Complete quests to earn scratch cards")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Theme.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
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

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surface)
                        .frame(width: 60, height: 6)
                    Capsule()
                        .fill(Theme.accent)
                        .frame(width: 60 * collectionProgress, height: 6)
                }

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
            if reduceMotion {
                showConfetti = true
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    showConfetti = false
                }
            } else {
                lootCard = revealed
                Task {
                    try? await Task.sleep(for: .milliseconds(600))
                    showLootOpening = true
                }
            }
        } else if revealed.rarity == .rare {
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
    var icon: String = ""

    var body: some View {
        VStack(spacing: 4) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(color.opacity(0.6))
            }
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glassCard()
    }
}
