import SwiftUI

struct DepthPopModifier: ViewModifier {
    let intensity: CGFloat
    @State private var appeared: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (appeared ? 1.0 + (0.05 * intensity) : 0.8))
            .brightness(reduceMotion ? 0 : 0.05 * intensity)
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
            .shadow(color: .black.opacity(0.1), radius: 30, y: 15)
            .onAppear {
                guard !reduceMotion else {
                    appeared = true
                    return
                }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                    appeared = true
                }
            }
    }
}

struct FloatingAnimationModifier: ViewModifier {
    let amplitude: CGFloat
    let duration: Double
    let wobble: Bool
    @State private var animating: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .offset(y: reduceMotion ? 0 : (animating ? -amplitude : amplitude))
            .rotationEffect(
                wobble && !reduceMotion
                ? .degrees(animating ? 2 : -2)
                : .zero
            )
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    animating = true
                }
            }
    }
}

extension View {
    func depthPop(intensity: CGFloat = 1.0) -> some View {
        modifier(DepthPopModifier(intensity: intensity))
    }

    func floatingAnimation(amplitude: CGFloat = 5, duration: Double = 3, wobble: Bool = false) -> some View {
        modifier(FloatingAnimationModifier(amplitude: amplitude, duration: duration, wobble: wobble))
    }
}
