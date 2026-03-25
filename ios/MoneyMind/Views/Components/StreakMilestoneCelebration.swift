import SwiftUI
import SwiftData

struct StreakMilestoneCelebration: View {
    let days: Int
    var onDismiss: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query private var profiles: [UserProfile]
    @Query private var quizResults: [QuizResult]

    private var referralCode: String { profiles.first?.referralCode ?? "SP-XXXXX" }
    private var userLevel: Int { CharacterStage.level(from: profiles.first?.xpPoints ?? 0) }
    private var archetypeName: String { (quizResults.first?.personality ?? .builder).rawValue }
    @State private var showNumber: Bool = false
    @State private var numberScale: CGFloat = 0.3
    @State private var showTitle: Bool = false
    @State private var showReward: Bool = false
    @State private var showContinue: Bool = false
    @State private var flameIntensity: Double = 0

    private var milestone: StreakMilestoneInfo {
        StreakMilestoneInfo.info(for: days)
    }

    private var isEpicMilestone: Bool { days >= 30 }
    private var isLegendaryMilestone: Bool { days >= 100 }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if !reduceMotion {
                fireParticles
                    .allowsHitTesting(false)
            }

            VStack(spacing: 24) {
                Spacer()

                if showNumber {
                    VStack(spacing: 8) {
                        Image(systemName: days >= 365 ? "bird.fill" : "flame.fill")
                            .font(.system(size: days >= 365 ? 64 : 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: days >= 365
                                        ? [Theme.neonGold, Color(hex: 0xFFA500)]
                                        : [Color(hex: 0xFB923C), Color(hex: 0xF87171)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .symbolEffect(.bounce, value: showNumber)
                            .neonGlow(color: days >= 365 ? Theme.neonGold : .orange, radius: isEpicMilestone ? 30 : 20, pulses: true)

                        Text("\(days)")
                            .font(Typography.displayLarge)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: 0xFB923C), Color(hex: 0xF87171), Theme.neonGold],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .scaleEffect(numberScale)
                            .depthPop(intensity: isLegendaryMilestone ? 2.5 : 1.5)
                            .neonGlow(color: .orange, radius: isEpicMilestone ? 25 : 15)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                if showTitle {
                    VStack(spacing: 6) {
                        Text("\(days)-DAY STREAK!")
                            .font(Typography.headingLarge)
                            .foregroundStyle(.white)

                        Text(milestone.title)
                            .font(Typography.headingSmall)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .transition(.opacity)
                }

                if showReward {
                    VStack(spacing: 10) {
                        Text("REWARD")
                            .font(Typography.labelSmall)
                            .foregroundStyle(Theme.neonGold)
                            .tracking(3)

                        HStack(spacing: 12) {
                            Image(systemName: milestone.rewardIcon)
                                .font(Typography.headingLarge)
                                .foregroundStyle(Theme.neonGold)

                            Text(milestone.rewardText)
                                .font(Typography.headingSmall)
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Theme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Theme.neonGold.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Theme.neonGold.opacity(0.2), radius: 12)
                        )
                    }
                    .depthPop(intensity: 0.8)
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                }

                Spacer()

                if showContinue {
                    ShareAchievementButton(
                        type: .streakMilestone(days: days),
                        level: userLevel,
                        archetypeName: archetypeName,
                        referralCode: referralCode,
                        style: .compact
                    )
                    .transition(.scale(scale: 0.8).combined(with: .opacity))

                    Button {
                        dismiss()
                    } label: {
                        Text("Continue")
                            .font(Typography.headingMedium)
                            .foregroundStyle(Theme.buttonTextOnAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: 0xFB923C), Color(hex: 0xF87171)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer().frame(height: 40)
            }
        }
        .onTapGesture {
            if showContinue { dismiss() } else { skipToEnd() }
        }
        .onAppear {
            if reduceMotion { skipToEnd() } else { runSequence() }
        }
    }

    // MARK: - Fire Particles

    private var fireParticles: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let particleCount = min(isEpicMilestone ? 40 : 20, 60)
                let colors: [Color] = [
                    Color(hex: 0xFB923C), Color(hex: 0xF87171),
                    Theme.neonGold, Color(hex: 0xFFEE58)
                ]

                for i in 0..<particleCount {
                    let seed = Double(i) * 1.618
                    let baseX = size.width * CGFloat((seed * 0.37).truncatingRemainder(dividingBy: 1.0))
                    let speed = 40.0 + seed.truncatingRemainder(dividingBy: 30.0)
                    let cycle = t * speed / Double(size.height)
                    let progress = 1.0 - (cycle + seed / 100.0).truncatingRemainder(dividingBy: 1.0)

                    let x = baseX + sin(t * 2 + seed) * 8
                    let y = size.height * CGFloat(progress)
                    let sz = CGFloat(3 + (seed.truncatingRemainder(dividingBy: 5)))
                    let opacity = max(0, progress * flameIntensity)

                    let rect = CGRect(x: x - sz / 2, y: y - sz / 2, width: sz, height: sz)
                    context.opacity = opacity
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(colors[i % colors.count])
                    )
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Sequence

    private func runSequence() {
        let hapticIntensity: UIImpactFeedbackGenerator.FeedbackStyle = isLegendaryMilestone ? .heavy : .medium
        UIImpactFeedbackGenerator(style: hapticIntensity).impactOccurred()

        withAnimation(.easeOut(duration: 1.0)) { flameIntensity = 1.0 }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3)) {
            showNumber = true
            numberScale = 1.0
        }

        withAnimation(.easeOut(duration: 0.3).delay(0.8)) { showTitle = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            SplurjHaptics.rewardItemReveal()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showReward = true }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showContinue = true }
            if days >= 7 {
                AppReviewManager.shared.requestReviewAfterDelay(seconds: 1.5)
            }
        }
    }

    private func skipToEnd() {
        flameIntensity = reduceMotion ? 0 : 1.0
        showNumber = true
        numberScale = 1.0
        showTitle = true
        showReward = true
        showContinue = true
    }

    private func dismiss() {
        SplurjHaptics.cardTap()
        onDismiss?()
        CeremonyOverlayManager.shared.dismiss()
    }
}

