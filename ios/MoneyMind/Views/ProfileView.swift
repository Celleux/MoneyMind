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
    @Environment(\.modelContext) private var modelContext
    @Environment(PremiumManager.self) private var premiumManager

    @State private var showPGSI = false
    @State private var showWeeklySummary = false
    @State private var showMoneyWrapped = false
    @State private var showAnnualWrapped = false
    @State private var showPaywall = false
    @State private var showRetakeQuiz = false
    @State private var showExportCSVShare = false
    @State private var showExportPDFShare = false
    @State private var exportURL: URL?
    @State private var showClearDataAlert = false
    @State private var showClearDataConfirm = false
    @State private var showDeleteAccountAlert = false
    @State private var showDeleteAccountConfirm = false
    @State private var sectionAppeared: [Bool] = Array(repeating: false, count: 12)

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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    personalityHeroCard
                        .sectionFadeIn(index: 0, appeared: $sectionAppeared)
                    statsGrid
                        .sectionFadeIn(index: 1, appeared: $sectionAppeared)
                    characterCardSection
                        .sectionFadeIn(index: 2, appeared: $sectionAppeared)
                    appearanceSection
                        .sectionFadeIn(index: 3, appeared: $sectionAppeared)
                    notificationsSection
                        .sectionFadeIn(index: 4, appeared: $sectionAppeared)
                    budgetPreferencesSection
                        .sectionFadeIn(index: 5, appeared: $sectionAppeared)
                    sharingSection
                        .sectionFadeIn(index: 6, appeared: $sectionAppeared)
                    ReferralSectionView(
                        referralCode: profile?.referralCode ?? "MM-XXXXX",
                        referralCount: referrals.count
                    )
                    .sectionFadeIn(index: 7, appeared: $sectionAppeared)
                    PGSITrendChart(assessments: pgsiAssessments)
                        .sectionFadeIn(index: 7, appeared: $sectionAppeared)
                    pgsiPromptCard
                    BadgeGalleryView()
                    dataSection
                        .sectionFadeIn(index: 8, appeared: $sectionAppeared)
                    premiumSection
                        .sectionFadeIn(index: 9, appeared: $sectionAppeared)
                    aboutSection
                        .sectionFadeIn(index: 10, appeared: $sectionAppeared)
                    dangerZoneSection
                        .sectionFadeIn(index: 11, appeared: $sectionAppeared)
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear { staggerAppear() }
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
            .sheet(isPresented: $showExportCSVShare) {
                if let exportURL {
                    ShareSheet(items: [exportURL])
                }
            }
            .sheet(isPresented: $showExportPDFShare) {
                if let exportURL {
                    ShareSheet(items: [exportURL])
                }
            }
            .alert("Clear All Data", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) { showClearDataConfirm = true }
            } message: {
                Text("This will permanently delete all your transactions, check-ins, and progress. This cannot be undone.")
            }
            .alert("Are you absolutely sure?", isPresented: $showClearDataConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Everything", role: .destructive) { clearAllData() }
            } message: {
                Text("All data will be permanently erased. There is no way to recover it.")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) { showDeleteAccountConfirm = true }
            } message: {
                Text("This will delete your account and all associated data permanently.")
            }
            .alert("Final Confirmation", isPresented: $showDeleteAccountConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Account", role: .destructive) { clearAllData() }
            } message: {
                Text("This action is irreversible. Your account and all data will be permanently deleted.")
            }
        }
    }

    // MARK: - Personality Hero Card

    private var personalityHeroCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(personality.color.opacity(0.05))
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(personality.color.opacity(0.1))
                    .frame(width: 100, height: 100)

                Circle()
                    .fill(personality.color.opacity(0.18))
                    .frame(width: 68, height: 68)

                Image(systemName: personality.icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(personality.color)
                    .symbolEffect(.pulse, options: .repeating.speed(0.4))
            }

            VStack(spacing: 6) {
                Text(profile?.name ?? "User")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                Text(personality.rawValue)
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(personality.color)
            }

            HStack(spacing: 8) {
                ForEach(personality.traits, id: \.self) { trait in
                    Text(trait)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(personality.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(personality.color.opacity(0.1), in: .capsule)
                }
            }

            Button {
                showRetakeQuiz = true
            } label: {
                Text("Retake Quiz")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.secondary)
            }

            if let startDate = profile?.startDate {
                Text("Member since \(startDate, format: .dateTime.month(.wide).year())")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                colors: [personality.color.opacity(0.06), Theme.cardSurface],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: .rect(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(personality.color.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 12) {
            ProfileStatCard(
                value: "\(profile?.currentStreak ?? 0)",
                label: "Day Streak",
                icon: "flame.fill",
                color: .orange
            )
            ProfileStatCard(
                value: profile?.totalSaved.formatted(.currency(code: profile?.defaultCurrency ?? "USD").precision(.fractionLength(0))) ?? "$0",
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

    // MARK: - Character Card

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

    // MARK: - Appearance

    private var appearanceSection: some View {
        SettingsSection(title: "Appearance", icon: "paintbrush.fill", iconColor: Theme.accent) {
            if let profile {
                HStack(spacing: 14) {
                    SettingsIconBadge(icon: "moon.fill", color: Color(hex: 0x5B21B6))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Theme")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Dark mode only")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Text("DARK")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.accent.opacity(0.12), in: .capsule)
                }

                SettingsDivider()

                HStack(spacing: 14) {
                    SettingsIconBadge(icon: "paintpalette.fill", color: personality.color)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Personality Color")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                        Text(personality.rawValue)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Circle()
                        .fill(personality.color)
                        .frame(width: 24, height: 24)
                        .overlay(Circle().strokeBorder(.white.opacity(0.2), lineWidth: 1))
                }

                SettingsDivider()

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

                SettingsDivider()

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

                SettingsDivider()

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

                SettingsDivider()

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

    // MARK: - Notifications

    private var notificationsSection: some View {
        SettingsSection(title: "Notifications", icon: "bell.badge.fill", iconColor: Theme.danger) {
            if let profile {
                PreferenceToggle(
                    icon: "creditcard.fill",
                    title: "Bill Reminders",
                    subtitle: "Get reminded before bills are due",
                    isOn: Binding(
                        get: { profile.billRemindersEnabled },
                        set: { profile.billRemindersEnabled = $0 }
                    ),
                    color: Theme.warning
                )

                SettingsDivider()

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "chart.bar.fill")
                            .font(.subheadline)
                            .foregroundStyle(Theme.accent)
                            .frame(width: 28)
                        Text("Budget Alerts")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                    }

                    HStack(spacing: 12) {
                        BudgetAlertPill(
                            label: "50%",
                            isOn: Binding(
                                get: { profile.budgetAlert50 },
                                set: { profile.budgetAlert50 = $0 }
                            )
                        )
                        BudgetAlertPill(
                            label: "80%",
                            isOn: Binding(
                                get: { profile.budgetAlert80 },
                                set: { profile.budgetAlert80 = $0 }
                            )
                        )
                        BudgetAlertPill(
                            label: "100%",
                            isOn: Binding(
                                get: { profile.budgetAlert100 },
                                set: { profile.budgetAlert100 = $0 }
                            )
                        )
                    }
                    .padding(.leading, 40)
                }

                SettingsDivider()

                PreferenceToggle(
                    icon: "checkmark.circle.fill",
                    title: "Daily Check-In",
                    subtitle: "Morning and evening reminders",
                    isOn: Binding(
                        get: { profile.dailyCheckInNotif },
                        set: { profile.dailyCheckInNotif = $0 }
                    ),
                    color: Theme.accentGreen
                )

                SettingsDivider()

                PreferenceToggle(
                    icon: "newspaper.fill",
                    title: "Weekly Digest",
                    subtitle: "Summary of your weekly spending",
                    isOn: Binding(
                        get: { profile.weeklyDigestNotif },
                        set: { profile.weeklyDigestNotif = $0 }
                    ),
                    color: Theme.teal
                )

                SettingsDivider()

                NavigationLink(destination: NotificationSettingsView()) {
                    HStack(spacing: 14) {
                        SettingsIconBadge(icon: "slider.horizontal.3", color: Theme.textSecondary)
                        Text("Advanced Settings")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    }
                }
            }
        }
    }

    // MARK: - Budget Preferences

    private var budgetPreferencesSection: some View {
        SettingsSection(title: "Budget", icon: "chart.pie.fill", iconColor: Theme.accentGreen) {
            if let profile {
                HStack(spacing: 14) {
                    SettingsIconBadge(icon: "dollarsign.circle.fill", color: Theme.accentGreen)
                    Text("Default Currency")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Picker("", selection: Binding(
                        get: { profile.defaultCurrency },
                        set: { profile.defaultCurrency = $0 }
                    )) {
                        Text("USD").tag("USD")
                        Text("EUR").tag("EUR")
                        Text("GBP").tag("GBP")
                        Text("CAD").tag("CAD")
                        Text("AUD").tag("AUD")
                        Text("JPY").tag("JPY")
                        Text("INR").tag("INR")
                    }
                    .pickerStyle(.menu)
                    .tint(Theme.accentGreen)
                }

                SettingsDivider()

                HStack(spacing: 14) {
                    SettingsIconBadge(icon: "list.bullet.rectangle.fill", color: Theme.accent)
                    Text("Budget Method")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Picker("", selection: Binding(
                        get: { profile.defaultBudgetMethod },
                        set: { profile.defaultBudgetMethod = $0 }
                    )) {
                        Text("50/30/20").tag("50/30/20")
                        Text("Zero-Based").tag("Zero-Based")
                        Text("Envelope").tag("Envelope")
                    }
                    .pickerStyle(.menu)
                    .tint(Theme.accent)
                }

                SettingsDivider()

                HStack(spacing: 14) {
                    SettingsIconBadge(icon: "calendar", color: Theme.teal)
                    Text("First Day of Month")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Picker("", selection: Binding(
                        get: { profile.firstDayOfMonth },
                        set: { profile.firstDayOfMonth = $0 }
                    )) {
                        ForEach(1...28, id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Theme.teal)
                }
            }
        }
    }

    // MARK: - Sharing

    private var sharingSection: some View {
        SettingsSection(title: "Share & Celebrate", icon: "square.and.arrow.up.fill", iconColor: Theme.accentGreen) {
            SettingsNavRow(icon: "calendar", title: "Weekly Summary", subtitle: "Share your 7-day highlights", color: Theme.teal) {
                showWeeklySummary = true
            }
            SettingsDivider()
            SettingsNavRow(icon: "sparkles", title: "Monthly Recap", subtitle: "Your month in 6 story cards", color: Theme.accentGreen, badge: "NEW") {
                showMoneyWrapped = true
            }
            SettingsDivider()
            SettingsNavRow(icon: "gift.fill", title: "Money Wrapped", subtitle: "Your all-time journey in cards", color: Theme.gold) {
                showAnnualWrapped = true
            }
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        SettingsSection(title: "Data", icon: "externaldrive.fill", iconColor: Theme.secondary) {
            SettingsNavRow(icon: "tablecells.fill", title: "Export Transactions", subtitle: "Download as CSV file", color: Theme.accentGreen) {
                if let url = ExportService.exportCSV(transactions: Array(transactions)) {
                    exportURL = url
                    showExportCSVShare = true
                }
            }
            SettingsDivider()
            SettingsNavRow(icon: "doc.richtext.fill", title: "Monthly Report", subtitle: "Generate PDF report", color: Theme.accent) {
                if let url = ExportService.exportPDF(transactions: Array(transactions), profile: profile) {
                    exportURL = url
                    showExportPDFShare = true
                }
            }
            SettingsDivider()
            Button {
                showClearDataAlert = true
            } label: {
                HStack(spacing: 14) {
                    SettingsIconBadge(icon: "trash.fill", color: Theme.danger)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clear All Data")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.danger)
                        Text("Remove all transactions and progress")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }
        }
    }

    // MARK: - Premium

    private var premiumSection: some View {
        SettingsSection(title: "Premium", icon: "crown.fill", iconColor: Theme.gold) {
            HStack(spacing: 14) {
                SettingsIconBadge(icon: "checkmark.seal.fill", color: premiumManager.isPremium ? Theme.accentGreen : Theme.textMuted)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Plan")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                    Text(premiumManager.isPremium ? "Premium Active" : "Free Plan")
                        .font(.caption)
                        .foregroundStyle(premiumManager.isPremium ? Theme.accentGreen : Theme.textSecondary)
                }
                Spacer()
                if premiumManager.isPremium {
                    Text("PRO")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.goldGradient, in: .capsule)
                }
            }

            if !premiumManager.isPremium {
                SettingsDivider()
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

            SettingsDivider()

            Button {
                premiumManager.restore()
            } label: {
                HStack(spacing: 14) {
                    SettingsIconBadge(icon: "arrow.counterclockwise", color: Theme.textSecondary)
                    Text("Restore Purchases")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                }
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        SettingsSection(title: "About", icon: "info.circle.fill", iconColor: Theme.textSecondary) {
            HStack(spacing: 14) {
                SettingsIconBadge(icon: "number", color: Theme.textMuted)
                Text("Version")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            SettingsDivider()

            SettingsNavRow(icon: "star.fill", title: "Rate on App Store", color: .orange) {
                if let url = URL(string: "https://apps.apple.com/app/splurj") {
                    UIApplication.shared.open(url)
                }
            }
            SettingsDivider()
            SettingsNavRow(icon: "square.and.arrow.up", title: "Share Splurj", color: Theme.accentGreen) {
                let url = URL(string: "https://splurj.app")!
                let av = UIActivityViewController(activityItems: ["Check out Splurj — Don't splurge. Splurj.", url], applicationActivities: nil)
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.windows.first?.rootViewController {
                    root.present(av, animated: true)
                }
            }
            SettingsDivider()
            SettingsNavRow(icon: "lock.shield.fill", title: "Privacy Policy", color: .blue) {
                if let url = URL(string: "https://moneymind.app/privacy") {
                    UIApplication.shared.open(url)
                }
            }
            SettingsDivider()
            SettingsNavRow(icon: "doc.text.fill", title: "Terms of Service", color: Theme.textSecondary) {
                if let url = URL(string: "https://moneymind.app/terms") {
                    UIApplication.shared.open(url)
                }
            }
            SettingsDivider()
            SettingsNavRow(icon: "envelope.fill", title: "Contact Support", color: Theme.teal) {
                if let url = URL(string: "mailto:support@moneymind.app") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    // MARK: - Danger Zone

    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(Theme.danger)
                Text("Danger Zone")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.danger)
            }

            Button {
                showClearDataAlert = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.subheadline)
                        .foregroundStyle(Theme.danger)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clear All Data")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.danger)
                        Text("Permanently remove all app data")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                }
            }
            .sensoryFeedback(.warning, trigger: showClearDataAlert)

            SettingsDivider()

            Button {
                showDeleteAccountAlert = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.xmark")
                        .font(.subheadline)
                        .foregroundStyle(Theme.danger)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Delete Account")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.danger)
                        Text("Delete your account and all data forever")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                }
            }
            .sensoryFeedback(.warning, trigger: showDeleteAccountAlert)
        }
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.danger.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - PGSI

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
            }
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
            let delay = Double(i) * 0.08
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    sectionAppeared[i] = true
                }
            }
        }
    }

    private func clearAllData() {
        do {
            try modelContext.delete(model: Transaction.self)
            try modelContext.delete(model: ImpulseLog.self)
            try modelContext.delete(model: DailyCheckIn.self)
            try modelContext.delete(model: Badge.self)
            if let profile {
                profile.totalSaved = 0
                profile.currentStreak = 0
                profile.longestStreak = 0
                profile.xpPoints = 0
                profile.totalConsciousChoices = 0
            }
        } catch { }
    }
}

