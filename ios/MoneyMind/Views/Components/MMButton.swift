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

    private var buttonVariant: ButtonVariant {
        switch variant {
        case .primary: .primary
        case .secondary: .secondary
        case .danger: .destructive
        case .success: .primary
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
                }
                Text(title)
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
        }
        .buttonStyle(SplurjButtonStyle(variant: buttonVariant, size: .large))
        .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
    }
}
