import SwiftUI
import SwiftData

struct QuestChainGrid: View {
    @Environment(\.modelContext) private var modelContext

    private let chains: [(id: String, name: String, icon: String, color: Color)] = [
        ("chain_savers_guild", "The Saver's Journey", "banknote.fill", Color(hex: 0x34D399)),
        ("chain_compound", "The Compound Path", "chart.line.uptrend.xyaxis", Color(hex: 0xF5C542)),
        ("chain_budget_warriors", "The Budget Battle", "shield.lefthalf.filled", Color(hex: 0x60A5FA)),
        ("chain_debt_slayers", "Debt Freedom Road", "bolt.circle.fill", Color(hex: 0xA78BFA)),
        ("chain_impulse_defenders", "Impulse Mastery", "hand.raised.fill", Color(hex: 0xFB923C)),
    ]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "link")
                    .foregroundStyle(Color(hex: 0xA78BFA))
                Text("Quest Chains")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                Spacer()
                Text("5 story arcs")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ], spacing: 12) {
                ForEach(chains, id: \.id) { chain in
                    ChainCard(
                        chainID: chain.id,
                        name: chain.name,
                        icon: chain.icon,
                        accentColor: chain.color,
                        modelContext: modelContext
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct ChainCard: View {
    let chainID: String
    let name: String
    let icon: String
    let accentColor: Color
    let modelContext: ModelContext

    private var progress: (completed: Int, total: Int) {
        let engine = QuestEngine(modelContext: modelContext)
        return engine.chainProgress(chainID: chainID)
    }

    private var progressFraction: Double {
        guard progress.total > 0 else { return 0 }
        return Double(progress.completed) / Double(progress.total)
    }

    private var isComplete: Bool {
        progress.completed >= progress.total && progress.total > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(accentColor)
                }

                Spacer()

                if isComplete {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.gold)
                }
            }

            Text(name)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 4)

            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Theme.elevated)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(accentColor)
                            .frame(width: geo.size.width * progressFraction, height: 6)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(progress.completed)/\(progress.total)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(accentColor)
                    Spacer()
                    Text(isComplete ? "Complete" : "In Progress")
                        .font(.system(size: 9))
                        .foregroundStyle(Theme.textMuted)
                }
            }
        }
        .padding(14)
        .frame(minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isComplete ? accentColor.opacity(0.4) : Theme.elevated.opacity(0.5),
                            lineWidth: isComplete ? 1 : 0.5
                        )
                )
        )
        .shadow(color: isComplete ? accentColor.opacity(0.2) : .clear, radius: isComplete ? 8 : 0)
    }
}
