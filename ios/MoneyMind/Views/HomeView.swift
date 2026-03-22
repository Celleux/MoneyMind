import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \ImpulseLog.date, order: .reverse) private var impulseLogs: [ImpulseLog]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var budgets: [BudgetCategory]
    @Query private var quizResults: [QuizResult]
    @Query(filter: #Predicate<InAppNotification> { !$0.isDismissed && !$0.isRead }) private var unreadNotifications: [InAppNotification]
    @State private var showLogWin = false
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var showCoach = false
    @State private var showUrgeSurf = false
    @State private var showChallengesHub = false
    @State private var showNotificationCenter = false
    @State private var appeared = false
    @State private var streakBounce = 0
    @State private var bellBounce = 0
    @State private var characterVM = CharacterViewModel()
    @State private var selectedBudget: BudgetCategory?
    @State private var selectedBudgetSpent: Double = 0
    @State private var showBudgetAnalytics = false
    @State private var isLoading = true
    @State private var refreshRotation: Double = 0
    @State private var deepLinkDestination: NotificationDeepLink?
    @Environment(\.modelContext) private var modelContext

    private var profile: UserProfile? { profiles.first }

    private var personality: MoneyPersonality {
        quizResults.first?.personality ?? .builder
    }

    private var totalBalance: Double {
        let income = transactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
        let expenses = transactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }
        let saved = profile?.totalSaved ?? 0
        return income - expenses + saved
    }

    private var lastWeekBalance: Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let oldTransactions = transactions.filter { $0.date < weekAgo }
        let income = oldTransactions.filter { $0.transactionType == .income }.reduce(0) { $0 + $1.amount }
        let expenses = oldTransactions.filter { $0.transactionType == .expense }.reduce(0) { $0 + $1.amount }
        return income - expenses + (profile?.totalSaved ?? 0)
    }

    private var trendPercentage: Double {
        guard lastWeekBalance != 0 else { return 0 }
        return ((totalBalance - lastWeekBalance) / abs(lastWeekBalance)) * 100
    }

    private var recentItems: [DashboardTransaction] {
        let expenseItems = transactions.prefix(10).map { t in
            DashboardTransaction(
                id: t.persistentModelID.hashValue,
                name: t.note.isEmpty ? t.transactionCategory.rawValue : t.note,
                amount: t.amount,
                isIncome: t.transactionType == .income,
                category: t.transactionCategory,
                date: t.date,
                moodEmoji: t.moodEmoji
            )
        }

        let resistedItems = impulseLogs.prefix(5).map { log in
            DashboardTransaction(
                id: log.persistentModelID.hashValue,
                name: log.note.isEmpty ? "Resisted purchase" : log.note,
                amount: log.amount,
                isIncome: false,
                category: .savings,
                date: log.date,
                moodEmoji: "",
                isResisted: true
            )
        }

        return (expenseItems + resistedItems)
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }

    private var weeklySpending: ([Double], [String], Int) {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = (weekday == 1) ? -6 : (2 - weekday)
        let monday = calendar.date(byAdding: .day, value: mondayOffset, to: calendar.startOfDay(for: today))!

        var amounts: [Double] = Array(repeating: 0, count: 7)
        let labels = ["M", "T", "W", "T", "F", "S", "S"]

        let weekExpenses = transactions.filter {
            $0.transactionType == .expense && $0.date >= monday
        }

        for expense in weekExpenses {
            let dayDiff = calendar.dateComponents([.day], from: monday, to: expense.date).day ?? 0
            if dayDiff >= 0 && dayDiff < 7 {
                amounts[dayDiff] += expense.amount
            }
        }

        let currentIndex = calendar.dateComponents([.day], from: monday, to: today).day ?? 0
        return (amounts, labels, min(currentIndex, 6))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    DashboardSkeletonView()
                        .padding(.horizontal)
                        .transition(.opacity)
                } else if transactions.isEmpty && impulseLogs.isEmpty {
                    emptyState
                } else {
                    dashboardContent
                }
            }
            .scrollIndicators(.hidden)
            .refreshable {
                withAnimation(.linear(duration: 0.6)) {
                    refreshRotation += 360
                }
                try? await Task.sleep(for: .seconds(0.5))
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showLogWin) {
                LogWinSheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedBudget) { budget in
                BudgetDetailSheet(budget: budget, spent: selectedBudgetSpent)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showUrgeSurf) {
                UrgeSurfView()
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showCoach) {
                CoachChatView()
            }
            .fullScreenCover(isPresented: $showChallengesHub) {
                ChallengesHubView()
            }
            .sheet(isPresented: $showNotificationCenter) {
                NotificationCenterView { link in
                    handleDeepLink(link)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationBackground(Theme.background)
            }
            .navigationDestination(for: String.self) { value in
                if value == "budgetAnalytics" {
                    BudgetAnalyticsView()
                } else if value == "ghostBudget" {
                    GhostBudgetView()
                } else if value == "vibeCheck" {
                    VibeCheckAnalyticsView()
                }
            }
            .onAppear {
                if let profile {
                    characterVM.syncFromProfile(profile)
                    profile.lastOpenDate = Date()
                    NotificationService.shared.scheduleAllNotifications(profile: profile)
                    NotificationService.shared.checkBudgetThresholds(
                        budgets: Array(budgets),
                        transactions: Array(transactions),
                        profile: profile,
                        modelContext: modelContext
                    )
                    if profile.currentStreak > 0 {
                        NotificationService.shared.celebrateStreak(
                            days: profile.currentStreak,
                            profile: profile,
                            modelContext: modelContext
                        )
                    }
                }
                ensureDefaultBudgets()
                Task {
                    try? await Task.sleep(for: .seconds(0.4))
                    withAnimation(.easeOut(duration: 0.3)) {
                        isLoading = false
                    }
                }
            }
            .onChange(of: profile?.xpPoints) { _, _ in
                if let profile {
                    characterVM.syncFromProfile(profile)
                }
            }
        }
    }

    // MARK: - Dashboard Content

    private var dashboardContent: some View {
        VStack(spacing: 20) {
            topBar
            heroBalance
            quickActionsRow
            budgetRingsSection
            spendingTimeline
            recentTransactionsSection
            streakCard
            DailyPledgeCard()
                .staggerIn(appeared: appeared, delay: 0.42)
            vibeCheckCard
            ghostBudgetCard
            challengesCard
            coachShortcutCard
            dailyInsightCard
        }
        .padding(.horizontal)
        .padding(.bottom, 80)
        .onAppear {
            withAnimation(.easeOut(duration: 0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal)

            PersonalityEmptyStateView(
                personality: personality,
                icon: "rocket.fill",
                secondaryIcon: "sparkles",
                headline: "Start Your Journey",
                subtext: "Add your first transaction or log a win\nto see your dashboard come alive",
                buttonLabel: "Add Your First Transaction",
                buttonIcon: "arrow.down.circle.fill"
            ) {
                showAddExpense = true
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Text("Splurj")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Button {
                bellBounce += 1
                showNotificationCenter = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(Theme.card)
                            .frame(width: 36, height: 36)
                        Image(systemName: "bell.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .symbolEffect(.bounce, value: bellBounce)
                    }

                    if !unreadNotifications.isEmpty {
                        Text("\(min(unreadNotifications.count, 99))")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Theme.danger, in: .capsule)
                            .offset(x: 4, y: -4)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .light), trigger: bellBounce)

            ZStack {
                Circle()
                    .fill(personality.color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: personality.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(personality.color)
            }
        }
        .padding(.top, 12)
        .staggerIn(appeared: appeared, delay: 0.0)
    }

    // MARK: - Hero Balance

    private var heroBalance: some View {
        VStack(spacing: 8) {
            Text("Total Balance")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Theme.textMuted)

            ZStack {
                Circle()
                    .fill(personality.color.opacity(0.05))
                    .frame(width: 220, height: 220)
                    .blur(radius: 40)

                VStack(spacing: 6) {
                    MMAmountDisplay(amount: totalBalance, font: Theme.amountXL)

                    HStack(spacing: 4) {
                        Image(systemName: trendPercentage >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12, weight: .bold))
                        Text("\(abs(trendPercentage), specifier: "%.1f")%")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(trendPercentage >= 0 ? Theme.accentGreen : Theme.danger)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .staggerIn(appeared: appeared, delay: 0.05)
    }

    // MARK: - Quick Actions

    private var quickActionsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                DashboardQuickAction(icon: "star.fill", label: "Log a Win", color: Theme.accentGreen) {
                    showLogWin = true
                }
                DashboardQuickAction(icon: "arrow.down.circle.fill", label: "Expense", color: Theme.danger) {
                    showAddExpense = true
                }
                DashboardQuickAction(icon: "wind", label: "Breathe", color: Color(hex: 0x6699FF)) {
                    showUrgeSurf = true
                }
                DashboardQuickAction(icon: "brain.head.profile", label: "Coach", color: Theme.teal) {
                    showCoach = true
                }
            }
            .padding(.horizontal, 4)
        }
        .contentMargins(.horizontal, 0)
        .staggerIn(appeared: appeared, delay: 0.1)
    }

    // MARK: - Budget Rings

    private var budgetRingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Budgets")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()

                NavigationLink(value: "budgetAnalytics") {
                    Text("See All")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.secondary)
                }
            }

            HStack(spacing: 0) {
                ForEach(budgets.prefix(3)) { budget in
                    let spent = spentForBudget(budget)
                    let progress = budget.monthlyLimit > 0 ? spent / budget.monthlyLimit : 0

                    Button {
                        selectedBudgetSpent = spent
                        selectedBudget = budget
                    } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                MMProgressRing(progress: min(progress, 1.0), lineWidth: 6, size: 64)

                                Image(systemName: budget.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color(hex: UInt(budget.colorHex, radix: 16) ?? 0x6C5CE7))
                            }

                            Text(budget.name)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.textPrimary)

                            Text("\(Int(spent))/\(Int(budget.monthlyLimit))")
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundStyle(Theme.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 20)
        .staggerIn(appeared: appeared, delay: 0.18)
    }

    // MARK: - Spending Timeline

    private var spendingTimeline: some View {
        let (amounts, labels, currentDay) = weeklySpending
        return SpendingTimelineChart(
            dailyAmounts: amounts,
            dayLabels: labels,
            currentDayIndex: currentDay
        )
        .staggerIn(appeared: appeared, delay: 0.24)
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("See All")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.secondary)
            }

            if recentItems.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.title2)
                            .foregroundStyle(Theme.textMuted)
                        Text("No transactions yet")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                VStack(spacing: 2) {
                    ForEach(recentItems) { item in
                        transactionRow(item)
                    }
                }
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 20)
        .staggerIn(appeared: appeared, delay: 0.30)
    }

    private func transactionRow(_ item: DashboardTransaction) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: UInt(item.category.color, radix: 16) ?? 0x64748B))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    if item.isResisted {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.accentGreen)
                    }
                    if !item.moodEmoji.isEmpty {
                        Text(item.moodEmoji)
                            .font(.system(size: 12))
                    }
                }
                Text(item.date, format: .dateTime.hour().minute())
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textMuted)
            }

            Spacer()

            Text(item.isIncome ? "+$\(item.amount, specifier: "%.0f")" :
                    item.isResisted ? "Saved $\(item.amount, specifier: "%.0f")" :
                    "-$\(item.amount, specifier: "%.0f")")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    item.isIncome ? Theme.accentGreen :
                        item.isResisted ? Theme.teal :
                        Theme.textPrimary
                )
        }
        .padding(.vertical, 10)
    }

    // MARK: - Streak Card

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
        .glassCard(cornerRadius: 20)
        .staggerIn(appeared: appeared, delay: 0.36)
    }

    // MARK: - Vibe Check Card

    private var vibeCheckCard: some View {
        NavigationLink(value: "vibeCheck") {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.gold.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Text("\u{1F60E}")
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Vibe Check")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Your spending moods & insights")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.4))
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(PressableButtonStyle())
        .staggerIn(appeared: appeared, delay: 0.42)
    }

    // MARK: - Ghost Budget Card

    private var ghostBudgetCard: some View {
        NavigationLink(value: "ghostBudget") {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.success.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Text("\u{1F47B}")
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Ghost Budget")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Label("PRO", systemImage: "crown.fill")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.gold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.gold.opacity(0.12), in: .capsule)
                    }
                    Text("What if you changed your habits?")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.4))
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(PressableButtonStyle())
        .staggerIn(appeared: appeared, delay: 0.43)
    }

    // MARK: - Challenges Card

    private var challengesCard: some View {
        Button {
            showChallengesHub = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.accent.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: "trophy.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Money Challenges")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Gamified savings goals & streaks")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.4))
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: showChallengesHub)
        .staggerIn(appeared: appeared, delay: 0.45)
    }

    // MARK: - Coach Shortcut

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
                    Text("Splurj Coach")
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
            .glassCard()
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: showCoach)
        .staggerIn(appeared: appeared, delay: 0.48)
    }

    // MARK: - Daily Insight

    private let insights: [(String, String)] = [
        ("The urge to spend impulsively is like a wave — it rises, peaks, and falls. You don't have to act on it.", "Cognitive Behavioral Therapy"),
        ("Between stimulus and response there is a space. In that space lies our freedom and power to choose.", "Viktor Frankl"),
        ("It's not about perfect control — it's about conscious choices, one at a time.", "Mindful Spending"),
        ("Every dollar you don't spend impulsively is a vote for the person you want to become.", "Financial Wellness"),
        ("The feeling will pass. It always does. Your future self will thank you for waiting.", "Urge Surfing"),
    ]

    private var todayInsight: (String, String) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return insights[dayOfYear % insights.count]
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

            Text("\"\(todayInsight.0)\"")
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary.opacity(0.75))
                .lineSpacing(4)

            Text("— \(todayInsight.1)")
                .font(.caption)
                .foregroundStyle(Theme.teal)
        }
        .padding(20)
        .glassCard(cornerRadius: 20)
        .staggerIn(appeared: appeared, delay: 0.54)
    }

    // MARK: - Helpers

    private func spentForBudget(_ budget: BudgetCategory) -> Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        return transactions
            .filter { $0.transactionType == .expense && $0.category == budget.name && $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }

    private func ensureDefaultBudgets() {
        guard budgets.isEmpty else { return }
        for (i, def) in BudgetCategory.defaults.enumerated() {
            let budget = BudgetCategory(
                name: def.0,
                icon: def.1,
                colorHex: def.2,
                monthlyLimit: def.3,
                sortOrder: i
            )
            modelContext.insert(budget)
        }
    }

    private func handleDeepLink(_ link: NotificationDeepLink) {
        switch link {
        case .budgetAnalytics:
            showBudgetAnalytics = true
        case .wallet:
            break
        case .challenges:
            showChallengesHub = true
        case .ghostBudget:
            break
        case .eveningReflection:
            break
        case .home, .none, .recurringExpenses, .profile:
            break
        }
    }
}

// MARK: - Dashboard Quick Action Button

struct DashboardQuickAction: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    @State private var hapticTrigger = false

    var body: some View {
        Button {
            hapticTrigger.toggle()
            action()
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial.opacity(0.3))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 3)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.textPrimary.opacity(0.8))
            }
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: hapticTrigger)
    }
}

// MARK: - Dashboard Transaction Model

struct DashboardTransaction: Identifiable {
    let id: Int
    let name: String
    let amount: Double
    let isIncome: Bool
    let category: TransactionCategory
    let date: Date
    let moodEmoji: String
    var isResisted: Bool = false
}

// MARK: - Stagger Animation Modifier

extension View {
    func staggerIn(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 15)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: appeared)
    }
}

// MARK: - LogWinSheet (kept)

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
