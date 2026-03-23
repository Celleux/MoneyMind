import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \ImpulseLog.date, order: .reverse) private var impulseLogs: [ImpulseLog]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var budgets: [BudgetCategory]
    @Query private var quizResults: [QuizResult]
    @Query(filter: #Predicate<InAppNotification> { !$0.isDismissed && !$0.isRead }) private var unreadNotifications: [InAppNotification]
    @Query(filter: #Predicate<ScratchCard> { $0.scratchedAt == nil }) private var pendingScratchCards: [ScratchCard]
    @State private var showLogWin = false
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var showCoach = false
    @State private var showNotificationCenter = false
    @State private var appeared = false
    @State private var bellBounce = 0
    @State private var characterVM = CharacterViewModel()
    @State private var selectedBudget: BudgetCategory?
    @State private var selectedBudgetSpent: Double = 0
    @State private var showBudgetAnalytics = false
    @State private var isLoading = true
    @State private var refreshRotation: Double = 0
    @State private var deepLinkDestination: NotificationDeepLink?
    @Environment(\.modelContext) private var modelContext
    @Environment(PremiumManager.self) private var premiumManager
    @State private var showPaywall = false
    @State private var splurjiEngine = SplurjiMoodEngine()
    @State private var showSplurjiBubble = false

    private var profile: UserProfile? { profiles.first }
    private var currencyCode: String { profile?.defaultCurrency ?? "USD" }
    private var currencySymbol: String { CurrencyHelper.symbol(for: currencyCode) }

    private var personality: MoneyPersonality {
        quizResults.first?.personality ?? .builder
    }

    private var characterLevel: Int {
        CharacterStage.level(from: profile?.xpPoints ?? 0)
    }

    private var totalSavedThisMonth: Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let monthLogs = impulseLogs.filter { $0.date >= startOfMonth }
        return monthLogs.reduce(0) { $0 + $1.amount }
    }

    private var totalSavedLastMonth: Double {
        let calendar = Calendar.current
        let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfThisMonth)!
        let lastMonthLogs = impulseLogs.filter { $0.date >= startOfLastMonth && $0.date < startOfThisMonth }
        return lastMonthLogs.reduce(0) { $0 + $1.amount }
    }

    private var savedDifference: Double {
        totalSavedThisMonth - totalSavedLastMonth
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
            .prefix(3)
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

    private var hasEnoughDataForWrapped: Bool {
        guard let start = profile?.startDate else { return false }
        let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return days >= 7
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
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
            .coordinateSpace(name: "homeScroll")
            .scrollIndicators(.hidden)
            .refreshable {
                withAnimation(.linear(duration: 0.6)) {
                    refreshRotation += 360
                }
                try? await Task.sleep(for: .seconds(0.5))
            }
            .sensoryFeedback(.impact(weight: .light), trigger: refreshRotation)
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
            .fullScreenCover(isPresented: $showCoach) {
                CoachChatView()
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
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
                } else if value == "vaultGame" {
                    VaultGameView()
                } else if value == "questHub" {
                    QuestHubView()
                }
            }
            .onAppear {
                if let profile {
                    premiumManager.updateInstallDate(profile.installDate)
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
                splurjiEngine.setContext(.home)
                splurjiEngine.update(
                    streakDays: profile?.currentStreak ?? 0,
                    questCompletedRecently: false,
                    leveledUpRecently: false,
                    streakJustBroken: false
                )
                splurjiEngine.showGreetingIfNeeded()
                if splurjiEngine.shouldShowSpeechBubble {
                    showSplurjiBubble = true
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(4))
                        withAnimation { showSplurjiBubble = false }
                    }
                }
                ensureDefaultBudgets()
                Task {
                    try? await Task.sleep(for: .seconds(0.4))
                    withAnimation(Theme.springSnappy) {
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

    private var trialBanner: some View {
        Group {
            if premiumManager.shouldShowTrialBanner {
                Button {
                    showPaywall = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.accent)

                        let days = premiumManager.trialDaysRemaining
                        Text("Your free trial ends in \(days) day\(days == 1 ? "" : "s")")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)

                        Spacer()

                        Text("See Plans")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.accent)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .glassCard(cornerRadius: 12)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var pendingScratchCardsPrompt: some View {
        Group {
            if !pendingScratchCards.isEmpty {
                NavigationLink(value: "vaultGame") {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                        Text("\(pendingScratchCards.count) card\(pendingScratchCards.count == 1 ? "" : "s") to scratch")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.textMuted)
                    }
                    .padding(14)
                    .glassCard(cornerRadius: 12)
                }
                .buttonStyle(.plain)
                .staggerIn(appeared: appeared, delay: 0.08)
            }
        }
    }

    private var dashboardContent: some View {
        VStack(spacing: 20) {
            trialBanner
            greetingHeader
            pendingScratchCardsPrompt
            QuestOfTheDayCard()
                .staggerIn(appeared: appeared, delay: 0.06)
            heroSavedCard
            quickActionsGrid
            budgetBarsSection
            spendingTimeline
            recentTransactionsSection
            DailyPledgeCard()
                .staggerIn(appeared: appeared, delay: 0.42)
        }
        .padding(.horizontal)
        .padding(.bottom, 80)
        .onAppear {
            withAnimation(Theme.springStagger) {
                appeared = true
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 0) {
            greetingHeader
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

    // MARK: - Greeting Header

    private var mascotMood: SplurjiMood {
        if !impulseLogs.isEmpty, let latest = impulseLogs.first, Calendar.current.isDateInToday(latest.date) {
            return .celebrating
        }
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 6 { return .sleeping }
        if !transactions.isEmpty { return .happy }
        return .idle
    }

    private var greetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(greetingText), \(profile?.name ?? "Friend")")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                HStack(spacing: 6) {
                    Image(systemName: personality.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.accent)
                    Text("\(personality.rawValue)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                    Text("•")
                        .foregroundStyle(Theme.textMuted)
                    Text("Level \(characterLevel)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            Spacer()

            VStack(spacing: 2) {
                if showSplurjiBubble {
                    SpeechBubble(message: splurjiEngine.moodMessage) {
                        showSplurjiBubble = false
                        splurjiEngine.dismissBubble()
                    }
                    .frame(maxWidth: 180)
                    .transition(.scale.combined(with: .opacity))
                }
                SplurjiCharacterView(mood: mascotMood, size: 50)
                    .onTapGesture {
                        splurjiEngine.setContext(.home)
                        splurjiEngine.showRandomMessage()
                        showSplurjiBubble = true
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(4))
                            withAnimation { showSplurjiBubble = false }
                        }
                    }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSplurjiBubble)

            Button {
                bellBounce += 1
                showNotificationCenter = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(Theme.elevated)
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
        }
        .padding(.top, 12)
        .staggerIn(appeared: appeared, delay: 0.0)
    }

    // MARK: - Hero Saved Card

    private var heroSavedCard: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .named("homeScroll")).minY
            let parallax = minY * 0.2

            VStack(spacing: 10) {
                Text("Total Saved This Month")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)

                MMAmountDisplay(amount: totalSavedThisMonth, font: Theme.amountXL, color: Theme.accent)

                HStack(spacing: 4) {
                    Image(systemName: savedDifference >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 11, weight: .bold))
                    Text("\(currencySymbol)\(abs(savedDifference), specifier: "%.0f") from last month")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .contentTransition(.numericText())
                }
                .foregroundStyle(savedDifference >= 0 ? Theme.accent : Theme.danger)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .glassCard(cornerRadius: 20)
            .offset(y: parallax)
        }
        .frame(height: 140)
        .staggerIn(appeared: appeared, delay: 0.05)
    }

    // MARK: - Quick Actions 2×2 Grid

    private var quickActionsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            HomeQuickAction(icon: "star.fill", label: "Log Save") {
                showLogWin = true
            }
            NavigationLink(value: "budgetAnalytics") {
                HomeQuickActionLabel(icon: "chart.bar.fill", label: "Budget Check")
            }
            .buttonStyle(PressableButtonStyle())

            if hasEnoughDataForWrapped {
                NavigationLink(value: "wrapped") {
                    HomeQuickActionLabel(icon: "chart.pie.fill", label: "Wrapped")
                }
                .buttonStyle(PressableButtonStyle())
            } else {
                HomeQuickAction(icon: "arrow.down.circle.fill", label: "Expense") {
                    showAddExpense = true
                }
            }

            HomeQuickAction(icon: "brain.head.profile", label: "Coach") {
                showCoach = true
            }
        }
        .staggerIn(appeared: appeared, delay: 0.1)
    }

    // MARK: - Budget Bars

    private var budgetBarsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Budgets")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()

                NavigationLink(value: "budgetAnalytics") {
                    Text("See All")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.accent)
                }
            }

            if budgets.isEmpty {
                HStack {
                    Spacer()
                    Text("No budgets set up yet")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textMuted)
                    Spacer()
                }
                .padding(.vertical, 12)
            } else {
                VStack(spacing: 16) {
                    ForEach(budgets.prefix(3)) { budget in
                        let spent = spentForBudget(budget)
                        let progress = budget.monthlyLimit > 0 ? min(spent / budget.monthlyLimit, 1.0) : 0

                        Button {
                            selectedBudgetSpent = spent
                            selectedBudget = budget
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: budget.icon)
                                        .font(.system(size: 14))
                                        .foregroundStyle(Theme.accent)
                                    Text(budget.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Theme.textPrimary)
                                    Spacer()
                                    Text("\(currencySymbol)\(Int(spent)) / \(currencySymbol)\(Int(budget.monthlyLimit))")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(Theme.textSecondary)
                                }

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Theme.border)
                                            .frame(height: 6)

                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(progress > 0.9 ? Theme.warning : Theme.accent)
                                            .frame(width: geo.size.width * progress, height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }
                        }
                        .buttonStyle(.plain)
                        .sensoryFeedback(.impact(weight: .light), trigger: selectedBudget)
                    }
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
            currentDayIndex: currentDay,
            currencySymbol: currencySymbol
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
                .fill(Theme.accent.opacity(0.15))
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
                            .foregroundStyle(Theme.accent)
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

            Text(item.isIncome ? "+\(currencySymbol)\(item.amount, specifier: "%.0f")" :
                    item.isResisted ? "Saved \(currencySymbol)\(item.amount, specifier: "%.0f")" :
                    "-\(currencySymbol)\(item.amount, specifier: "%.0f")")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    item.isIncome ? Theme.accent :
                        item.isResisted ? Theme.accent :
                        Theme.textPrimary
                )
        }
        .padding(.vertical, 10)
    }

    // MARK: - Helpers

    private func spentForBudget(_ budget: BudgetCategory) -> Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let budgetName = budget.name.lowercased()
        return transactions
            .filter {
                $0.transactionType == .expense &&
                ($0.category.lowercased() == budgetName || $0.transactionCategory.resolvedCategory.rawValue.lowercased() == budgetName) &&
                $0.date >= startOfMonth
            }
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
            break
        case .ghostBudget:
            break
        case .eveningReflection:
            break
        case .home, .none, .recurringExpenses, .profile:
            break
        }
    }
}

