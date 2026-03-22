import SwiftUI

struct VaultFilterChip: View {
    let label: String
    let isSelected: Bool
    var color: Color = Theme.accent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundStyle(isSelected ? Theme.background : Theme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected ? AnyShapeStyle(color) : AnyShapeStyle(Theme.elevated)
                )
                .clipShape(.capsule)
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
