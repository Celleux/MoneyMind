import SwiftUI
import SwiftData

struct BossBattleView: View {
    let player: PlayerProfile
    let zone: QuestZone
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var shaking: Bool = false
    @State private var attackFlash: Bool = false
    @State private var showDefeatCelebration: Bool = false
    @State private var particles: [BossDamageParticle] = []
    @State private var bossBreathing: Bool = false
    @State private var glowPulsing: Bool = false
    @State private var damageShown: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var damagePercent: CGFloat {
        CGFloat(player.currentBossDamageDealt) / CGFloat(max(1, zone.bossHP))
    }

    private var remainingHP: Int {
        max(0, zone.bossHP - player.currentBossDamageDealt)
    }

    private var canDefeat: Bool {
        player.currentBossDamageDealt >= zone.bossHP
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.background, Color(hex: 0x1A0A0A)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            radialBossGlow
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.top, 16)

                Spacer()

                bossNameSection

                bossIconSection
                    .padding(.top, 8)

                Spacer().frame(height: 36)

                hpBarSection
                    .padding(.horizontal, 40)

                Spacer().frame(height: 20)

                objectiveSection
                    .padding(.horizontal, 40)

                Spacer().frame(height: 12)

                damageInfoSection
                    .padding(.horizontal, 40)

                Spacer()

