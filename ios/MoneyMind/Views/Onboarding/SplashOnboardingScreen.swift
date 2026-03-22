import SwiftUI

struct SplashOnboardingScreen: View {
    let onNext: () -> Void

    @State private var appeared = false
    @State private var textOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.accentGradient)
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .opacity(appeared ? 1 : 0)

                VStack(spacing: 16) {
                    Text("See what impulse\nspending really\ncosts you.")
                        .font(Theme.headingFont(.title))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)

                    Text("It's more than you think.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .opacity(textOpacity)
                }
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                appeared = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                textOpacity = 1
            }
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                onNext()
            }
        }
    }
}
