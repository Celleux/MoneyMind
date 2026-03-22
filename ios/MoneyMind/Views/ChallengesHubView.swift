import SwiftUI
import SwiftData

struct ChallengesHubView: View {
    @Query private var challenges: [SavingsChallenge]
    @Query private var quizResults: [QuizResult]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var vm = ChallengesViewModel()
    @State private var selectedType: ChallengeType?
    @State private var activeChallenge: SavingsChallenge?
    @State private var appeared = false

    private var personality: MoneyPersonality {
        quizResults.first?.personality ?? .builder
    }

    private var activeChallenges: [SavingsChallenge] {
        challenges.filter { $0.isActive }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if activeChallenges.isEmpty {
                        emptyStateCard
                            .transition(.scale.combined(with: .opacity))
                    }

                    if !activeChallenges.isEmpty {
                        activeChallengesSection
                    }

                    availableChallengesSection
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Money Challenges")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .fullScreenCover(item: $activeChallenge) { challenge in
                challengeDestination(challenge)
            }
            .overlay {
                if vm.showCelebration {
                    ChallengesCelebrationOverlay(
                        message: vm.celebrationMessage,
                        particles: vm.confettiParticles
                    ) {
                        vm.showCelebration = false
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    appeared = true
                }
            }
        }
    }

    private var emptyStateCard: some View {
        PersonalityEmptyStateView(
            personality: personality,
            icon: "trophy.fill",
            secondaryIcon: "flag.fill",
            headline: "Ready to Challenge Yourself?",
            subtext: "Pick a savings challenge and start\nbuilding your financial muscles"
        )
        .frame(height: 340)
    }

    private var activeChallengesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Theme.warning)
                Text("Active")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
            }

            ForEach(activeChallenges) { challenge in
                ActiveChallengeCard(
                    challenge: challenge,
                    personalityColor: personality.color
                ) {
                    activeChallenge = challenge
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: appeared)
            }
        }
    }

    private var availableChallengesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Theme.gold)
                Text("Available Challenges")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
            }

            ForEach(Array(ChallengeType.allCases.enumerated()), id: \.element) { index, type in
                let alreadyActive = activeChallenges.contains { $0.challengeType == type }
                ChallengePickerCard(type: type, isAlreadyActive: alreadyActive) {
                    if !alreadyActive {
                        withAnimation(Theme.spring) {
                            vm.startChallenge(type: type, context: modelContext)
                        }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15 + Double(index) * 0.08), value: appeared)
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: vm.hapticTrigger)
    }

    @ViewBuilder
    private func challengeDestination(_ challenge: SavingsChallenge) -> some View {
        switch challenge.challengeType {
        case .envelope100:
            EnvelopeChallengeView(challenge: challenge, vm: vm, personalityColor: personality.color)
        case .week52:
            WeekSavingsView(challenge: challenge, vm: vm, personalityColor: personality.color)
        case .noSpend:
            NoSpendChallengeView(challenge: challenge, vm: vm, personalityColor: personality.color)
        case .roundUp:
            RoundUpRaceView(challenge: challenge, vm: vm, personalityColor: personality.color)
        }
    }
}

private struct ActiveChallengeCard: View {
    let challenge: SavingsChallenge
    let personalityColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                MMProgressRing(progress: challenge.progress, lineWidth: 6, size: 60)
                    .overlay {
                        Image(systemName: challenge.challengeType.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(personalityColor)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(challenge.challengeType.title)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 12) {
                        Label("\(challenge.daysActive)d", systemImage: "clock.fill")
                        if challenge.challengeType != .noSpend {
                            Label("$\(Int(challenge.totalSaved))", systemImage: "dollarsign.circle.fill")
                        } else {
                            Label("\(challenge.noSpendStreak) streak", systemImage: "flame.fill")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Theme.elevated)
                                .frame(height: 4)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [personalityColor, Theme.secondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * challenge.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.4))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [personalityColor.opacity(0.08), Theme.card],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [personalityColor.opacity(0.3), personalityColor.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct ChallengePickerCard: View {
    let type: ChallengeType
    let isAlreadyActive: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.accent.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: type.icon)
                        .font(.title3)
                        .foregroundStyle(Theme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(type.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(type.subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            HStack(spacing: 16) {
                Label(type.durationLabel, systemImage: "clock")
                    .font(.caption2)
                    .foregroundStyle(Theme.textMuted)

                HStack(spacing: 2) {
                    ForEach(0..<type.difficulty, id: \.self) { _ in
                        Text("🔥")
                            .font(.caption2)
                    }
                }

                if type.totalGoal > 0 {
                    Text("$\(Int(type.totalGoal))")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.success)
                }

                Spacer()

                if isAlreadyActive {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Active")
                    }
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.success)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Theme.success.opacity(0.12), in: .capsule)
                } else {
                    Button(action: action) {
                        Text("Start")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 7)
                            .background(Theme.accent, in: .capsule)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .padding(16)
        .background(Theme.card, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.border, lineWidth: 0.5)
        )
    }
}
