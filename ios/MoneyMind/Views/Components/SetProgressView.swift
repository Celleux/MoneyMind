import SwiftUI

struct SetProgressView: View {
    let set: CardSet
    let collectedCount: Int

    private var milestones: [(threshold: Int, reward: String, icon: String)] {
        [
            (3, "+5% pull luck for 24h", "arrow.up.circle"),
            (5, "1 free scratch card", "sparkles.rectangle.stack"),
            (8, "Guaranteed Rare+ next pull", "star.fill"),
            (10, "Set complete — Exclusive badge + 100 Essence", "trophy.fill"),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: set.icon)
                    .foregroundStyle(set.accentColor)
                Text(set.rawValue)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(collectedCount)/\(set.totalCards)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(set.accentColor)
            }

            ForEach(milestones, id: \.threshold) { milestone in
                let achieved = collectedCount >= milestone.threshold
                HStack(spacing: 10) {
                    Image(systemName: achieved ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14))
                        .foregroundStyle(achieved ? set.accentColor : Theme.textMuted)

                    Text("\(milestone.threshold)/\(set.totalCards) — \(milestone.reward)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(achieved ? Theme.textPrimary : Theme.textSecondary)
                        .strikethrough(achieved, color: Theme.textMuted)
                }
            }
        }
        .padding(16)
        .glassCard()
    }
}