struct StreakMilestoneInfo {
    let title: String
    let rewardText: String
    let rewardIcon: String

    static func info(for days: Int) -> StreakMilestoneInfo {
        switch days {
        case 3: return StreakMilestoneInfo(title: "Spark Ignited", rewardText: "+50 bonus XP", rewardIcon: "star.fill")
        case 7: return StreakMilestoneInfo(title: "Week Warrior", rewardText: "Rare scratch card", rewardIcon: "creditcard.fill")
        case 14: return StreakMilestoneInfo(title: "Fortnight Financial", rewardText: "+100 essence", rewardIcon: "diamond.fill")
        case 21: return StreakMilestoneInfo(title: "Habit Formed", rewardText: "Epic scratch card", rewardIcon: "creditcard.fill")
        case 30: return StreakMilestoneInfo(title: "Monthly Master", rewardText: "Title: \"Disciplined\"", rewardIcon: "shield.checkered")
        case 50: return StreakMilestoneInfo(title: "Half Century", rewardText: "Epic card + 200 essence", rewardIcon: "diamond.fill")
        case 75: return StreakMilestoneInfo(title: "Diamond Hands", rewardText: "Title: \"Diamond Hands\"", rewardIcon: "hands.clap.fill")
        case 100: return StreakMilestoneInfo(title: "Centurion", rewardText: "Legendary scratch card", rewardIcon: "crown.fill")
        case 150: return StreakMilestoneInfo(title: "Legend in the Making", rewardText: "500 essence + title", rewardIcon: "star.circle.fill")
        case 200: return StreakMilestoneInfo(title: "Unstoppable", rewardText: "2 Legendary cards", rewardIcon: "creditcard.fill")
        case 250: return StreakMilestoneInfo(title: "Quarter Millennium", rewardText: "1000 essence", rewardIcon: "diamond.fill")
        case 365: return StreakMilestoneInfo(title: "Year of Financial Freedom", rewardText: "Phoenix card (unique!)", rewardIcon: "bird.fill")
        default: return StreakMilestoneInfo(title: "Streak Milestone", rewardText: "+\(days * 2) XP", rewardIcon: "flame.fill")
        }
    }
}
