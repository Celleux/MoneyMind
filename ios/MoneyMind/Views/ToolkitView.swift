import SwiftUI

struct ToolkitView: View {
    @State private var showBudgetAnalytics = false
    @State private var showGhostBudget = false
    @State private var showVibeCheck = false
    @State private var showChallenges = false
    @State private var showUrgeSurf = false
    @State private var showCoolingOff = false
    @State private var showHALTCheck = false
    @State private var showIntentions = false
    @State private var showCoach = false
    @State private var showExercises = false
    @State private var showEmergency = false
    @State private var showDNSBlocking = false
    @State private var showOneSecGuide = false
    @State private var appeared = false
    @AppStorage("blockingEnabled") private var blockingEnabled = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("What do you need right now?")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 4)

                    spendingToolsSection
                    impulseControlSection
                    coachingSection
                    crisisSupportLink
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    appeared = true
                }
            }
            .fullScreenCover(isPresented: $showBudgetAnalytics) { BudgetAnalyticsView() }
            .fullScreenCover(isPresented: $showGhostBudget) { GhostBudgetView() }
            .fullScreenCover(isPresented: $showVibeCheck) { VibeCheckAnalyticsView() }
            .fullScreenCover(isPresented: $showChallenges) { ChallengesHubView() }
            .fullScreenCover(isPresented: $showUrgeSurf) { UrgeSurfView() }
            .fullScreenCover(isPresented: $showCoolingOff) { CoolingOffView() }
            .fullScreenCover(isPresented: $showHALTCheck) { HALTCheckView() }
            .fullScreenCover(isPresented: $showIntentions) { ImplementationIntentionsView() }
            .fullScreenCover(isPresented: $showCoach) { CoachChatView() }
            .fullScreenCover(isPresented: $showExercises) { ACTExercisesView() }
            .fullScreenCover(isPresented: $showEmergency) { EmergencyCrisisView() }
            .fullScreenCover(isPresented: $showDNSBlocking) { DNSBlockingWizardView() }
            .fullScreenCover(isPresented: $showOneSecGuide) { OneSecBreathingGuideView() }
        }
    }

    // MARK: - Spending Tools

    private var spendingToolsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "dollarsign.circle.fill", title: "Spending Tools")

            LazyVGrid(columns: columns, spacing: 12) {
                ToolGridCard(
                    icon: "chart.bar.fill",
                    title: "Budget Tracker",
                    subtitle: "Track your spending across categories",
                    index: 0,
                    appeared: appeared
                ) { showBudgetAnalytics = true }

                ToolGridCard(
                    icon: "eye.trianglebadge.exclamationmark.fill",
                    title: "Ghost Budget",
                    subtitle: "What-if scenarios for your money",
                    index: 1,
                    appeared: appeared
                ) { showGhostBudget = true }

                ToolGridCard(
                    icon: "face.smiling.inverse",
                    title: "Vibe Check",
                    subtitle: "How do you feel about that purchase?",
                    index: 2,
                    appeared: appeared
                ) { showVibeCheck = true }

                ToolGridCard(
                    icon: "trophy.fill",
                    title: "Challenges",
                    subtitle: "Savings goals and streaks",
                    index: 3,
                    appeared: appeared
                ) { showChallenges = true }
            }
        }
    }

    // MARK: - Impulse Control

    private var impulseControlSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "hand.raised.fill", title: "Impulse Control")

            LazyVGrid(columns: columns, spacing: 12) {
                ToolGridCard(
                    icon: "wind",
                    title: "Pause & Breathe",
                    subtitle: "Guided breathing before buying",
                    index: 4,
                    appeared: appeared
                ) { showUrgeSurf = true }

                ToolGridCard(
                    icon: "timer",
                    title: "Cool Down",
                    subtitle: "Wait it out with a countdown timer",
                    index: 5,
                    appeared: appeared
                ) { showCoolingOff = true }

                ToolGridCard(
                    icon: "book.fill",
                    title: "Urge Journal",
                    subtitle: "Log what triggered the urge",
                    index: 6,
                    appeared: appeared
                ) { showHALTCheck = true }

                ToolGridCard(
                    icon: "lightbulb.fill",
                    title: "If-Then Plan",
                    subtitle: "Pre-set your response to triggers",
                    index: 7,
                    appeared: appeared
                ) { showIntentions = true }
            }

            blockingCards
        }
    }

    // MARK: - Coaching & Therapy

    private var coachingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "brain.head.profile.fill", title: "Coaching & Therapy")

            Button {
                showCoach = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Theme.accentDim)
                            .frame(width: 52, height: 52)
                        Image(systemName: "bubble.left.and.text.bubble.right.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.accent)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("AI Money Coach")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        Text("Talk through what you're feeling")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textMuted)
                }
                .padding(16)
                .glassCard()
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: showCoach)

            LazyVGrid(columns: columns, spacing: 12) {
                ToolGridCard(
                    icon: "figure.mind.and.body",
                    title: "Exercises",
                    subtitle: "CBT & ACT techniques",
                    index: 8,
                    appeared: appeared
                ) { showExercises = true }
            }
        }
    }

    // MARK: - Blocking Cards

    private var blockingCards: some View {
        VStack(spacing: 12) {
            Button {
                showDNSBlocking = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Theme.accentDim)
                            .frame(width: 44, height: 44)
                        Image(systemName: "shield.checkered")
                            .font(.body)
                            .foregroundStyle(Theme.accent)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("Block Gambling Sites")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            if blockingEnabled {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                        Text(blockingEnabled ? "DNS protection is active" : "Set up DNS-level site blocking")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Spacer()

                    if !blockingEnabled {
                        Text("+100 XP")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.accentDim, in: .capsule)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.textMuted)
                    }
                }
                .padding(14)
                .glassCard()
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: showDNSBlocking)

            Button {
                showOneSecGuide = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Theme.accentDim)
                            .frame(width: 44, height: 44)
                        Image(systemName: "lungs.fill")
                            .font(.body)
                            .foregroundStyle(Theme.accent)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Add Breathing Pause")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Pause before opening tempting apps")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textMuted)
                }
                .padding(14)
                .glassCard()
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: showOneSecGuide)
        }
    }

    // MARK: - Crisis Support

    private var crisisSupportLink: some View {
        Button {
            showEmergency = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.caption)
                Text("Need urgent help? Tap for immediate support")
                    .font(.footnote)
                Image(systemName: "arrow.right")
                    .font(.caption2)
            }
            .foregroundStyle(Theme.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: showEmergency)
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
                .font(.subheadline)
            Text(title)
                .font(Theme.headingFont(.headline))
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

// MARK: - Tool Grid Card

private struct ToolGridCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let index: Int
    let appeared: Bool
    let action: () -> Void

    @State private var tapped = false

    var body: some View {
        Button {
            tapped.toggle()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Theme.accent)
                    .frame(width: 40, height: 40)
                    .background(Theme.accentDim, in: .rect(cornerRadius: 10))

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .glassCard()
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: tapped)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.06), value: appeared)
    }
}
