import SwiftUI
import SwiftData

struct LevelUpCeremony: View {
    let oldLevel: Int
    let newLevel: Int
    var onDismiss: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query private var profiles: [UserProfile]
    @Query private var quizResults: [QuizResult]

    private var referralCode: String { profiles.first?.referralCode ?? "SP-XXXXX" }
    private var archetypeName: String { (quizResults.first?.personality ?? .builder).rawValue }
    @State private var displayLevel: Int = 0
    @State private var levelScale: CGFloat = 0
    @State private var showTitle: Bool = false
    @State private var bgPhase: Double = 0
    @State private var showRewards: Bool = false
    @State private var rewardsRevealed: Int = 0
    @State private var showContinue: Bool = false
    @State private var particleAngle: Double = 0

    private var newZone: QuestZone? {
        let oldZone = QuestZone.zone(forLevel: oldLevel)
        let zone = QuestZone.zone(forLevel: newLevel)
        return oldZone != zone ? zone : nil
    }

    private var rewards: [LevelReward] {
        var items: [LevelReward] = []
        items.append(LevelReward(icon: "bolt.fill", title: "New quests unlocked", color: Theme.accent))

        if newLevel % 5 == 0 {
            items.append(LevelReward(icon: "creditcard.fill", title: "Bonus scratch card", color: Theme.neonPurple))
        }
        if newLevel % 10 == 0 {
            items.append(LevelReward(icon: "diamond.fill", title: "+100 bonus essence", color: Theme.neonGold))
        }
        if let zone = newZone {
            items.append(LevelReward(icon: zone.sfSymbol, title: "New zone: \(zone.rawValue)", color: Theme.neonEmerald))
        }

        return items
    }

    var body: some View {
        ZStack {
            animatedBackground
                .ignoresSafeArea()

            if !reduceMotion {
                orbitalParticles
                    .allowsHitTesting(false)
            }

            VStack(spacing: 24) {
                Spacer()

                if showTitle {
                    Text("LEVEL UP")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.neonEmerald)
                        .tracking(6)
                        .transition(.opacity)
                }

                Text("\(displayLevel)")
                    .font(.system(size: 96, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.neonGold, Color(hex: 0xFFA500)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .contentTransition(.numericText(value: Double(displayLevel)))
                    .scaleEffect(levelScale)
                    .neonGlow(color: Theme.neonGold, radius: 30)
                    .depthPop(intensity: 2.0)

                if showRewards {
                    VStack(spacing: 10) {
                        ForEach(Array(rewards.enumerated()), id: \.offset) { index, reward in
                            if index < rewardsRevealed {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(reward.color.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: reward.icon)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(reward.color)
                                    }
                                    Text(reward.title)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.surface.opacity(0.7))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(reward.color.opacity(0.2), lineWidth: 0.5)
                                        )
                                )
                                .depthPop(intensity: 0.5)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()

                if showContinue {
                    ShareAchievementButton(
                        type: .levelUp(level: newLevel),
                        level: newLevel,
                        archetypeName: archetypeName,
                        referralCode: referralCode,
                        style: .compact
                    )
                    .transition(.scale(scale: 0.8).combined(with: .opacity))

                    Button {
                        dismiss()
                    } label: {
                        Text("Continue")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.neonEmerald)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 40)
                    .neonGlow(color: Theme.neonEmerald, radius: 10, pulses: true)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer().frame(height: 40)
            }
        }
        .onTapGesture {
            if showContinue {
                dismiss()
            } else {
                skipToEnd()
            }
        }
        .onAppear {
            if reduceMotion {
                skipToEnd()
            } else {
                runSequence()
            }
        }
    }

    // MARK: - Background

    private var animatedBackground: some View {
        ZStack {
            Color.black

            if !reduceMotion {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let phase = (t / 4.0).truncatingRemainder(dividingBy: 1.0)

                    MeshGradient(
                        width: 3, height: 3,
                        points: [
                            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                            [0.0, 0.5], [Float(0.5 + sin(phase * .pi * 2) * 0.1), 0.5], [1.0, 0.5],
                            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                        ],
                        colors: [
                            .black, Theme.neonEmerald.opacity(0.08), .black,
                            Theme.neonGold.opacity(0.06), .black.opacity(0.95), Theme.neonEmerald.opacity(0.06),
                            .black, Theme.neonGold.opacity(0.08), .black
                        ]
                    )
                }
            } else {
                Color.black
            }
        }
    }

    // MARK: - Particles

    private var orbitalParticles: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let cx = size.width / 2
                let cy = size.height * 0.35
                let radius: CGFloat = 80

                for i in 0..<20 {
                    let angle = (t * 0.8 + Double(i) * 0.314) .truncatingRemainder(dividingBy: 2 * .pi)
                    let r = radius + CGFloat(i % 3) * 15
                    let x = cx + cos(angle) * r
                    let y = cy + sin(angle) * r * 0.5
                    let sz: CGFloat = CGFloat(3 + i % 3)

                    let rect = CGRect(x: x - sz / 2, y: y - sz / 2, width: sz, height: sz)
                    context.opacity = 0.6
                    context.fill(Circle().path(in: rect), with: .color(i % 2 == 0 ? Theme.neonGold : Theme.neonEmerald))
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Sequence

    private func runSequence() {
        displayLevel = oldLevel
        SplurjHaptics.levelUp()

        withAnimation(.easeOut(duration: 0.3).delay(0.2)) { showTitle = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                levelScale = 1.0
            }

            let steps = newLevel - oldLevel
            let interval = min(0.3, 1.0 / Double(max(steps, 1)))
            for i in 1...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                        displayLevel = oldLevel + i
                    }
                    SplurjHaptics.coinCollect()

                    if i == steps {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                            levelScale = 1.15
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                levelScale = 1.0
                            }
                        }
                    }
                }
            }
        }

        let rewardDelay = 0.5 + Double(max(newLevel - oldLevel, 1)) * 0.3 + 0.5

        DispatchQueue.main.asyncAfter(deadline: .now() + rewardDelay) {
            showRewards = true
            for i in rewards.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                    SplurjHaptics.rewardItemReveal()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        rewardsRevealed = i + 1
                    }
                }
            }
        }

        let continueDelay = rewardDelay + Double(rewards.count) * 0.2 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + continueDelay) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showContinue = true
            }
        }
    }

    private func skipToEnd() {
        displayLevel = newLevel
        levelScale = 1.0
        showTitle = true
        showRewards = true
        rewardsRevealed = rewards.count
        showContinue = true
    }

    private func dismiss() {
        SplurjHaptics.cardTap()
        onDismiss?()
        CeremonyOverlayManager.shared.dismiss()
    }
}

private struct LevelReward {
    let icon: String
    let title: String
    let color: Color
}
