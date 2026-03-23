import SwiftUI
import Lottie

struct LottieAnimationPlayer: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .playOnce
    var speed: CGFloat = 1.0
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var onComplete: (() -> Void)?

    func makeUIView(context: Context) -> some UIView {
        let container = UIView(frame: .zero)
        container.backgroundColor = .clear

        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.contentMode = contentMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        animationView.play { finished in
            if finished { onComplete?() }
        }

        context.coordinator.animationView = animationView
        return container
    }

    func updateUIView(_ uiView: some UIView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var animationView: LottieAnimationView?
    }
}

struct SafeLottieView: View {
    let name: String
    var loopMode: LottieLoopMode = .playOnce
    var speed: CGFloat = 1.0
    var onComplete: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            Color.clear
        } else if LottieAnimation.named(name) != nil {
            LottieAnimationPlayer(
                name: name,
                loopMode: loopMode,
                speed: speed,
                onComplete: onComplete
            )
        } else {
            Color.clear
        }
    }
}

struct ConfettiLottieView: View {
    var body: some View {
        SafeLottieView(name: "confetti_gold", loopMode: .playOnce)
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}

struct CoinShowerLottieView: View {
    var body: some View {
        SafeLottieView(name: "coin_shower", loopMode: .playOnce)
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}

struct SparkleTrailLottieView: View {
    var body: some View {
        SafeLottieView(name: "sparkle_trail", loopMode: .loop)
            .allowsHitTesting(false)
    }
}

struct LevelUpLottieView: View {
    var body: some View {
        SafeLottieView(name: "level_up_burst", loopMode: .playOnce)
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}
