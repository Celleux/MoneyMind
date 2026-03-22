import SwiftUI

enum MMButtonVariant {
    case primary
    case secondary
    case danger
    case success
}

struct MMButton: View {
    let title: String
    let icon: String?
    let variant: MMButtonVariant
    let isFullWidth: Bool
    let action: () -> Void

    @State private var hapticTrigger: Bool = false

    init(
        _ title: String,
        icon: String? = nil,
        variant: MMButtonVariant = .primary,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.isFullWidth = fullWidth
        self.action = action
    }

    private var fillColor: Color {
        switch variant {
        case .primary: Theme.accent
        case .secondary: .clear
        case .danger: Theme.danger
        case .success: Theme.success
        }
    }

    private var textColor: Color {
        switch variant {
        case .primary, .danger, .success: .white
        case .secondary: Theme.accent
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary, .danger, .success: .clear
        case .secondary: Theme.accent.opacity(0.5)
        }
    }

    var body: some View {
        Button {
            hapticTrigger.toggle()
            action()
        } label: {
            HStack(spacing: Theme.Spacing.xxs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(textColor)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.xs)
            .background(fillColor, in: .rect(cornerRadius: Theme.Radius.button))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
    }
}