                if canDefeat {
                    finalBlowButton
                        .padding(.horizontal, 40)
                        .padding(.bottom, 48)
                } else {
                    questsNeededHint
                        .padding(.bottom, 48)
                }
            }

            ForEach(particles) { particle in
                Text("-\(particle.damage)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: 0xF87171))
                    .shadow(color: Color(hex: 0xF87171).opacity(0.6), radius: 8)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            if !reduceMotion {
                bossBreathing = true
                glowPulsing = true
            }
            if player.currentBossDamageDealt > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showDamageParticles()
                }
            }
        }
        .fullScreenCover(isPresented: $showDefeatCelebration) {
            BossDefeatCelebration(zone: zone, player: player)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(zone.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.textMuted)
                    .tracking(1)
                Text("Zone Boss")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color(hex: 0xF87171))
                    .tracking(1.5)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Boss Name

    private var bossNameSection: some View {
        VStack(spacing: 6) {
            Text(zone.bossName.uppercased())
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(Color(hex: 0xF87171))
                .tracking(3)
                .shadow(color: Color(hex: 0xF87171).opacity(0.5), radius: 20)
                .multilineTextAlignment(.center)

            Text("Level \(zone.levelRange.upperBound) Guardian")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: - Boss Icon

    private var bossIconSection: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: 0xF87171).opacity(0.25), Color.clear],
                        center: .center,
                        startRadius: 30,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)
                .scaleEffect(glowPulsing ? 1.1 : 0.9)
                .animation(reduceMotion ? nil : .easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: glowPulsing)

            Circle()
                .stroke(Color(hex: 0xF87171).opacity(0.15), lineWidth: 1)
                .frame(width: 180, height: 180)
                .scaleEffect(bossBreathing ? 1.05 : 0.95)
                .animation(reduceMotion ? nil : .easeInOut(duration: 3).repeatForever(autoreverses: true), value: bossBreathing)

            Image(systemName: bossIcon)
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: 0xF87171), Color(hex: 0x991B1B)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color(hex: 0xF87171).opacity(0.6), radius: 30)
                .offset(x: shaking ? -5 : 5)
                .scaleEffect(reduceMotion ? 1.0 : (bossBreathing ? 1.02 : 0.98))
                .animation(reduceMotion ? nil : .easeInOut(duration: 3).repeatForever(autoreverses: true), value: bossBreathing)
                .animation(.easeInOut(duration: 0.06).repeatCount(8, autoreverses: true), value: shaking)
                .opacity(attackFlash ? 0.3 : 1.0)
                .animation(.easeOut(duration: 0.08), value: attackFlash)
        }
    }

    // MARK: - HP Bar

    private var hpBarSection: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(hex: 0xF87171))
                    Text("HP")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Color(hex: 0xF87171))
                }
                Spacer()
                Text("\(remainingHP) / \(zone.bossHP)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Boss HP: \(remainingHP) of \(zone.bossHP)")
            .accessibilityValue("\(Int((1.0 - damagePercent) * 100)) percent remaining")

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.elevated)
                        .frame(height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: 0xF87171).opacity(0.1), lineWidth: 0.5)
                        )

                    let hpFraction = max(0, 1.0 - damagePercent)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: hpColors(percent: hpFraction),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * hpFraction, height: 24)
                        .animation(.spring(response: 0.8), value: damagePercent)
                        .shadow(color: hpColors(percent: hpFraction).first?.opacity(0.4) ?? .clear, radius: 8)

                    if hpFraction > 0 && hpFraction < 1 {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: geo.size.width * hpFraction, height: 12)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .frame(height: 24)

            HStack {
                Text("Damage dealt: \(player.currentBossDamageDealt)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.textMuted)
                Spacer()
                if !canDefeat {
                    Text("\(remainingHP) HP remaining")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(hex: 0xF87171).opacity(0.7))
                } else {
                    Text("Ready to defeat")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.gold)
                }
            }
        }
    }

    // MARK: - Objective

    private var objectiveSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: 0xF87171).opacity(0.7))
                Text("Objective")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color(hex: 0xF87171).opacity(0.7))
                    .tracking(1)
            }

            Text(zone.bossDescription)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Damage Info

    private var damageInfoSection: some View {
        VStack(spacing: 4) {
            Text("Every quest you complete deals damage to this boss")
                .font(.system(size: 11))
                .foregroundStyle(Theme.textMuted)
                .multilineTextAlignment(.center)

            Text("Defeat the boss to unlock the next zone")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.textMuted.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Quests Needed Hint

    private var questsNeededHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Theme.accent.opacity(0.6))
            Text("Complete quests to deal damage")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            Capsule().fill(Theme.surface)
        )
    }

    // MARK: - Final Blow Button

    private var finalBlowButton: some View {
        Button {
            deliverFinalBlow()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .bold))
                Text("DELIVER FINAL BLOW")
                    .font(.system(size: 16, weight: .black))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Theme.gold, Color(hex: 0xFB923C)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Theme.gold.opacity(0.5), radius: 20)
        }
        .symbolEffect(.bounce, isActive: canDefeat)
    }

    // MARK: - Radial Glow

    private var radialBossGlow: some View {
        RadialGradient(
            colors: [
                Color(hex: 0xF87171).opacity(canDefeat ? 0.08 : 0.04),
                Color.clear
            ],
            center: .center,
            startRadius: 50,
            endRadius: 400
        )
        .offset(y: -60)
    }

    // MARK: - Actions

    private func deliverFinalBlow() {
        triggerBossDefeatHaptics()

        shaking = true
        attackFlash = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            attackFlash = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            attackFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            attackFlash = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            shaking = false
            let engine = QuestEngine(modelContext: modelContext)
            let success = engine.defeatBoss(player: player, zone: zone)
            if success {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showDefeatCelebration = true
                }
            }
        }
    }

    private func showDamageParticles() {
        let centerX: CGFloat = 0
        let centerY: CGFloat = -40

        for i in 0..<5 {
            let delay = Double(i) * 0.12
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                var particle = BossDamageParticle(
                    x: centerX + CGFloat.random(in: -60...60),
                    y: centerY + CGFloat.random(in: -30...30),
                    damage: Int.random(in: 5...25),
                    opacity: 1.0
                )
                particles.append(particle)

                let idx = particles.count - 1
                withAnimation(.easeOut(duration: 1.5)) {
                    if idx < particles.count {
                        particles[idx].y -= 80
                        particles[idx].opacity = 0
                    }
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            particles.removeAll()
        }
    }

    // MARK: - Helpers

    private var bossIcon: String {
        switch zone {
        case .awakening: return "eye.trianglebadge.exclamationmark.fill"
        case .budgetForge: return "flame.circle.fill"
        case .savingsCitadel: return "building.columns.circle.fill"
        case .incomeFrontier: return "lizard.fill"
        case .legacy: return "crown.fill"
        }
    }

    private func triggerBossDefeatHaptics() {
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        heavy.prepare()
        heavy.impactOccurred(intensity: 1.0)
        for i in 1...8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                heavy.impactOccurred(intensity: max(0.3, 1.0 - Double(i) * 0.08))
            }
        }
    }

    private func hpColors(percent: CGFloat) -> [Color] {
        if percent > 0.5 { return [Color(hex: 0xF87171), Color(hex: 0xDC2626)] }
        if percent > 0.25 { return [Color(hex: 0xFB923C), Color(hex: 0xF59E0B)] }
        return [Color(hex: 0x34D399), Color(hex: 0x10B981)]
    }
}

private struct BossDamageParticle: Identifiable {
    let id: UUID = UUID()
    var x: CGFloat
    var y: CGFloat
    var damage: Int
    var opacity: Double
}
