import SwiftUI

struct MMTextField: View {
    let label: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool
    private var isFloating: Bool { isFocused || !text.isEmpty }

    var body: some View {
        ZStack(alignment: .leading) {
            Text(label)
                .font(.system(size: isFloating ? 12 : 16, weight: .medium, design: .rounded))
                .foregroundStyle(isFocused ? Theme.accent : Theme.textMuted)
                .offset(y: isFloating ? -14 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFloating)

            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundStyle(Theme.textPrimary)
            .keyboardType(keyboardType)
            .focused($isFocused)
            .offset(y: isFloating ? 6 : 0)
        }
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.sm)
        .frame(height: 56)
        .background(Theme.elevated, in: .rect(cornerRadius: Theme.Radius.button))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.button)
                .strokeBorder(
                    isFocused ? Theme.accent : Theme.border,
                    lineWidth: isFocused ? 1.5 : 0.5
                )
                .animation(Theme.colorTransition, value: isFocused)
        )
    }
}
