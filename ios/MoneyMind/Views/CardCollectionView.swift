import SwiftUI
import SwiftData

struct CardCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var collection: [CollectedCard]
    @State private var selectedSet: CardSet?
    @State private var selectedCard: CardDefinition?
    @State private var showSetProgress: Bool = false

    private var displayedCards: [CardDefinition] {
        if let set = selectedSet {
            return CardDatabase.cards(forSet: set)
        }
        return CardDatabase.allCards
    }

    private func isCollected(_ cardID: String) -> Bool {
        collection.contains { $0.cardID == cardID }
    }

    private func collectedInfo(_ cardID: String) -> CollectedCard? {
        collection.first { $0.cardID == cardID }
    }

    private func collectedCountForSet(_ set: CardSet) -> Int {
        collection.filter { $0.setName == set.rawValue }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    setFilterChips
                    progressBar
                    cardGrid

                    if let set = selectedSet {
                        SetProgressView(set: set, collectedCount: collectedCountForSet(set))
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Theme.background)
            .navigationTitle("Collection")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Theme.accent)
                }
            }
            .sheet(item: $selectedCard) { card in
                CardDetailView(card: card, collectedInfo: collectedInfo(card.id))
            }
        }
    }

    private var setFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                VaultFilterChip(label: "All", isSelected: selectedSet == nil) {
                    selectedSet = nil
                }
                ForEach(CardSet.allCases, id: \.self) { set in
                    let count = collectedCountForSet(set)
                    VaultFilterChip(
                        label: "\(set.rawValue) \(count)/\(set.totalCards)",
                        isSelected: selectedSet == set,
                        color: set.accentColor
                    ) {
                        selectedSet = set
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
    }

    private var progressBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Collection Progress")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(collection.count)/\(CardDatabase.totalCards)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surface)
                        .frame(height: 8)
                    Capsule()
                        .fill(Theme.accent)
                        .frame(
                            width: geo.size.width * CGFloat(collection.count) / CGFloat(max(CardDatabase.totalCards, 1)),
                            height: 8
                        )
                        .shadow(color: Theme.accent.opacity(0.4), radius: 4)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
    }

    private var cardGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ], spacing: 16) {
            ForEach(displayedCards) { card in
                let collected = isCollected(card.id)
                let info = collectedInfo(card.id)

                Button {
                    if collected {
                        selectedCard = card
                    }
                } label: {
                    cardCell(card: card, collected: collected, info: info)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private func cardCell(card: CardDefinition, collected: Bool, info: CollectedCard?) -> some View {
        ZStack {
            CardArtView(card: card)
                .frame(height: 210)
                .opacity(collected ? 1.0 : 0.12)
                .saturation(collected ? 1.0 : 0)

            if !collected {
                VStack(spacing: 6) {
                    Image(systemName: "questionmark")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Theme.textMuted)
                    Text(card.rarity.label)
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.textMuted)
                }
            }

            if let info, info.isNew {
                VStack {
                    HStack {
                        Spacer()
                        Text("NEW")
                            .font(.system(size: 8, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.background)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(card.rarity.color, in: .capsule)
                            .padding(6)
                    }
                    Spacer()
                }
            }

            if let info, info.duplicateCount > 0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("x\(info.duplicateCount + 1)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Theme.surface.opacity(0.9), in: .capsule)
                            .padding(6)
                    }
                }
            }
        }
    }
}

extension CardDefinition: @retroactive Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated public static func == (lhs: CardDefinition, rhs: CardDefinition) -> Bool {
        lhs.id == rhs.id
    }
}
