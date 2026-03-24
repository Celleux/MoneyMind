import SwiftUI

struct ReferralMilestoneCelebration: View {
    let milestone: ReferralMilestone
    let referralCount: Int
    let onDismiss: () -> Void

    @State private var phase: Int = 0
    @State private var confettiParticles: [ConfettiParticle] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Theme.background.opacity(0.95).ignoresSafeArea()

            ForEach(confettiParticles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(milestone.accentColor.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .scaleEffect(phase >= 1 ? 1.0 : 0.3)
                        .opacity(phase >= 1 ? 1 : 0)

                    Circle()
                        .fill(milestone.accentColor.opacity(0.2))
                        .frame(width: 110, height: 110)
                        .scaleEffect(phase >= 1 ? 1.0 : 0.3)
                        .opacity(phase >= 1 ? 1 : 0)

                    Image(systemName: milestone.icon)
                        .font(Typography.displayLarge)
                        .foregroundStyle(milestone.accentColor)
                        .scaleEffect(phase >= 1 ? 1.0 : 0.0)
                        .shadow(color: milestone.accentColor.opacity(0.5), radius: 16)
                }
                .animation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.6), value: phase)

                VStack(spacing: 12) {
                    Text(milestone.title)
                        .font(Typography.displaySmall)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(phase >= 2 ? 1 : 0)
                        .offset(y: phase >= 2 ? 0 : 20)

                    Text(milestone.subtitle)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(phase >= 2 ? 1 : 0)
                        .offset(y: phase >= 2 ? 0 : 20)
                }
                .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: phase)

                if case .fifth = milestone {
                    connectorCardPreview
                        .opacity(phase >= 3 ? 1 : 0)
                        .offset(y: phase >= 3 ? 0 : 30)
                        .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: phase)
                }

                if case .tenth = milestone {
                    premiumRewardBadge
                        .opacity(phase >= 3 ? 1 : 0)
                        .scaleEffect(phase >= 3 ? 1.0 : 0.5)
                        .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.6).delay(0.4), value: phase)
                }

                Spacer()

                rewardsStack
                    .opacity(phase >= 3 ? 1 : 0)
                    .offset(y: phase >= 3 ? 0 : 20)
                    .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(0.5), value: phase)

                Button {
                    onDismiss()
                } label: {
                    Text("Awesome!")
                        .font(Typography.headingMedium)
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(milestone.accentColor, in: .rect(cornerRadius: 14))
                }
                .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
                .padding(.horizontal, 24)
                .opacity(phase >= 3 ? 1 : 0)
                .animation(reduceMotion ? .none : .easeOut(duration: 0.3).delay(0.7), value: phase)

                Spacer().frame(height: 40)
            }
        }
        .sensoryFeedback(.success, trigger: phase)
        .onAppear {
            spawnConfetti()
            Task {
                try? await Task.sleep(for: .milliseconds(200))
                phase = 1
                try? await Task.sleep(for: .milliseconds(400))
                phase = 2
                try? await Task.sleep(for: .milliseconds(400))
                phase = 3
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(milestone.title). \(milestone.subtitle)")
    }

    private var rewardsStack: some View {
        VStack(spacing: 8) {
            Text("Your Rewards")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textMuted)

            HStack(spacing: 16) {
                RewardPill(icon: "star.fill", text: "+500 XP", color: Theme.neonPurple)
                RewardPill(icon: "creditcard.fill", text: "+3 Cards", color: Theme.accent)
                RewardPill(icon: "crown.fill", text: "+7 Days", color: Theme.gold)
            }
        }
    }

    private var connectorCardPreview: some View {
        VStack(spacing: 12) {
            Text("Exclusive Card Set Unlocked")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.neonPurple)

            HStack(spacing: -8) {
                ForEach(connectorIcons.indices, id: \.self) { i in
                    ZStack {
                        Circle()
                            .fill(Theme.elevated)
                            .frame(width: 44, height: 44)
                            .overlay(Circle().stroke(Theme.neonPurple.opacity(0.4), lineWidth: 1))

                        Image(systemName: connectorIcons[i])
                            .font(Typography.bodyLarge)
                            .foregroundStyle(Theme.neonPurple)
                    }
                    .zIndex(Double(5 - i))
                }
            }

            Text("The Connector Collection — 5 Cards")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(16)
        .splurjCard(.hero)
        .padding(.horizontal, 32)
    }

    private let connectorIcons = ["person.3.fill", "lightbulb.fill", "shield.fill", "flame.fill", "crown.fill"]

    private var premiumRewardBadge: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(Typography.displaySmall)
                .foregroundStyle(Theme.gold)

            VStack(alignment: .leading, spacing: 2) {
                Text("1 Month Premium")
                    .font(Typography.headingSmall)
                    .foregroundStyle(.white)
                Text("Unlocked for free")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.gold)
            }
        }
        .padding(16)
        .background(Theme.gold.opacity(0.1), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.gold.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 40)
    }

    private func spawnConfetti() {
        guard !reduceMotion else { return }
        let colors: [Color] = [milestone.accentColor, Theme.gold, Theme.neonPurple, Theme.accent, .white]
        for _ in 0..<40 {
            let particle = ConfettiParticle(
                x: CGFloat.random(in: -180...180),
                y: CGFloat.random(in: -400...(-100)),
                size: CGFloat.random(in: 4...10),
                color: colors.randomElement() ?? .white,
                opacity: Double.random(in: 0.4...0.9)
            )
            confettiParticles.append(particle)
        }

        withAnimation(.easeIn(duration: 2.0)) {
            for i in confettiParticles.indices {
                confettiParticles[i].y += CGFloat.random(in: 600...900)
                confettiParticles[i].opacity = 0
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var opacity: Double
}

private struct RewardPill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(Typography.labelSmall)
                .foregroundStyle(color)
            Text(text)
                .font(Typography.labelSmall)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12), in: .capsule)
    }
}
