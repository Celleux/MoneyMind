import SwiftUI

struct BossDefeatCelebration: View {
    let zone: QuestZone
    let player: PlayerProfile
    @Environment(\.dismiss) private var dismiss
    @State private var showFlash: Bool = false
    @State private var showBossExplosion: Bool = false
    @State private var showDefeatedText: Bool = false
    @State private var showLoot: Bool = false
    @State private var showNextZone: Bool = false
    @State private var showContinue: Bool = false
    @State private var particles: [DefeatParticle] = []
    @State private var lootItems: [LootItem] = []
    @State private var bossScale: CGFloat = 1.0
    @State private var bossOpacity: Double = 1.0
    @State private var bossRotation: Double = 0

    private var nextZone: QuestZone? {
        let all = QuestZone.allCases
        guard let idx = all.firstIndex(of: zone), idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }

    private var isFinalBoss: Bool {
        zone == .legacy
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .opacity(showBossExplosion ? 0 : 0.8)
                    .animation(.easeOut(duration: 0.4), value: showBossExplosion)
            }

            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.x - particle.size / 2,
                        y: particle.y - particle.size / 2,
                        width: particle.size,
                        height: particle.size
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

            VStack(spacing: 0) {
                Spacer()

                if showBossExplosion && !showDefeatedText {
                    Image(systemName: bossIcon)
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(Color(hex: 0xF87171).opacity(0.3))
                        .scaleEffect(bossScale)
                        .opacity(bossOpacity)
                        .rotationEffect(.degrees(bossRotation))
                }

                if showDefeatedText {
                    defeatedTextSection
                        .transition(.scale.combined(with: .opacity))
                }

                if showLoot {
                    lootSection
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.top, 32)
                }

                if showNextZone {
                    nextZoneSection
                        .transition(.scale.combined(with: .opacity))
                        .padding(.top, 24)
                }

                Spacer()

                if showContinue {
                    Button {
                        dismiss()
                    } label: {
                        Text("Continue")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                isFinalBoss
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [Theme.gold, Color(hex: 0xFB923C)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                : AnyShapeStyle(Theme.accent)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 48)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            startCelebrationSequence()
        }
    }

    // MARK: - Defeated Text

    private var defeatedTextSection: some View {
        VStack(spacing: 12) {
            if isFinalBoss {
                Text("FINANCIAL FREEDOM")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.gold)
                    .tracking(4)
            }

            Text("BOSS DEFEATED")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.gold, Color(hex: 0xFB923C)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Theme.gold.opacity(0.5), radius: 30)

            Text("You defeated \(zone.bossName)")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)

            Image(systemName: "trophy.fill")
                .font(.system(size: 52))
                .foregroundStyle(Theme.gold)
                .symbolEffect(.bounce)
                .shadow(color: Theme.gold.opacity(0.4), radius: 20)
                .padding(.top, 8)
        }
    }

    // MARK: - Loot Section

    private var lootSection: some View {
        VStack(spacing: 12) {
            ForEach(lootItems) { item in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(item.color.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: item.icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(item.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Text(item.subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(item.color.opacity(0.2), lineWidth: 0.5)
                        )
                )
                .padding(.horizontal, 32)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
    }

    // MARK: - Next Zone

    private var nextZoneSection: some View {
        Group {
            if let next = nextZone {
                VStack(spacing: 8) {
                    Text("NEW ZONE UNLOCKED")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.accent)
                        .tracking(3)

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.accent.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: next.sfSymbol)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Theme.accent)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(next.rawValue)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Levels \(next.levelRange.lowerBound)-\(next.levelRange.upperBound)")
                                .font(.system(size: 12))
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
                }
                .padding(.horizontal, 32)
            } else {
                VStack(spacing: 8) {
                    Text("ALL ZONES COMPLETE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.gold)
                        .tracking(3)

                    Text("You have achieved financial mastery")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    // MARK: - Animation Sequence

    private func startCelebrationSequence() {
        withAnimation(.easeIn(duration: 0.15)) {
            showFlash = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.5)) {
                showBossExplosion = true
            }
            animateBossExplosion()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            spawnConfetti()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showDefeatedText = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            buildLootItems()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showLoot = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showNextZone = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showContinue = true
            }
        }
    }

    private func animateBossExplosion() {
        withAnimation(.easeOut(duration: 0.6)) {
            bossScale = 2.5
            bossOpacity = 0
            bossRotation = 15
        }
    }

    private func buildLootItems() {
        lootItems = [
            LootItem(
                icon: "star.fill",
                title: "+500 XP",
                subtitle: "Boss defeat bonus",
                color: Theme.gold
            ),
            LootItem(
                icon: "creditcard.fill",
                title: "Epic Scratch Card",
                subtitle: "Guaranteed from boss defeat",
                color: Theme.accent
            ),
            LootItem(
                icon: "diamond.fill",
                title: "+100 Essence",
                subtitle: "Boss loot drop",
                color: Color(hex: 0xA78BFA)
            ),
            LootItem(
                icon: "shield.checkered",
                title: "Boss Slayer Badge",
                subtitle: "Defeated \(zone.bossName)",
                color: Color(hex: 0xF87171)
            )
        ]
    }

    private func spawnConfetti() {
        let colors: [Color] = [Theme.accent, Theme.gold, .white, Color(hex: 0xA78BFA), Color(hex: 0x60A5FA), Color(hex: 0xFB923C)]
        let screenWidth = UIScreen.main.bounds.width

        particles = (0..<80).map { _ in
            DefeatParticle(
                x: CGFloat.random(in: 0...screenWidth),
                y: -CGFloat.random(in: 10...50),
                velocityX: CGFloat.random(in: -3...3),
                velocityY: CGFloat.random(in: 2...8),
                size: CGFloat.random(in: 4...10),
                color: colors.randomElement() ?? .white,
                opacity: 1.0
            )
        }

        let timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { t in
            for i in particles.indices {
                particles[i].x += particles[i].velocityX
                particles[i].y += particles[i].velocityY
                particles[i].velocityY += 0.12
                particles[i].velocityX *= 0.99
            }

            if particles.allSatisfy({ $0.y > UIScreen.main.bounds.height + 60 }) {
                t.invalidate()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            timer.invalidate()
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
}

private struct DefeatParticle: Identifiable {
    let id: UUID = UUID()
    var x: CGFloat
    var y: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}

private struct LootItem: Identifiable {
    let id: UUID = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}
