import SwiftUI

struct SplurjWelcomeScreen: View {
    let onNext: () -> Void

    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var taglineOffset: CGFloat = 20
    @State private var taglineOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    @State private var buttonOpacity: Double = 0
    @State private var particlePhase: CGFloat = 0
    @State private var glowPulse: Bool = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            RadialGradient(
                colors: [Theme.accent.opacity(0.03), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            particleField
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        Text("Splurj")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.accent)
                            .blur(radius: glowPulse ? 12 : 8)
                            .opacity(0.4)

                        Text("Splurj")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.accent, Color(hex: 0x059669)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                    Text("Don't splurge. Splurj.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .opacity(taglineOpacity)
                        .offset(y: taglineOffset)
                }

                Spacer()

                VStack(spacing: 14) {
                    Button(action: onNext) {
                        Text("Get Started")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .sensoryFeedback(.impact(weight: .medium), trigger: true)

                    Text("Takes 2 minutes · 100% free for 3 days")
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
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                logoOpacity = 1
                logoScale = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                taglineOpacity = 1
                taglineOffset = 0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
                buttonOpacity = 1
                buttonOffset = 0
            }
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                particlePhase = 1
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }

    private var particleField: some View {
        Canvas { context, size in
            let particleCount = 30
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

                let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(
                    Circle().path(in: rect),
                    with: .color(Theme.accent.opacity(opacity))
                )
            }
        }
    }
}
