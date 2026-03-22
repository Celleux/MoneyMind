import SwiftUI

struct SplurjWelcomeScreen: View {
    let onNext: () -> Void

    @State private var logoScale: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 40
    @State private var buttonOpacity: Double = 0
    @State private var particlePhase: CGFloat = 0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            particleField
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 36) {
                    ZStack {
                        Circle()
                            .fill(Theme.accentGreen.opacity(0.08))
                            .frame(width: 130, height: 130)
                            .scaleEffect(logoScale * 1.1)

                        Circle()
                            .fill(Theme.accentGreen.opacity(0.04))
                            .frame(width: 170, height: 170)
                            .scaleEffect(logoScale * 1.05)

                        Image(systemName: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.accentGreen, Theme.teal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(logoScale)
                    }

                    VStack(spacing: 16) {
                        Text("What's your\nMoney Personality?")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text("Are you a Saver, Builder, Hustler,\nMinimalist, or Generous?\nFind out in 60 seconds.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .opacity(textOpacity)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button(action: onNext) {
                        Text("Discover Mine")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(Theme.accentGreen, in: .rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .sensoryFeedback(.impact(weight: .medium), trigger: true)

                    Text("Takes less than a minute · No signup needed")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .opacity(buttonOpacity)
                .offset(y: buttonOffset)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                textOpacity = 1
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6)) {
                buttonOpacity = 1
                buttonOffset = 0
            }
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                particlePhase = 1
            }
        }
    }

    private var particleField: some View {
        Canvas { context, size in
            let particleCount = 35
            for i in 0..<particleCount {
                let seed = Double(i) * 137.508
                let baseX = (seed.truncatingRemainder(dividingBy: 1.0) + Double(i) * 0.033).truncatingRemainder(dividingBy: 1.0) * size.width
                let speed = 0.2 + (Double(i % 7) * 0.08)
                let yOffset = (Double(particlePhase) * speed + Double(i) * 0.1).truncatingRemainder(dividingBy: 1.0)
                let y = size.height * (1.0 - yOffset)
                let drift = sin(seed + Double(particlePhase) * .pi * 2) * 25
                let x = baseX + drift
                let radius = 1.5 + Double(i % 5) * 0.7
                let opacity = 0.05 + Double(i % 6) * 0.015

                let colors: [Color] = [Theme.accentGreen, Theme.teal, Theme.accent]
                let color = colors[i % colors.count]

                let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(
                    Circle().path(in: rect),
                    with: .color(color.opacity(opacity))
                )
            }
        }
    }
}
