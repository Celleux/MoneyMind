import SwiftUI

struct LottieAnimationPlayer: View {
    let name: String

    var body: some View {
        Color.clear
    }
}

struct SafeLottieView: View {
    let name: String
    var onComplete: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Color.clear
            .onAppear { onComplete?() }
    }
}

struct ConfettiLottieView: View {
    var body: some View {
        Color.clear
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}

struct CoinShowerLottieView: View {
    var body: some View {
        Color.clear
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}

struct SparkleTrailLottieView: View {
    var body: some View {
        Color.clear
            .allowsHitTesting(false)
    }
}

struct LevelUpLottieView: View {
    var body: some View {
        Color.clear
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}
