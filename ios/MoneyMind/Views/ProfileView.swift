import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Query private var impulseLogs: [ImpulseLog]
    @Query private var checkIns: [DailyCheckIn]
    @Query(sort: \PGSIAssessment.date) private var pgsiAssessments: [PGSIAssessment]
    @Query private var referrals: [ReferralCode]
    @Query private var quizResults: [QuizResult]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var showPGSI = false
    @State private var showWeeklySummary = false
    @State private var showMoneyWrapped = false
    @State private var showAnnualWrapped = false

    private var profile: UserProfile? { profiles.first }

    private var dayCount: Int {
        guard let start = profile?.startDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
    }

    private var characterStage: CharacterStage {
        CharacterStage.from(xp: profile?.xpPoints ?? 0)
    }

    private var characterLevel: Int {
        CharacterStage.level(from: profile?.xpPoints ?? 0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    avatarSection
                    statsGrid
                    characterCardSection
                    ReferralSectionView(
                        referralCode: profile?.referralCode ?? "MM-XXXXX",
                        referralCount: referrals.count
                    )
                    PGSITrendChart(assessments: pgsiAssessments)
                    pgsiPromptCard
                    BadgeGalleryView()
                    sharingSection
                    goalsSection
                    preferencesSection
                    settingsSections
                    dangerZone
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showPGSI) {
                PGSIAssessmentView()
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showWeeklySummary) {
                WeeklySummarySheet(
                    totalSaved: weekSaved,
                    purchasesResisted: weekResisted,
                    streak: profile?.currentStreak ?? 0,
                    characterStage: characterStage,
                    level: characterLevel
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showMoneyWrapped) {
                MoneyWrappedView(data: monthlyWrappedData)
            }
            .fullScreenCover(isPresented: $showAnnualWrapped) {
                MoneyWrappedView(data: annualWrappedData)
            }
        }
    }

    private var weekSaved: Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return impulseLogs.filter { $0.resisted && $0.date >= weekAgo }.reduce(0) { $0 + $1.amount }
    }

    private var weekResisted: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return impulseLogs.filter { $0.resisted && $0.date >= weekAgo }.count
    }

    private var monthSaved: Double {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return impulseLogs.filter { $0.resisted && $0.date >= monthAgo }.reduce(0) { $0 + $1.amount }
    }

    private var monthResisted: Int {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return impulseLogs.filter { $0.resisted && $0.date >= monthAgo }.count
    }

    private var personality: MoneyPersonality {
        quizResults.first?.personality ?? .builder
    }

    private var monthlyWrappedData: WrappedData {
        let cal = Calendar.current
        let monthAgo = cal.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let twoMonthsAgo = cal.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        let monthTx = transactions.filter { $0.transactionType == .expense && $0.date >= monthAgo }
        let lastMonthTx = transactions.filter { $0.transactionType == .expense && $0.date >= twoMonthsAgo && $0.date < monthAgo }
        let monthSpent = monthTx.reduce(0) { $0 + $1.amount }
        let lastMonthSpent = lastMonthTx.reduce(0) { $0 + $1.amount }
        let catAmounts = buildCategoryBreakdown(from: monthTx)
        let moods = buildMoodBreakdown(from: monthTx)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return WrappedData(
            periodLabel: formatter.string(from: Date()),
            isAnnual: false,
            totalSpent: monthSpent,
            lastPeriodSpent: lastMonthSpent,
            totalSaved: monthSaved,
            savingsGoal: 1000,
            purchasesResisted: monthResisted,
            longestStreak: profile?.longestStreak ?? 0,
            currentStreak: profile?.currentStreak ?? 0,
            characterStage: characterStage,
            startStage: .seedling,
            level: characterLevel,
            personality: personality,
            categoryBreakdown: catAmounts,
            moodBreakdown: moods
        )
    }

    private var annualWrappedData: WrappedData {
        let expenseTx = transactions.filter { $0.transactionType == .expense }
        let catAmounts = buildCategoryBreakdown(from: expenseTx)
        let moods = buildMoodBreakdown(from: expenseTx)
        let totalSpent = expenseTx.reduce(0) { $0 + $1.amount }
        return WrappedData(
            periodLabel: String(Calendar.current.component(.year, from: Date())),
            isAnnual: true,
            totalSpent: totalSpent,
            lastPeriodSpent: 0,
            totalSaved: profile?.totalSaved ?? 0,
            savingsGoal: 5000,
            purchasesResisted: impulseLogs.filter(\.resisted).count,
            longestStreak: profile?.longestStreak ?? 0,
            currentStreak: profile?.currentStreak ?? 0,
            characterStage: characterStage,
            startStage: .seedling,
            level: characterLevel,
            personality: personality,
            categoryBreakdown: catAmounts,
            moodBreakdown: moods
        )
    }

    private func buildCategoryBreakdown(from txs: [Transaction]) -> [(category: String, amount: Double, color: String)] {
        var amounts: [String: Double] = [:]
        var colors: [String: String] = [:]
        for tx in txs {
            let cat = tx.transactionCategory
            amounts[cat.rawValue, default: 0] += tx.amount
            colors[cat.rawValue] = cat.color
        }
        return amounts.sorted { $0.value > $1.value }.map { (category: $0.key, amount: $0.value, color: colors[$0.key] ?? "6C5CE7") }
    }

    private func buildMoodBreakdown(from txs: [Transaction]) -> [(emoji: String, count: Int)] {
        var counts: [String: Int] = [:]
        for tx in txs where !tx.moodEmoji.isEmpty {
            counts[tx.moodEmoji, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }.map { (emoji: $0.key, count: $0.value) }
    }

    private var pgsiPromptCard: some View {
        Group {
            let showPrompt: Bool = {
                guard let reason = profile?.selectedReason, reason.lowercased().contains("gambl") else { return false }
                let day = Calendar.current.component(.day, from: Date())
                guard day <= 7 else { return false }
                let thisMonth = Calendar.current.startOfDay(for: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!)
                return !pgsiAssessments.contains { $0.date >= thisMonth }
            }()

            if showPrompt {
                Button {
                    showPGSI = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Theme.teal.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "chart.line.downtrend.xyaxis")
                                .font(.title3)
                                .foregroundStyle(Theme.teal)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Monthly Check-In")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Text("Track your recovery progress with the PGSI")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }

                        Spacer()

                        Text("Optional")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Theme.teal)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.teal.opacity(0.1), in: .capsule)
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Theme.teal.opacity(0.06), Theme.cardSurface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: .rect(cornerRadius: 16)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Theme.teal.opacity(0.12), lineWidth: 1)
                    )
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Take monthly PGSI assessment")
            }
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.accentGreen.opacity(0.2), Theme.cardSurface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Text(String(profile?.name.prefix(1) ?? "?"))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
            }

            Text(profile?.name ?? "User")
                .font(Theme.headingFont(.title2))
                .foregroundStyle(Theme.textPrimary)

            if let startDate = profile?.startDate {
                Text("Member since \(startDate, format: .dateTime.month(.wide).year())")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.top, 8)
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            ProfileStatCard(
                value: "\(profile?.currentStreak ?? 0)",
                label: "Day Streak",
                icon: "flame.fill",
                color: .orange
            )
            ProfileStatCard(
                value: profile?.totalSaved.formatted(.currency(code: "USD").precision(.fractionLength(0))) ?? "$0",
                label: "Total Saved",
                icon: "dollarsign.circle.fill",
                color: Theme.accentGreen
            )
            ProfileStatCard(
                value: "\(impulseLogs.count)",
                label: "Wins Logged",
                icon: "star.fill",
                color: Theme.gold
            )
        }
    }

    private var characterCardSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.crop.circle.badge.checkmark.fill")
                    .foregroundStyle(characterStage.primaryColor)
                Text("Your Companion")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("Level \(characterLevel)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(characterStage.primaryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(characterStage.primaryColor.opacity(0.12), in: .capsule)
            }

            HStack(spacing: 16) {
                CharacterView(stage: characterStage, reaction: .idle, level: characterLevel)
                    .scaleEffect(0.7)
                    .frame(width: 80, height: 80)

                VStack(alignment: .leading, spacing: 6) {
                    Text(characterStage.name)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)

                    Text("\(profile?.xpPoints ?? 0) XP")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)

                    XPProgressBar(
                        progress: {
                            let xp = profile?.xpPoints ?? 0
                            let lvl = CharacterStage.level(from: xp)
                            let cur = CharacterStage.xpForLevel(lvl)
                            let nxt = CharacterStage.xpForNextLevel(lvl)
                            let range = nxt - cur
                            guard range > 0 else { return 1.0 }
                            return Double(xp - cur) / Double(range)
                        }(),
                        level: characterLevel,
                        stage: characterStage,
                        currentXP: profile?.xpPoints ?? 0
                    )
                }
            }

            ShareCharacterButton(
                stage: characterStage,
                level: characterLevel,
                totalSaved: profile?.totalSaved ?? 0,
                streak: profile?.currentStreak ?? 0,
                dayCount: dayCount
            )
        }
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(characterStage.primaryColor.opacity(0.12), lineWidth: 1)
        )
    }

    private var sharingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "square.and.arrow.up.fill")
                    .foregroundStyle(Theme.accentGreen)
                Text("Share & Celebrate")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
            }

            Button {
                showWeeklySummary = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Theme.teal.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(Theme.teal)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weekly Summary")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Share your 7-day highlights")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                showMoneyWrapped = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Theme.accentGreen.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: "sparkles")
                            .font(.subheadline)
                            .foregroundStyle(Theme.accentGreen)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monthly Recap")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Your month in 6 story cards")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Text("NEW")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(Theme.accentGreen)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Theme.accentGreen.opacity(0.12), in: .capsule)
                }
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                showAnnualWrapped = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Theme.gold.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: "gift.fill")
                            .font(.subheadline)
                            .foregroundStyle(Theme.gold)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Money Wrapped")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Your all-time journey in cards")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(20)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Theme.accentGreen.opacity(0.1), lineWidth: 1)
        )
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Goals")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            if let goals = profile?.selectedGoals, !goals.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(goals, id: \.self) { goal in
                            Text(goal)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Theme.accentGreen)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Theme.accentGreen.opacity(0.12), in: .capsule)
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
                .scrollIndicators(.hidden)
            } else {
                Text("No goals set yet")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            if let profile {
                VStack(spacing: 12) {
                    PreferenceToggle(
                        icon: "eye.slash.fill",
                        title: "Gentle View Mode",
                        subtitle: "Hide exact dollar amounts",
                        isOn: Binding(
                            get: { profile.gentleViewMode },
                            set: { profile.gentleViewMode = $0 }
                        ),
                        color: Theme.teal
                    )
                    PreferenceToggle(
                        icon: "figure.stand",
                        title: "Simple Mode",
                        subtitle: "Hide character, show minimal stats",
                        isOn: Binding(
                            get: { profile.simpleMode },
                            set: { profile.simpleMode = $0 }
                        ),
                        color: Color(red: 0.4, green: 0.6, blue: 1.0)
                    )
                    PreferenceToggle(
                        icon: "circle.hexagongrid.fill",
                        title: "ADHD Mode",
                        subtitle: "Simplified interactions, fewer choices",
                        isOn: Binding(
                            get: { profile.adhdMode },
                            set: { profile.adhdMode = $0 }
                        ),
                        color: Theme.accentGreen
                    )
                    PreferenceToggle(
                        icon: "sun.max.fill",
                        title: "High Contrast",
                        subtitle: "Increase text and icon contrast",
                        isOn: Binding(
                            get: { profile.highContrastMode },
                            set: { profile.highContrastMode = $0 }
                        ),
                        color: Theme.gold
                    )
                }
            }
        }
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
    }

    private var settingsSections: some View {
        VStack(spacing: 2) {
            NavigationLink(destination: NotificationSettingsView()) {
                ProfileSettingsRowLabel(icon: "bell.fill", title: "Notifications", color: Theme.emergency)
            }
            .buttonStyle(PressableButtonStyle())
            ProfileSettingsRow(icon: "lock.fill", title: "Privacy", color: .blue)
            ProfileSettingsRow(icon: "square.and.arrow.up.fill", title: "Export Data", color: Theme.accentGreen)
            ProfileSettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .orange)
            ProfileSettingsRow(icon: "info.circle.fill", title: "About MoneyMind", color: Theme.textSecondary)
        }
        .clipShape(.rect(cornerRadius: 16))
    }

    private var dangerZone: some View {
        VStack(spacing: 12) {
            Button(role: .destructive) { } label: {
                Text("Delete All Data")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding(.top, 8)
    }
}

private struct ProfileStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 14))
    }
}

private struct PreferenceToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .tint(Theme.accentGreen)
        .sensoryFeedback(.selection, trigger: isOn)
        .accessibilityLabel("\(title): \(subtitle)")
    }
}

private struct ProfileSettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button { } label: {
            ProfileSettingsRowLabel(icon: icon, title: title, color: color)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(title)
    }
}

struct ProfileSettingsRowLabel: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(color, in: .rect(cornerRadius: 8))

            Text(title)
                .font(.body)
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.textSecondary.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.cardSurface)
    }
}
