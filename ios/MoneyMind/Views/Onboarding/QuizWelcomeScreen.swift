import SwiftUI

struct QuizWelcomeScreen: View {
    let onStart: () -> Void

    @State private var logoScale: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var particlePhase: CGFloat = 0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            particleField
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 32) {
                    ZStack {
                        Circle()
                            .fill(Theme.accent.opacity(0.08))
                            .frame(width: 120, height: 120)
                            .scaleEffect(logoScale * 1.1)

                        Image(systemName: "brain.head.profile.fill")
                            .font(.system(size: 56, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.accent, Theme.secondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(logoScale)
                    }

                    VStack(spacing: 12) {
                        Text("Discover Your\nMoney Personality")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text("5 questions. 60 seconds.\nChange how you see money.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    .opacity(textOpacity)
                }

                Spacer()

                Button(action: onStart) {
                    Text("Let's Go")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(Theme.accent, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(PressableButtonStyle())
                .sensoryFeedback(.impact(weight: .medium), trigger: true)
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .opacity(buttonOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                textOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                buttonOpacity = 1
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                particlePhase = 1
            }
        }
    }

    private var particleField: some View {
        Canvas { context, size in
            let particleCount = 30
            for i in 0..<particleCount {
                let seed = Double(i) * 137.508
                let baseX = (seed.truncatingRemainder(dividingBy: 1.0) + Double(i) * 0.033).truncatingRemainder(dividingBy: 1.0) * size.width
                let speed = 0.3 + (Double(i % 7) * 0.1)
                let yOffset = (Double(particlePhase) * speed + Double(i) * 0.1).truncatingRemainder(dividingBy: 1.0)
                let y = size.height * (1.0 - yOffset)
                let drift = sin(seed + Double(particlePhase) * .pi * 2) * 20
                let x = baseX + drift
                let radius = 1.5 + Double(i % 4) * 0.8
                let opacity = 0.06 + Double(i % 5) * 0.02

                let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(
                    Circle().path(in: rect),
                    with: .color(Theme.accent.opacity(opacity))
                )
            }
        }
    }
}
