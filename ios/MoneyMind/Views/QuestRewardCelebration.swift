import SwiftUI

struct QuestRewardCelebration: View {
    let reward: QuestReward
    @Environment(\.dismiss) private var dismiss
    @State private var showTitle: Bool = false
    @State private var showXP: Bool = false
    @State private var showCard: Bool = false
    @State private var showEssence: Bool = false
    @State private var showBoss: Bool = false
    @State private var showLevelUp: Bool = false
    @State private var showStreak: Bool = false
    @State private var xpCounter: Int = 0
    @State private var particles: [CelebrationParticle] = []
    @State private var canDismiss: Bool = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
                .opacity(0.95)

            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.x - 4,
                        y: particle.y - 6,
                        width: 8,
                        height: 12
                    )
                    context.fill(
                        RoundedRectangle(cornerRadius: 2).path(in: rect),
                        with: .color(particle.color)
                    )
                }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                if showTitle {
                    Text("QUEST COMPLETE")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.accent)
                        .tracking(4)
                        .transition(.scale.combined(with: .opacity))
                }

                if showXP {
                    VStack(spacing: 4) {
                        Text("+\(xpCounter)")
                            .font(.system(size: 56, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.gold)
                            .contentTransition(.numericText(value: Double(xpCounter)))
                        Text("EXPERIENCE POINTS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.textSecondary)
                            .tracking(2)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                if reward.scratchCard && showCard {
                    HStack(spacing: 12) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Theme.accent)
                            .symbolEffect(.bounce)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Scratch Card Earned")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Head to The Vault to reveal it")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .transition(.scale.combined(with: .opacity))
                }

                if reward.essence > 0 && showEssence {
                    HStack(spacing: 8) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(hex: 0xA78BFA))
                        Text("+\(reward.essence) Essence")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color(hex: 0xA78BFA))
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                if reward.bossDamage > 0 && showBoss {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(hex: 0xF87171))
                        Text("-\(reward.bossDamage) Boss HP")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color(hex: 0xF87171))
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                if reward.didLevelUp && showLevelUp {
                    VStack(spacing: 8) {
                        Text("LEVEL UP")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.gold, Color(hex: 0xFB923C)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Theme.gold.opacity(0.5), radius: 20)

                        Text("Level \(reward.newLevel)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                if reward.isLucky && showStreak {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Theme.gold)
                        Text("Lucky Quest Bonus Active")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Theme.gold)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                if canDismiss {
                    Button {
                        dismiss()
                    } label: {
                        Text("Continue")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity)
                }

                Spacer().frame(height: 40)
            }
        }
        .onTapGesture {
            if canDismiss {
                dismiss()
            }
        }
        .onAppear {
            startAnimationSequence()
            if reward.didLevelUp || reward.scratchCard {
                spawnParticles()
            }
        }
    }

    private func startAnimationSequence() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
            showTitle = true
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4)) {
            showXP = true
        }

        let xpTarget = reward.xp
        let steps = 20
        let interval = 0.6 / Double(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * interval) {
                withAnimation(.linear(duration: interval)) {
                    xpCounter = Int(Double(xpTarget) * Double(i) / Double(steps))
                }
            }
        }

        var delay: Double = 1.2

        if reward.scratchCard {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                showCard = true
            }
            delay += 0.4
        }

        if reward.essence > 0 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                showEssence = true
            }
            delay += 0.3
        }

        if reward.bossDamage > 0 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                showBoss = true
            }
            delay += 0.3
        }

        if reward.didLevelUp {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                showLevelUp = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            }
            delay += 0.5
        }

        if reward.isLucky {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                showStreak = true
            }
            delay += 0.3
        }

        withAnimation(.easeOut(duration: 0.3).delay(delay + 0.3)) {
            canDismiss = true
        }
    }

    private func spawnParticles() {
        let colors: [Color] = [Theme.accent, Theme.gold, .white, Color(hex: 0xA78BFA), Color(hex: 0x60A5FA)]
        let screenWidth = UIScreen.main.bounds.width

        particles = (0..<50).map { _ in
            CelebrationParticle(
                x: CGFloat.random(in: 0...screenWidth),
                y: -20,
                velocityX: CGFloat.random(in: -2...2),
                velocityY: CGFloat.random(in: 2...6),
                color: colors.randomElement() ?? .white
            )
        }

        let timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { t in
            for i in particles.indices {
                particles[i].x += particles[i].velocityX
                particles[i].y += particles[i].velocityY
                particles[i].velocityY += 0.12
            }

            if particles.allSatisfy({ $0.y > UIScreen.main.bounds.height + 50 }) {
                t.invalidate()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            timer.invalidate()
        }
    }
}

private struct CelebrationParticle: Identifiable {
    let id: UUID = UUID()
    var x: CGFloat
    var y: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var color: Color
}
