import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \ImpulseLog.date, order: .reverse) private var impulseLogs: [ImpulseLog]
    @State private var showLogWin = false
    @State private var showEveningReflection = false
    @State private var showUrgeSurf = false
    @State private var showCoach = false
    @State private var appeared = false
    @State private var streakBounce = 0
    @State private var characterVM = CharacterViewModel()
    @State private var healthVM = HealthViewModel()
    @Query(sort: \EveningReflection.date, order: .reverse) private var reflections: [EveningReflection]
    @Query(sort: \HALTCheckIn.date, order: .reverse) private var haltCheckIns: [HALTCheckIn]
    @Query(sort: \UrgeSurfSession.date, order: .reverse) private var urgeSessions: [UrgeSurfSession]
    @Environment(\.modelContext) private var modelContext

    private var profile: UserProfile? { profiles.first }
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var dayCount: Int {
        guard let start = profile?.startDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection

                    if profile?.simpleMode == true {
                        SimpleModeView(
                            dayCount: dayCount,
                            totalSaved: profile?.totalSaved ?? 0,
                            level: characterVM.level
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.1), value: appeared)
                    } else {
                        characterSection
                        xpSection
                    }

                    DailyPledgeCard()
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.12), value: appeared)

                    EMACheckInCard()
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.14), value: appeared)

                    NotificationPermissionCard()
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.15), value: appeared)

                    streakCard

                    hrvSection

                    if !healthVM.jitaiSuggestions.isEmpty {
                        JITAIRecommendationCard(
                            suggestions: healthVM.jitaiSuggestions,
                            onSelectTool: handleJITAITool
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.23), value: appeared)
                    }

                    if let sdtMsg = characterVM.sdtMessage(profile: profile ?? UserProfile(name: "")) {
                        sdtInsightCard(sdtMsg)
                    }

                    moneySavedCard

                    eveningReflectionPrompt

                    CurriculumSectionView(dayCount: dayCount)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.28), value: appeared)

                    coachShortcutCard

                    quickActionsRow
                    socialProofSection
                    dailyInsightCard
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showLogWin) {
                LogWinSheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showEveningReflection) {
                EveningReflectionSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .navigationDestination(for: Int.self) { sessionNumber in
                CurriculumSessionDetailView(sessionNumber: sessionNumber)
            }
            .sheet(isPresented: $showUrgeSurf) {
                UrgeSurfView()
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showCoach) {
                CoachChatView()
            }
            .onAppear {
                if let profile {
                    characterVM.syncFromProfile(profile)
                    profile.lastOpenDate = Date()
                    NotificationService.shared.scheduleAllNotifications(profile: profile)
                }
                Task {
                    await healthVM.requestAuthAndLoad()
                    await NotificationService.shared.checkAuthorizationStatus()
                    healthVM.analyzePatterns(
                        haltCheckIns: haltCheckIns,
                        reflections: reflections,
                        urgeSessions: urgeSessions,
                        profile: profile,
                        modelContext: modelContext
                    )
                    healthVM.collectDailyCrisisData(
                        haltCheckIns: haltCheckIns,
                        urgeSessions: urgeSessions,
                        profile: profile,
                        modelContext: modelContext
                    )
                }
            }
            .onChange(of: profile?.xpPoints) { _, _ in
                if let profile {
                    characterVM.syncFromProfile(profile)
                }
            }
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting),")
                    .font(.title2)
                    .foregroundStyle(Theme.textSecondary)
                Text(profile?.name ?? "Friend")
                    .font(Theme.headingFont(.largeTitle))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            Text(Date(), format: .dateTime.month(.abbreviated).day())
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: .capsule)
        }
        .padding(.top, 16)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.spring(response: 0.5).delay(0.05), value: appeared)
        .onAppear { appeared = true }
    }

    private var characterSection: some View {
        VStack(spacing: 12) {
            ZStack {
                CharacterView(
                    stage: characterVM.stage,
                    reaction: characterVM.currentReaction,
                    level: characterVM.level
                )
                .sensoryFeedback(.impact(weight: .light), trigger: characterVM.currentReaction)

                if characterVM.showXPGain {
                    Text("+\(characterVM.lastXPGain) XP")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(characterVM.stage.primaryColor)
                        .offset(y: -70)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity).combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                }

                if characterVM.showReactionMessage {
                    ReactionMessageBubble(
                        message: characterVM.reactionMessage,
                        stage: characterVM.stage
                    )
                    .offset(y: 70)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)

            ShareCharacterButton(
                stage: characterVM.stage,
                level: characterVM.level,
                totalSaved: profile?.totalSaved ?? 0,
                streak: profile?.currentStreak ?? 0,
                dayCount: dayCount
            )
        }
        .padding(.vertical, 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.1), value: appeared)
    }

    private var xpSection: some View {
        XPProgressBar(
            progress: characterVM.levelProgress,
            level: characterVM.level,
            stage: characterVM.stage,
            currentXP: characterVM.currentXP
        )
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(characterVM.stage.primaryColor.opacity(0.1), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.15), value: appeared)
    }

    private var flameSize: CGFloat {
        let streak = profile?.currentStreak ?? 0
        switch streak {
        case 90...: return 52
        case 60..<90: return 48
        case 30..<60: return 44
        case 14..<30: return 40
        case 7..<14: return 38
        default: return 36
        }
    }

    private var streakCard: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("\(profile?.currentStreak ?? 0)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accentGradient)
                    .contentTransition(.numericText())
                Text("Day Streak")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Label("Best: \(profile?.longestStreak ?? 0) days", systemImage: "trophy.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.gold)

                if let profile, characterVM.canUseGrace(profile) {
                    Label("Grace available", systemImage: "shield.fill")
                        .font(.caption2)
                        .foregroundStyle(Theme.teal.opacity(0.7))
                }

                Image(systemName: "flame.fill")
                    .font(.system(size: flameSize))
                    .foregroundStyle(Theme.accentGradient)
                    .symbolEffect(.bounce, value: streakBounce)
                    .onAppear {
                        if (profile?.currentStreak ?? 0) > 0 {
                            streakBounce += 1
                        }
                    }
            }
        }
        .padding(20)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Theme.teal.opacity(0.15), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.2), value: appeared)
    }

    private var hrvSection: some View {
        HRVCardView(
            hrvData: healthVM.hrvData,
            trend: healthVM.hrvTrend,
            todayHRV: healthVM.todayHRV,
            weekAvgHRV: healthVM.weekAvgHRV,
            isStressDetected: healthVM.isStressDetected,
            onSurfUrge: { showUrgeSurf = true }
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.21), value: appeared)
    }

    private func handleJITAITool(_ toolType: JITAIToolType) {
        switch toolType {
        case .urgeSurf:
            showUrgeSurf = true
        case .haltCheck, .coolingOff, .breathing, .implementationIntention:
            break
        case .eveningReflection:
            showEveningReflection = true
        }
    }

    private var hasCompletedEveningReflection: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return reflections.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    private var eveningReflectionPrompt: some View {
        Group {
            let hour = Calendar.current.component(.hour, from: Date())
            if hour >= 19 && !hasCompletedEveningReflection {
                Button {
                    showEveningReflection = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "moon.stars.fill")
                                .font(.title3)
                                .foregroundStyle(Color(red: 0.4, green: 0.5, blue: 0.9))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Evening Reflection")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Text("How was your day? Take a moment to reflect.")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.08), Theme.cardSurface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: .rect(cornerRadius: 16)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.15), lineWidth: 1)
                    )
                }
                .buttonStyle(PressableButtonStyle())
                .sensoryFeedback(.selection, trigger: showEveningReflection)
                .accessibilityLabel("Open evening reflection")
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)
                .animation(.spring(response: 0.5).delay(0.26), value: appeared)
            }
        }
    }

    private func sdtInsightCard(_ message: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(Theme.gold)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary.opacity(0.85))
                .lineSpacing(3)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Theme.gold.opacity(0.08), Theme.cardSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.gold.opacity(0.12), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.22), value: appeared)
    }

    private var moneySavedCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.accentGreen)
                Text("Money Saved")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }

            Text(profile?.totalSaved ?? 0, format: .currency(code: "USD"))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("by resisting impulse spending")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Theme.accentGreen.opacity(0.1), Theme.cardSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Theme.accentGreen.opacity(0.1), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.25), value: appeared)
    }

    private var coachShortcutCard: some View {
        Button {
            showCoach = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.teal.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundStyle(Theme.teal)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("MoneyMind Coach")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Talk through what you're feeling")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.4))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Theme.teal.opacity(0.08), Theme.cardSurface],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Theme.teal.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: showCoach)
        .accessibilityLabel("Open MoneyMind Coach")
        .accessibilityHint("Talk through what you're feeling with your AI wellness coach")
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.29), value: appeared)
    }

    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            QuickActionButton(icon: "star.fill", title: "Log a Win", color: Theme.accentGreen) {
                showLogWin = true
            }
            QuickActionButton(icon: "heart.text.clipboard", title: "Check In", color: Theme.teal) { }
            QuickActionButton(icon: "wind", title: "Breathe", color: Color(red: 0.4, green: 0.6, blue: 1.0)) { }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.3), value: appeared)
    }

    private var socialProofSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundStyle(Theme.teal)
                Text("Community")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
            }

            ForEach(characterVM.socialProofStats, id: \.0) { stat in
                SocialProofCard(icon: stat.0, message: stat.1)
            }

            Button {
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "hands.clap.fill")
                    Text("Celebrate Others")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(Theme.teal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.teal.opacity(0.1), in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Celebrate others in the community")
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.35), value: appeared)
    }

    private var dailyInsightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Theme.gold)
                Text("Daily Insight")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
            }

            Text("\"The urge to spend impulsively is like a wave — it rises, peaks, and falls. You don't have to act on it. Just ride it out.\"")
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary.opacity(0.75))
                .lineSpacing(4)

            Text("— Cognitive Behavioral Therapy")
                .font(.caption)
                .foregroundStyle(Theme.teal)
        }
        .padding(20)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Theme.cardSurface.opacity(0.5), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.4), value: appeared)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Theme.textPrimary.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(color.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(title)
    }
}

struct LogWinSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var amount: String = ""
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("What did you resist?")
                        .font(Theme.headingFont(.headline))
                        .foregroundStyle(.primary)

                    TextField("Amount saved", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                        .tint(Theme.accentGreen)

                    TextField("What was the temptation?", text: $note)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }

                Button {
                    if let value = Double(amount) {
                        let log = ImpulseLog(amount: value, note: note, resisted: true)
                        modelContext.insert(log)
                        if let profile = profiles.first {
                            profile.totalSaved += value
                        }
                    }
                    dismiss()
                } label: {
                    Text("Log Win")
                        .font(.headline)
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.accentGradient, in: .capsule)
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(amount.isEmpty)
                .sensoryFeedback(.success, trigger: amount)
            }
            .padding()
            .navigationTitle("Log a Win")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
