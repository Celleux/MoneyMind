import SwiftUI
import SwiftData

struct PityInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var gachaStates: [GachaState]
    @Query private var collection: [CollectedCard]

    private var state: GachaState? { gachaStates.first }

    private var legendaryCount: Int {
        collection.filter { $0.rarity == CardRarity.legendary.rawValue }.count
    }

    private var epicCount: Int {
        collection.filter { $0.rarity == CardRarity.epic.rawValue }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    pitySection(
                        title: "Legendary Pity",
                        current: state?.pullsSinceLastLegendary ?? 0,
                        softPity: 35,
                        hardPity: 50,
                        color: Theme.gold,
                        description: "Guaranteed ★★★★★ Legendary card at 50 pulls. Soft pity starts at 35 — your chances increase with every pull."
                    )

                    pitySection(
                        title: "Epic Pity",
                        current: state?.pullsSinceLastEpic ?? 0,
                        softPity: 15,
                        hardPity: 20,
                        color: Color(hex: 0xA78BFA),
                        description: "Guaranteed ★★★★ Epic card every 20 pulls. Soft pity starts at 15."
                    )

                    statsSection

                    howItWorksSection
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Pity Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.accent)
                }
            }
        }
    }

    private func pitySection(title: String, current: Int, softPity: Int, hardPity: Int, color: Color, description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(current)/\(hardPity)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surface)
                        .frame(height: 10)

                    let softPityX = geo.size.width * CGFloat(softPity) / CGFloat(hardPity)
                    Rectangle()
                        .fill(color.opacity(0.15))
                        .frame(width: geo.size.width - softPityX, height: 10)
                        .offset(x: softPityX)
                        .clipShape(.capsule)

                    Capsule()
                        .fill(color)
                        .frame(
                            width: geo.size.width * CGFloat(min(current, hardPity)) / CGFloat(hardPity),
                            height: 10
                        )
                        .shadow(color: color.opacity(0.4), radius: 4)
                }
            }
            .frame(height: 10)

            HStack {
                Text("Soft pity: \(softPity)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
                Spacer()
                Text("Guaranteed: \(hardPity)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
            }

            Text(description)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(16)
        .glassCard()
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Stats")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            statRow(label: "Total Pulls", value: "\(state?.totalPulls ?? 0)")
            statRow(label: "Legendaries Pulled", value: "\(legendaryCount)")
            statRow(label: "Epics Pulled", value: "\(epicCount)")
            statRow(label: "Collection Essence", value: "\(state?.totalEssence ?? 0)")
            statRow(label: "Cards Collected", value: "\(collection.count)/\(CardDatabase.totalCards)")
        }
        .padding(16)
        .glassCard()
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
        }
    }

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How The Vault Works")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text("Every time you resist a spending impulse, you earn a scratch card. Inside each card is a gacha pull — scratch to reveal which financial literacy card you've collected.")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(Theme.textSecondary)

            Text("This is not gambling. There is no money at risk. Every scratch card is free — earned through discipline. Every card teaches real financial wisdom.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.accent)
        }
        .padding(16)
        .glassCard()
    }
}
