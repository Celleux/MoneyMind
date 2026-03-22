import SwiftUI

struct MilestoneCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let accentColor: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isCompleted ? accentColor.opacity(0.15) : Theme.elevated)
                    .frame(width: 48, height: 48)
                    .shadow(color: isCompleted ? accentColor.opacity(0.3) : .clear, radius: 8)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isCompleted ? accentColor : Theme.textMuted.opacity(0.3))
            }

            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(isCompleted ? .white : Theme.textMuted)

            Text(subtitle)
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(Theme.textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(accentColor)
            }
        }
        .frame(width: 100)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .glassCard(cornerRadius: 12)
    }
}