// MARK: - Reusable Settings Components

private struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.bottom, 2)

            content()
        }
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
    }
}

private struct SettingsIconBadge: View {
    let icon: String
    let color: Color

    var body: some View {
        Image(systemName: icon)
            .font(.subheadline)
            .foregroundStyle(.white)
            .frame(width: 30, height: 30)
            .background(color, in: .rect(cornerRadius: 7))
    }
}

private struct SettingsDivider: View {
    var body: some View {
        Divider()
            .overlay(Theme.background.opacity(0.3))
    }
}

private struct SettingsNavRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let color: Color
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                SettingsIconBadge(icon: icon, color: color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(color.opacity(0.12), in: .capsule)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }
        }
        .buttonStyle(PressableButtonStyle())
    }
}

private struct BudgetAlertPill: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isOn ? .white : Theme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isOn ? Theme.accent : Theme.elevated, in: .capsule)
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.selection, trigger: isOn)
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
    }
}

// MARK: - Stagger Animation Modifier

private struct SectionFadeInModifier: ViewModifier {
    let index: Int
    @Binding var appeared: [Bool]

    func body(content: Content) -> some View {
        content
            .opacity(index < appeared.count && appeared[index] ? 1 : 0)
            .offset(y: index < appeared.count && appeared[index] ? 0 : 12)
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
