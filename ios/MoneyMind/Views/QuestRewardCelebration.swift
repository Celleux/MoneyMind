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
    @State private var showShare: Bool = false
    @State private var canDismiss: Bool = false

    @State private var xpCounter: Int = 0
    @State private var streakCount: Int = 0
    @State private var particles: [CelebrationParticle] = []
    @State private var goldBurst: Bool = false

    @State private var swordSlash: Bool = false
    @State private var damageFloat: Bool = false
    @State private var levelUpScale: CGFloat = 0.3
    @State private var cardBounce: Bool = false
    @State private var essenceFly: Bool = false
    @State private var flameActive: Bool = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
                .opacity(0.97)

            Canvas { context, size in
                for particle in particles {
                    var rect = CGRect(
                        x: particle.x - particle.size / 2,
                        y: particle.y - particle.size / 2,
                        width: particle.size,
                        height: particle.size * 1.5
                    )
                    context.opacity = particle.opacity
                    context.fill(
                        RoundedRectangle(cornerRadius: 2).path(in: rect),
                        with: .color(particle.color)
                    )
                }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()

            if goldBurst {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.gold.opacity(0.4), Theme.gold.opacity(0), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                    .frame(width: 600, height: 600)
                    .scaleEffect(goldBurst ? 1.2 : 0.1)
                    .opacity(goldBurst ? 0 : 1)
                    .animation(.easeOut(duration: 1.2), value: goldBurst)
                    .allowsHitTesting(false)
            }

            VStack(spacing: 20) {
                Spacer()

                if showTitle {
                    VStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Theme.accent)
                            .symbolEffect(.bounce, value: showTitle)

                        Text("QUEST COMPLETE")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.accent)
                            .tracking(4)
                    }
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                }

                if showXP {
                    VStack(spacing: 4) {
                        Text("+\(xpCounter)")
                            .font(.system(size: 60, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.gold, Color(hex: 0xFBBF24)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .contentTransition(.numericText(value: Double(xpCounter)))
                            .shadow(color: Theme.gold.opacity(0.4), radius: 20)

                        Text("EXPERIENCE POINTS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.textSecondary)
                            .tracking(2)

                        if reward.isLucky {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 10))
                                Text("LUCKY QUEST BONUS")
                                    .font(.system(size: 9, weight: .heavy))
                                    .tracking(1)
                            }
                            .foregroundStyle(Theme.gold)
                            .padding(.top, 4)
                        }
                    }
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
                }

                if reward.scratchCard && showCard {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Theme.accent.opacity(0.15))
                                .frame(width: 52, height: 52)

                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Theme.accent)
                                .offset(y: cardBounce ? 0 : -30)
                                .animation(.spring(response: 0.5, dampingFraction: 0.5), value: cardBounce)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Scratch Card Earned")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Head to The Vault to reveal it")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.textSecondary)
                        }

                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Theme.accent.opacity(0.2), radius: 12)
                    )
                    .padding(.horizontal, 32)
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                }

                if reward.essence > 0 && showEssence {
                    HStack(spacing: 10) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(hex: 0xA78BFA))
                            .offset(y: essenceFly ? 0 : 20)
                            .opacity(essenceFly ? 1 : 0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: essenceFly)

                        Text("+\(reward.essence) Essence")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(hex: 0xA78BFA))
                    }
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                }

                if reward.bossDamage > 0 && showBoss {
                    HStack(spacing: 10) {
                        ZStack {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(Color(hex: 0xF87171))
                                .rotationEffect(.degrees(swordSlash ? 0 : -45))
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: swordSlash)

                            if damageFloat {
                                Text("-\(reward.bossDamage)")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(Color(hex: 0xF87171))
                                    .offset(y: damageFloat ? -25 : 0)
                                    .opacity(damageFloat ? 0.6 : 1)
                                    .animation(.easeOut(duration: 1.0), value: damageFloat)
                            }
                        }

                        Text("-\(reward.bossDamage) Boss HP")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(hex: 0xF87171))
                    }
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                }

                if reward.didLevelUp && showLevelUp {
                    VStack(spacing: 10) {
                        Text("LEVEL UP")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.gold, Color(hex: 0xFB923C), Theme.gold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Theme.gold.opacity(0.6), radius: 30)
                            .scaleEffect(levelUpScale)

                        Text("Level \(reward.newLevel)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        if let newZone = zoneChangedTo {
                            VStack(spacing: 4) {
                                Text("NEW ZONE UNLOCKED")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundStyle(Theme.accent)
                                    .tracking(2)

                                HStack(spacing: 8) {
                                    Image(systemName: newZone.sfSymbol)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Theme.accent)
                                    Text(newZone.rawValue)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .transition(.scale(scale: 0.3).combined(with: .opacity))
                }

                if showStreak {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: 0xFB923C), Color(hex: 0xF87171)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .symbolEffect(.bounce, value: flameActive)

                        Text("Quest Streak")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.textSecondary)

                        Text("\(streakCount)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: 0xFB923C))
                            .contentTransition(.numericText(value: Double(streakCount)))
                    }
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                }

                if reward.tiktokMoment != nil && showShare {
                    shareCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()

                if canDismiss {
                    VStack(spacing: 12) {
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

                        Text("Tap anywhere to dismiss")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.textMuted)
                    }
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
            spawnParticles()
        }
    }

    @ViewBuilder
    private var shareCard: some View {
        VStack(spacing: 12) {
            Text(reward.tiktokMoment ?? "")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            if let moment = reward.tiktokMoment {
                ShareLink(item: moment) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .bold))
                        Text("Share your win")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(Theme.accent.opacity(0.15))
                    )
                    .overlay(
                        Capsule().stroke(Theme.accent.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.accent.opacity(0.2), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 32)
    }

    private var zoneChangedTo: QuestZone? {
        guard reward.didLevelUp else { return nil }
        let previousLevel = reward.newLevel - 1
        let oldZone = QuestZone.zone(forLevel: max(1, previousLevel))
        let newZone = QuestZone.zone(forLevel: reward.newLevel)
        return oldZone != newZone ? newZone : nil
    }

    private func startAnimationSequence() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
            showTitle = true
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4)) {
            showXP = true
        }

        animateXPCounter(target: reward.xp, startDelay: 0.5)

        var delay: Double = 1.2

        if reward.scratchCard {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                showCard = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.05) {
                cardBounce = true
            }
            delay += 0.5
        }

        if reward.essence > 0 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                showEssence = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.05) {
                essenceFly = true
            }
            delay += 0.4
        }

        if reward.bossDamage > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                showBoss = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.05) {
                swordSlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.3) {
                damageFloat = true
            }
            delay += 0.4
        }

        if reward.didLevelUp {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                triggerLevelUpHaptics()
                goldBurst = true
                spawnLevelUpBurst()
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay)) {
                showLevelUp = true
                levelUpScale = 1.0
            }
            delay += 0.7
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
            showStreak = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.1) {
            animateStreak()
        }
        delay += 0.5

        if reward.tiktokMoment != nil {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                showShare = true
            }
            delay += 0.5
        }

        withAnimation(.easeOut(duration: 0.3).delay(delay + 0.2)) {
            canDismiss = true
        }
    }

    private func animateXPCounter(target: Int, startDelay: Double) {
        let steps = 25
        let interval = 0.7 / Double(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay + Double(i) * interval) {
                withAnimation(.linear(duration: interval)) {
                    xpCounter = Int(Double(target) * Double(i) / Double(steps))
                }
                if i % 5 == 0 {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.3)
                }
            }
        }
    }

    private func animateStreak() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            streakCount = max(1, reward.newLevel > 1 ? 1 : 1)
            flameActive.toggle()
        }
    }

    private func triggerLevelUpHaptics() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }

    private func spawnParticles() {
        let colors: [Color] = [Theme.accent, Theme.gold, .white, Color(hex: 0xA78BFA), Color(hex: 0x60A5FA)]
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        particles = (0..<40).map { _ in
            CelebrationParticle(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: -50...(-10)),
                velocityX: CGFloat.random(in: -1.5...1.5),
                velocityY: CGFloat.random(in: 0.5...2.5),
                color: colors.randomElement() ?? .white,
                size: CGFloat.random(in: 4...10),
                opacity: Double.random(in: 0.3...0.7)
            )
        }

        let timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { t in
            for i in particles.indices {
                particles[i].x += particles[i].velocityX
                particles[i].y += particles[i].velocityY
                particles[i].velocityY += 0.03
                particles[i].x += sin(particles[i].y * 0.02) * 0.3

                if particles[i].y > screenHeight + 50 {
                    particles[i].y = CGFloat.random(in: -50...(-10))
                    particles[i].x = CGFloat.random(in: 0...screenWidth)
                    particles[i].velocityY = CGFloat.random(in: 0.5...2.5)
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            timer.invalidate()
        }
    }

    private func spawnLevelUpBurst() {
        let colors: [Color] = [Theme.gold, Color(hex: 0xFB923C), .white, Theme.gold.opacity(0.7)]
        let screenWidth = UIScreen.main.bounds.width
        let centerX = screenWidth / 2
        let centerY = UIScreen.main.bounds.height * 0.35

        let burst: [CelebrationParticle] = (0..<30).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 3...8)
            return CelebrationParticle(
                x: centerX,
                y: centerY,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed,
                color: colors.randomElement() ?? .white,
                size: CGFloat.random(in: 5...12),
                opacity: 1.0
            )
        }

        particles.append(contentsOf: burst)
    }
}

private struct CelebrationParticle: Identifiable {
    let id: UUID = UUID()
    var x: CGFloat
    var y: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var color: Color
    var size: CGFloat = 8
    var opacity: Double = 0.6
}