// MARK: - Home Quick Action Button

struct HomeQuickAction: View {
    let icon: String
    let label: String
    let action: () -> Void

    @State private var hapticTrigger = false

    var body: some View {
        Button {
            hapticTrigger.toggle()
            action()
        } label: {
            HomeQuickActionLabel(icon: icon, label: label)
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: hapticTrigger)
    }
}

struct HomeQuickActionLabel: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.accent)
            }
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
        }
        .padding(14)
        .glassCard(cornerRadius: 14)
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
            .offset(y: appeared ? 0 : 16)
            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(delay), value: appeared)
    }
}

// MARK: - LogWinSheet

struct LogWinSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var gachaStates: [GachaState]
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var scratchCardToast: ScratchCardToastData?

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
                        .tint(Theme.accent)

                    TextField("What was the temptation?", text: $note)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }

                Button {
                    guard let value = Double(amount), value > 0 else { return }
                    let log = ImpulseLog(amount: value, note: note, resisted: true)
                    modelContext.insert(log)
                    if let profile = profiles.first {
                        profile.totalSaved += value
                    }

                    let engine = GachaEngine()
                    if let state = gachaStates.first {
                        engine.syncFromState(state)
                    }
                    let currency = profiles.first?.defaultCurrency ?? "USD"
                    if let result = ScratchCardService.earnScratchCard(
                        resistedAmount: value,
                        currency: currency,
                        engine: engine,
                        gachaState: gachaStates.first,
                        modelContext: modelContext
                    ) {
                        scratchCardToast = ScratchCardToastData(isGlowing: result.isGlowing)
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
            .overlay(alignment: .top) {
                if let toast = scratchCardToast {
                    ScratchCardToast(data: toast) {
                        withAnimation { scratchCardToast = nil }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
                }
            }
        }
    }
}
