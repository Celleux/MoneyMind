import SwiftUI

struct ZoneBanner: View {
    let zone: QuestZone

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(zone.rawValue.uppercased())
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .tracking(2)

                Text("Levels \(zone.levelRange.lowerBound)-\(zone.levelRange.upperBound)")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.white)

                Text(zone.themeDescription)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: zone.sfSymbol)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Theme.accent.opacity(0.5), Theme.accent.opacity(0.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 4) {
                Text("View Map")
                    .font(.system(size: 9, weight: .medium))
                Image(systemName: "map.fill")
                    .font(.system(size: 9))
            }
            .foregroundStyle(Theme.textMuted)
            .padding(.trailing, 16)
            .padding(.bottom, 8)
        }
    }
}
