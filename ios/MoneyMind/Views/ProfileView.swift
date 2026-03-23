import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Query private var impulseLogs: [ImpulseLog]
    @Query private var checkIns: [DailyCheckIn]
    @Query(sort: \PGSIAssessment.date) private var pgsiAssessments: [PGSIAssessment]
    @Query private var referrals: [ReferralCode]
    @Query private var quizResults: [QuizResult]
    @Query private var badges: [Badge]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Environment(\.modelContext) private var modelContext
    @Environment(PremiumManager.self) private var premiumManager

    @State private var showPGSI = false
    @State private var showWeeklySummary = false
    @State private var showMoneyWrapped = false
    @State private var showAnnualWrapped = false
    @State private var showPaywall = false
    @State private var showRetakeQuiz = false
    @State private var showShareCharacter = false
    @State private var sectionAppeared: [Bool] = Array(repeating: false, count: 8)

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

    private var personality: MoneyPersonality {
        quizResults.first?.personality ?? .builder
    }

    private var showRecoveryContent: Bool {
        let path = profile?.userPath ?? .generalSaver
        return path == .gambling || path == .impulseShopper
    }

    private var totalSaved: Double {
        profile?.totalSaved ?? 0
    }

    private var bestStreak: Int {
        profile?.longestStreak ?? 0
    }

    private var totalWins: Int {
        impulseLogs.filter(\.resisted).count
    }

    private var xpProgress: Double {
        let xp = profile?.xpPoints ?? 0
        let lvl = CharacterStage.level(from: xp)
        let cur = CharacterStage.xpForLevel(lvl)
        let nxt = CharacterStage.xpForNextLevel(lvl)
        let range = nxt - cur
        guard range > 0 else { return 1.0 }
        return Double(xp - cur) / Double(range)
    }

    private var currentXP: Int {
        profile?.xpPoints ?? 0
    }

    private var nextLevelXP: Int {
        CharacterStage.xpForNextLevel(characterLevel)
    }

    private var earnedBadges: [Badge] {
        badges.filter(\.isEarned)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeroCard
                        .sectionFadeIn(index: 0, appeared: $sectionAppeared)
                    statsGrid
                        .sectionFadeIn(index: 1, appeared: $sectionAppeared)
                    journeySection
                        .sectionFadeIn(index: 2, appeared: $sectionAppeared)
                    shareCelebrateSection
                        .sectionFadeIn(index: 3, appeared: $sectionAppeared)
                    referralSection
                        .sectionFadeIn(index: 4, appeared: $sectionAppeared)

                    if showRecoveryContent {
                        recoverySection
                            .sectionFadeIn(index: 5, appeared: $sectionAppeared)
                    }

                    premiumSection
                        .sectionFadeIn(index: 6, appeared: $sectionAppeared)
                    settingsLink
                        .sectionFadeIn(index: 7, appeared: $sectionAppeared)
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                seedBadgesIfNeeded()
                staggerAppear()
            }
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
                if hasMonthlyData {
                    MoneyWrappedView(data: monthlyWrappedData)
                } else {
                    wrappedEmptyState
                }
            }
            .fullScreenCover(isPresented: $showAnnualWrapped) {
                MoneyWrappedView(data: annualWrappedData)
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showShareCharacter) {
                ShareCharacterCardView(
                    stage: characterStage,
                    level: characterLevel,
                    totalSaved: totalSaved,
                    streak: profile?.currentStreak ?? 0,
                    dayCount: dayCount
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Profile Hero Card

    private var profileHeroCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Text(profile?.name ?? "User")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                Text("·")
                    .foregroundStyle(Theme.textMuted)

                Text(personality.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.accent)

                Text("·")
                    .foregroundStyle(Theme.textMuted)

                Text("Lv. \(characterLevel)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.accent)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            HStack(spacing: 8) {
                ForEach(personality.traits, id: \.self) { trait in
                    Text(trait)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.accent.opacity(0.1), in: .capsule)
                }
            }

            Button {
                showRetakeQuiz = true
            } label: {
                Text("Retake Quiz")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)
            }

            if let startDate = profile?.startDate {
                Text("Member since \(startDate, format: .dateTime.month(.wide).year())")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .glassCard(cornerRadius: 20)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 12) {
            ProfileStatCard(
                value: "\(profile?.currentStreak ?? 0)",
                label: "Day Streak",
                icon: "flame.fill",
                color: Theme.accent
            )
            ProfileStatCard(
                value: profile?.totalSaved.formatted(.currency(code: profile?.defaultCurrency ?? "USD").precision(.fractionLength(0))) ?? "$0",
                label: "Total Saved",
                icon: "dollarsign.circle.fill",
                color: Theme.accent
            )
            ProfileStatCard(
                value: "\(impulseLogs.count)",
                label: "Wins Logged",
                icon: "star.fill",
                color: Theme.accent
            )
        }
    }

    // MARK: - My Journey (Gamified)

    private var journeySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .font(.subheadline)
                    .foregroundStyle(Theme.accent)
                Text("My Journey")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            characterLevelCard
            milestoneTimeline
            badgeCollectionPreview
            leaderboardLink
            shareCharacterButton
        }
    }

    private var characterLevelCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(personality.color.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .shadow(color: personality.color.opacity(0.3), radius: 12)

                Image(systemName: characterStage.bodyIcon)
                    .font(.system(size: 32))
                    .foregroundStyle(characterStage.primaryColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(characterStage.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Level \(characterLevel) \(personality.rawValue)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(personality.color)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.elevated)
                            .frame(height: 8)

                        Capsule()
                            .fill(personality.color)
                            .frame(width: geo.size.width * xpProgress, height: 8)
                            .shadow(color: personality.color.opacity(0.5), radius: 4)
                    }
                }
                .frame(height: 8)

                Text("\(currentXP)/\(nextLevelXP) XP")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .padding(20)
        .glassCard()
    }

    private var milestoneTimeline: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Milestones")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    MilestoneCard(
                        icon: "star.fill",
                        title: "First Save",
                        subtitle: "Logged your first win",
                        isCompleted: totalWins >= 1,
                        accentColor: Theme.accent
                    )
                    MilestoneCard(
                        icon: "flame.fill",
                        title: "7-Day Streak",
                        subtitle: "Saved 7 days in a row",
                        isCompleted: bestStreak >= 7,
                        accentColor: .orange
                    )
                    MilestoneCard(
                        icon: "dollarsign.circle.fill",
                        title: "$100 Club",
                        subtitle: "Total savings hit $100",
                        isCompleted: totalSaved >= 100,
                        accentColor: Theme.accent
                    )
                    MilestoneCard(
                        icon: "trophy.fill",
                        title: "$500 Saver",
                        subtitle: "Total savings hit $500",
                        isCompleted: totalSaved >= 500,
                        accentColor: Theme.gold
                    )
                    MilestoneCard(
                        icon: "crown.fill",
                        title: "$1,000 Legend",
                        subtitle: "Total savings hit $1,000",
                        isCompleted: totalSaved >= 1000,
                        accentColor: Theme.gold
                    )
                    MilestoneCard(
                        icon: "bolt.fill",
                        title: "30-Day Warrior",
                        subtitle: "30-day streak achieved",
                        isCompleted: bestStreak >= 30,
                        accentColor: .purple
                    )
                }
                .padding(.horizontal, 4)
            }
            .contentMargins(.horizontal, 0)
        }
    }

    private var badgeCollectionPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink(destination: BadgeGalleryView()) {
                HStack {
                    Text("Badges")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(earnedBadges.count)/\(badges.count)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textMuted)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(Array(badges.prefix(10)), id: \.name) { badge in
                    ZStack {
                        Circle()
                            .fill(badge.isEarned ? badgeColor(for: badge).opacity(0.15) : Theme.elevated)
                            .frame(width: 48, height: 48)
                            .shadow(color: badge.isEarned ? badgeColor(for: badge).opacity(0.3) : .clear, radius: 6)

                        Image(systemName: badge.iconName)
                            .font(.system(size: 18))
                            .foregroundStyle(badge.isEarned ? badgeColor(for: badge) : Theme.textMuted.opacity(0.3))
                    }
                }
            }
        }
        .padding(20)
        .glassCard()
    }

    private var leaderboardLink: some View {
        NavigationLink(destination: LeaderboardView()) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(Theme.neonGold)
                Text("Leaderboard")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(16)
            .background(Theme.elevated, in: .rect(cornerRadius: 12))
        }
    }

    private var shareCharacterButton: some View {
        Button {
            showShareCharacter = true
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(Theme.accent)
                Text("Share My Character Card")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(16)
            .background(Theme.elevated, in: .rect(cornerRadius: 12))
        }
        .sensoryFeedback(.impact(weight: .light), trigger: showShareCharacter)
    }

    // MARK: - Share & Celebrate

    private var shareCelebrateSection: some View {
        SettingsSectionCard(title: "Share & Celebrate", icon: "sparkles", iconColor: Theme.accent) {
            SettingsNavRow(icon: "calendar", title: "Weekly Summary", subtitle: "Share your 7-day highlights", color: Theme.accent) {
                showWeeklySummary = true
            }

            SettingsDividerLine()

            SettingsNavRow(icon: "sparkles", title: "Monthly Recap", subtitle: "Your month in 6 story cards", color: Theme.accent, badge: "NEW") {
                showMoneyWrapped = true
            }

            SettingsDividerLine()

            SettingsNavRow(icon: "gift.fill", title: "Splurj Wrapped", subtitle: "Your all-time journey in cards", color: Theme.accent) {
                showAnnualWrapped = true
            }

            SettingsDividerLine()

            achievementShareRow
        }
    }

    private var achievementShareRow: some View {
        HStack(spacing: 12) {
            ShareAchievementButton(
                type: .streak(days: profile?.currentStreak ?? 0),
                level: characterLevel,
                archetypeName: personality.rawValue,
                referralCode: profile?.referralCode ?? "SP-XXXXX",
                style: .pill
            )

            if totalSaved > 0 {
                ShareAchievementButton(
                    type: .saved(amount: totalSaved),
                    level: characterLevel,
                    archetypeName: personality.rawValue,
                    referralCode: profile?.referralCode ?? "SP-XXXXX",
                    style: .pill
                )
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Referral

    private var referralSection: some View {
        SettingsSectionCard(title: "Referral", icon: "person.badge.plus", iconColor: Theme.accent) {
            ProfileReferralInlineView(
                referralCode: profile?.referralCode ?? "SP-XXXXX",
                referralCount: referrals.count
            )
        }
    }

    // MARK: - Recovery Progress

    private var recoverySection: some View {
        SettingsSectionCard(title: "Recovery Progress", icon: "chart.line.downtrend.xyaxis", iconColor: Theme.accent) {
            SettingsNavRow(icon: "chart.line.downtrend.xyaxis", title: "Recovery Progress", subtitle: "PGSI assessments & trends", color: Theme.accent) {
                showPGSI = true
            }

            if !pgsiAssessments.isEmpty {
                PGSITrendChart(assessments: pgsiAssessments)
                    .padding(.top, 8)
            }

            pgsiPromptCard
        }
    }

    // MARK: - Premium

    private var premiumSection: some View {
        SettingsSectionCard(title: "Premium", icon: "crown.fill", iconColor: Theme.gold) {
            HStack(spacing: 14) {
                SettingsIconBadge(icon: "crown.fill", color: Theme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Premium")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                    Text(premiumStatusText)
                        .font(.caption)
                        .foregroundStyle(premiumStatusColor)
                }
                Spacer()
                if premiumManager.isPremium {
                    Text("PRO")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.goldGradient, in: .capsule)
                } else if premiumManager.isInTrial {
                    Text("TRIAL")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.accent, in: .capsule)
                }
            }

            if !premiumManager.hasFullAccess {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Text("Upgrade to Premium")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    // MARK: - Settings Link

    private var settingsLink: some View {
        NavigationLink {
            SettingsView()
        } label: {
            HStack {
                Image(systemName: "gearshape")
                    .foregroundStyle(Theme.textSecondary)
                Text("Settings")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(16)
            .background(Theme.elevated, in: .rect(cornerRadius: 12))
        }
    }

    // MARK: - Premium Helpers

    private var premiumStatusText: String {
        if premiumManager.isPremium {
            return "Premium Active"
        } else if premiumManager.isInTrial {
            let days = premiumManager.trialDaysRemaining
            return "3-Day Trial \u{2022} \(days) day\(days == 1 ? "" : "s") left"
        } else {
            return "Free Plan"
        }
    }

    private var premiumStatusColor: Color {
        if premiumManager.isPremium || premiumManager.isInTrial {
            return Theme.accent
        } else {
            return Theme.textSecondary
        }
    }

    // MARK: - PGSI Prompt

    private var pgsiPromptCard: some View {
        Group {
            let showPrompt: Bool = {
                guard showRecoveryContent else { return false }
                let day = Calendar.current.component(.day, from: Date())
                guard day <= 7 else { return false }
                let thisMonth = Calendar.current.startOfDay(for: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!)
                return !pgsiAssessments.contains { $0.date >= thisMonth }
            }()

            if showPrompt {
                Button {
                    showPGSI = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                            .font(.subheadline)
                            .foregroundStyle(Theme.accent)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Monthly Check-In")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Text("Track your recovery progress")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        Text("Optional")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.accent.opacity(0.1), in: .capsule)
                    }
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Badge Helpers

    private func badgeColor(for badge: Badge) -> Color {
        switch badge.category {
        case "Money": Theme.accentGreen
        case "Streak": .orange
        case "Skill": Theme.teal
        default: Theme.textSecondary
        }
    }

    private func seedBadgesIfNeeded() {
        guard badges.isEmpty else { return }
        for info in BadgeDefinition.all {
            let badge = Badge(name: info.name, category: info.category, badgeDescription: info.description, iconName: info.icon)
            modelContext.insert(badge)
        }
    }

    // MARK: - Wrapped Data

    private var hasMonthlyData: Bool {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return transactions.contains { $0.date >= monthAgo } || impulseLogs.contains { $0.date >= monthAgo }
    }

    private var wrappedEmptyState: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button { showMoneyWrapped = false } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial, in: .circle)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                PersonalityEmptyStateView(
                    personality: personality,
                    icon: "calendar.badge.clock",
                    secondaryIcon: "sparkles",
                    headline: "Your First Wrapped Is Coming",
                    subtext: "Keep tracking your spending this month\nand we'll create your story"
                )
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

    // MARK: - Helpers

    private func staggerAppear() {
        for i in sectionAppeared.indices {
            sectionAppeared[i] = true
        }
    }
}

// MARK: - Referral Inline View

private struct ProfileReferralInlineView: View {
    let referralCode: String
    let referralCount: Int
    @State private var copied = false

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                SettingsIconBadge(icon: "person.badge.plus", color: Theme.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Invite Friends")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                    Text(referralCode)
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                if referralCount > 0 {
                    Text("\(referralCount) invited")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.accent.opacity(0.12), in: .capsule)
                }
                Button {
                    UIPasteboard.general.string = referralCode
                    withAnimation(.spring(response: 0.3)) { copied = true }
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation { copied = false }
                    }
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc.fill")
                        .font(.caption)
                        .foregroundStyle(copied ? Theme.accent : Theme.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Theme.elevated, in: .circle)
                }
                .sensoryFeedback(.selection, trigger: copied)
            }
        }
    }
}

// MARK: - Profile Stat Card

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
        .glassCard(cornerRadius: 14)
    }
}

// MARK: - Stagger Animation Modifier

private struct SectionFadeInModifier: ViewModifier {
    let index: Int
    @Binding var appeared: [Bool]

    private var isVisible: Bool {
        index < appeared.count && appeared[index]
    }

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 16)
            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.08), value: isVisible)
    }
}

extension View {
    fileprivate func sectionFadeIn(index: Int, appeared: Binding<[Bool]>) -> some View {
        modifier(SectionFadeInModifier(index: index, appeared: appeared))
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
