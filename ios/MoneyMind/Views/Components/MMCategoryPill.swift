import SwiftUI

struct MMCategoryPill: View {
    let label: String
    var color: Color = Theme.accent
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: Theme.Spacing.xxxs) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(isSelected ? .white : Theme.textSecondary)
        }
        .padding(.horizontal, Theme.Spacing.xs)
        .padding(.vertical, 6)
        .background(
            isSelected ? color.opacity(0.2) : Theme.elevated.opacity(0.8),
            in: .capsule
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    isSelected ? color.opacity(0.4) : Theme.border,
                    lineWidth: 0.5
                )
        )
    }
}
