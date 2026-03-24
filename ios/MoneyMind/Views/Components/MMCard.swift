import SwiftUI

struct MMCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(Theme.Spacing.sm)
            .splurjCard(.elevated)
    }
}
