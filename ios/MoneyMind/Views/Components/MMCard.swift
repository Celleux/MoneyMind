import SwiftUI

struct MMCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(Theme.Spacing.sm)
            .background(Theme.card, in: .rect(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(Theme.border, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}
