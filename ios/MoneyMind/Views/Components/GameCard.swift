import SwiftUI

struct GameCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let badgeCount: Int
    var accentColor: Color = Theme.accent
    var isLocked: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(isLocked ? Theme.textMuted : Theme.textPrimary)
                    if badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(accentColor)
                            .clipShape(Capsule())
                    }
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(Theme.textMuted)
                    }
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(accentColor)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            if !isLocked {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [accentColor.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
        )
        .opacity(isLocked ? 0.5 : 1.0)
    }
}
