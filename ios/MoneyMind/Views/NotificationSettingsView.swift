import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Query private var profiles: [UserProfile]
    @Query private var patterns: [HighRiskPattern]
    @Query(sort: \CurriculumSession.sessionNumber) private var sessions: [CurriculumSession]
    @State private var notifService = NotificationService.shared

    private var profile: UserProfile? { profiles.first }

    private var nextIncompleteSession: Int? {
        for i in 1...8 {
            if !sessions.contains(where: { $0.sessionNumber == i && $0.isCompleted }) {
                return i
            }
        }
        return nil
    }

    private var lastSessionCompletionDate: Date? {
        sessions.filter(\.isCompleted).compactMap(\.completedDate).max()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                masterToggleSection
                if profile?.notificationsEnabled == true {
                    budgetAlertsSection
                    dailyRemindersSection
                    checkInsSection
                    weeklyMilestonesSection
                    smartNotificationsSection
                    quietHoursSection
                    styleSection
                    frequencyCapNote
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onChange(of: profile?.notificationsEnabled) { _, _ in reschedule() }
        .onChange(of: profile?.notificationStyle) { _, _ in reschedule() }
        .onChange(of: profile?.quietHoursEnabled) { _, _ in reschedule() }
        .onChange(of: profile?.quietHoursStart) { _, _ in reschedule() }
        .onChange(of: profile?.quietHoursEnd) { _, _ in reschedule() }
    }

    private func reschedule() {
        guard let profile else { return }
        notifService.scheduleAllNotifications(
            profile: profile,
            patterns: Array(patterns),
            nextIncompleteSession: nextIncompleteSession,
            lastSessionCompletionDate: lastSessionCompletionDate
        )
    }

    private var masterToggleSection: some View {
        VStack(spacing: 0) {
            if let profile {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Theme.accentGreen.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: "bell.badge.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.accentGreen)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Notifications")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        Text(profile.notificationsEnabled ? "All notifications active" : "Notifications are off")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { profile.notificationsEnabled },
                        set: { newValue in
                            if newValue {
                                Task {
                                    let granted = await notifService.requestPermission()
                                    profile.notificationsEnabled = granted
                                    if granted { reschedule() }
                                }
                            } else {
                                profile.notificationsEnabled = false
                            }
                        }
                    ))
                    .labelsHidden()
                    .tint(Theme.accentGreen)
                }
                .padding(16)

                if !notifService.isAuthorized && profile.notificationsEnabled {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("Enable notifications in Settings to receive alerts")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
        }
        .glassCard()
        .sensoryFeedback(.selection, trigger: profile?.notificationsEnabled)
    }

    private var dailyRemindersSection: some View {
        NotifSection(title: "Daily Reminders", icon: "sun.max.fill", iconColor: Theme.gold) {
            if let profile {
                NotifToggleRow(
                    icon: "sunrise.fill",
                    title: "Morning Pledge",
                    subtitle: "\(formatHour(profile.dailyPledgeTime))",
                    isOn: Binding(
                        get: { profile.morningPledgeNotif },
                        set: { profile.morningPledgeNotif = $0; reschedule() }
                    ),
                    color: Theme.gold
                )

                if profile.morningPledgeNotif {
                    NotifTimePicker(
                        label: "Pledge Time",
                        hour: Binding(
                            get: { profile.dailyPledgeTime },
                            set: { profile.dailyPledgeTime = $0; reschedule() }
                        )
                    )
                }

                Divider().overlay(Theme.background.opacity(0.3))

                NotifToggleRow(
                    icon: "moon.stars.fill",
                    title: "Evening Reflection",
                    subtitle: "\(formatHour(profile.eveningReflectionTime))",
                    isOn: Binding(
                        get: { profile.eveningReflectionNotif },
                        set: { profile.eveningReflectionNotif = $0; reschedule() }
                    ),
                    color: Color(red: 0.4, green: 0.5, blue: 0.9)
                )

                if profile.eveningReflectionNotif {
                    NotifTimePicker(
                        label: "Reflection Time",
                        hour: Binding(
                            get: { profile.eveningReflectionTime },
                            set: { profile.eveningReflectionTime = $0; reschedule() }
                        )
                    )
                }

                Divider().overlay(Theme.background.opacity(0.3))

                NotifToggleRow(
                    icon: "cart.fill",
                    title: "Mid-Day Intention",
                    subtitle: "\(formatHour(profile.midDayIntentionTime, minute: profile.midDayIntentionMinute))",
                    isOn: Binding(
                        get: { profile.midDayIntentionNotif },
                        set: { profile.midDayIntentionNotif = $0; reschedule() }
                    ),
                    color: Theme.teal
                )

                if profile.midDayIntentionNotif {
                    NotifTimePicker(
                        label: "Intention Time",
                        hour: Binding(
                            get: { profile.midDayIntentionTime },
                            set: { profile.midDayIntentionTime = $0; reschedule() }
                        ),
                        minute: Binding(
                            get: { profile.midDayIntentionMinute },
                            set: { profile.midDayIntentionMinute = $0; reschedule() }
                        )
                    )
                }
            }
        }
    }

    private var checkInsSection: some View {
        NotifSection(title: "EMA Check-Ins", icon: "checkmark.circle.fill", iconColor: Theme.teal) {
            if let profile {
                NotifToggleRow(
                    icon: "sunrise",
                    title: "Morning Check-In",
                    subtitle: "Urge level · \(formatHour(profile.emaMorningTime))",
                    isOn: Binding(
                        get: { profile.emaMorningNotif },
                        set: { profile.emaMorningNotif = $0; reschedule() }
                    ),
                    color: Theme.gold
                )

                if profile.emaMorningNotif {
                    NotifTimePicker(
                        label: "Morning Time",
                        hour: Binding(
                            get: { profile.emaMorningTime },
                            set: { profile.emaMorningTime = $0; reschedule() }
                        )
                    )
                }

                Divider().overlay(Theme.background.opacity(0.3))

                NotifToggleRow(
                    icon: "sun.min",
                    title: "Afternoon Check-In",
                    subtitle: "Spending intention · \(formatHour(profile.emaAfternoonTime))",
                    isOn: Binding(
                        get: { profile.emaAfternoonNotif },
                        set: { profile.emaAfternoonNotif = $0; reschedule() }
                    ),
                    color: .orange
                )

                if profile.emaAfternoonNotif {
                    NotifTimePicker(
                        label: "Afternoon Time",
                        hour: Binding(
                            get: { profile.emaAfternoonTime },
                            set: { profile.emaAfternoonTime = $0; reschedule() }
                        )
                    )
                }

                Divider().overlay(Theme.background.opacity(0.3))

                NotifToggleRow(
                    icon: "moon",
                    title: "Evening Check-In",
                    subtitle: "Intention review · \(formatHour(profile.emaEveningTime))",
                    isOn: Binding(
                        get: { profile.emaEveningNotif },
                        set: { profile.emaEveningNotif = $0; reschedule() }
                    ),
                    color: Color(red: 0.4, green: 0.5, blue: 0.9)
                )

                if profile.emaEveningNotif {
                    NotifTimePicker(
                        label: "Evening Time",
                        hour: Binding(
                            get: { profile.emaEveningTime },
                            set: { profile.emaEveningTime = $0; reschedule() }
                        )
                    )
                }
            }
        }
    }

    private var weeklyMilestonesSection: some View {
        NotifSection(title: "Weekly & Milestones", icon: "trophy.fill", iconColor: Theme.gold) {
            if let profile {
                NotifToggleRow(
                    icon: "banknote.fill",
                    title: "Weekly Paycheck",
                    subtitle: "Sunday 10am savings summary",
                    isOn: Binding(
                        get: { profile.weeklyPaycheckNotif },
                        set: { profile.weeklyPaycheckNotif = $0; reschedule() }
                    ),
                    color: Theme.accentGreen
                )

                Divider().overlay(Theme.background.opacity(0.3))

                NotifToggleRow(
                    icon: "flag.fill",
                    title: "Milestone Approaching",
                    subtitle: "Within $50 of savings milestone",
                    isOn: Binding(
                        get: { profile.milestoneApproachingNotif },
                        set: { profile.milestoneApproachingNotif = $0; reschedule() }
                    ),
                    color: Theme.gold
                )

                Divider().overlay(Theme.background.opacity(0.3))

                NotifToggleRow(
                    icon: "flame.fill",
                    title: "Streak Maintenance",
                    subtitle: "6pm daily if not opened",
                    isOn: Binding(
                        get: { profile.streakMaintenanceNotif },
                        set: { profile.streakMaintenanceNotif = $0; reschedule() }
                    ),
                    color: .orange
                )
            }
        }
    }

    private var smartNotificationsSection: some View {
        NotifSection(title: "Smart Notifications", icon: "brain.head.profile.fill", iconColor: Theme.teal) {
            if let profile {
                NotifToggleRow(
                    icon: "waveform.path.ecg",
                    title: "JITAI Adaptive",
                    subtitle: "Proactive alerts before risky times",
                    isOn: Binding(
                        get: { profile.jitaiAdaptiveNotif },
                        set: { profile.jitaiAdaptiveNotif = $0; reschedule() }
                    ),
                    color: Theme.teal
                )

                Divider().overlay(Theme.background.opacity(0.3))

                NotifToggleRow(
                    icon: "book.fill",
                    title: "Curriculum Reminders",
                    subtitle: "Nudge after 10 days without a session",
                    isOn: Binding(
                        get: { profile.curriculumReminderNotif },
                        set: { profile.curriculumReminderNotif = $0; reschedule() }
                    ),
                    color: Color(red: 0.4, green: 0.6, blue: 1.0)
                )

                Divider().overlay(Theme.background.opacity(0.3))

                NotifToggleRow(
                    icon: "arrow.uturn.backward.circle.fill",
                    title: "Re-engagement",
                    subtitle: "Gentle nudges if you haven't visited",
                    isOn: Binding(
                        get: { profile.reEngagementNotif },
                        set: { profile.reEngagementNotif = $0; reschedule() }
                    ),
                    color: Theme.accentGreen
                )
            }
        }
    }

    private var quietHoursSection: some View {
        NotifSection(title: "Quiet Hours", icon: "moon.zzz.fill", iconColor: Color(red: 0.4, green: 0.5, blue: 0.9)) {
            if let profile {
                NotifToggleRow(
                    icon: "bell.slash.fill",
                    title: "Enable Quiet Hours",
                    subtitle: "No notifications during this window",
                    isOn: Binding(
                        get: { profile.quietHoursEnabled },
                        set: { profile.quietHoursEnabled = $0; reschedule() }
                    ),
                    color: Color(red: 0.4, green: 0.5, blue: 0.9)
                )

                if profile.quietHoursEnabled {
                    Divider().overlay(Theme.background.opacity(0.3))

                    NotifTimePicker(
                        label: "Start",
                        hour: Binding(
                            get: { profile.quietHoursStart },
                            set: { profile.quietHoursStart = $0; reschedule() }
                        )
                    )

                    NotifTimePicker(
                        label: "End",
                        hour: Binding(
                            get: { profile.quietHoursEnd },
                            set: { profile.quietHoursEnd = $0; reschedule() }
                        )
                    )
                }
            }
        }
    }

    private var budgetAlertsSection: some View {
        NotifSection(title: "Budget & Bills", icon: "chart.bar.fill", iconColor: Theme.warning) {
            if let profile {
                NotifToggleRow(
                    icon: "creditcard.fill",
                    title: "Bill Reminders",
                    subtitle: "Remind before bills are due",
                    isOn: Binding(
                        get: { profile.billRemindersEnabled },
                        set: { profile.billRemindersEnabled = $0; reschedule() }
                    ),
                    color: Theme.teal
                )

                Divider().overlay(Theme.background.opacity(0.3))

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundStyle(Theme.warning)
                            .frame(width: 24)
                        Text("Budget Alert Thresholds")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textPrimary)
                    }

                    HStack(spacing: 10) {
                        BudgetThresholdPill(
                            label: "50%",
                            color: Theme.gold,
                            isOn: Binding(
                                get: { profile.budgetAlert50 },
                                set: { profile.budgetAlert50 = $0; reschedule() }
                            )
                        )
                        BudgetThresholdPill(
                            label: "80%",
                            color: Theme.warning,
                            isOn: Binding(
                                get: { profile.budgetAlert80 },
                                set: { profile.budgetAlert80 = $0; reschedule() }
                            )
                        )
                        BudgetThresholdPill(
                            label: "100%",
                            color: Theme.danger,
                            isOn: Binding(
                                get: { profile.budgetAlert100 },
                                set: { profile.budgetAlert100 = $0; reschedule() }
                            )
                        )
                    }
                    .padding(.leading, 36)
                }

                Divider().overlay(Theme.background.opacity(0.3))

                NotifToggleRow(
                    icon: "moon.stars.fill",
                    title: "Daily Check-In",
                    subtitle: "Evening spending reflection",
                    isOn: Binding(
                        get: { profile.dailyCheckInNotif },
                        set: { profile.dailyCheckInNotif = $0; reschedule() }
                    ),
                    color: Theme.accent
                )

                Divider().overlay(Theme.background.opacity(0.3))

                NotifToggleRow(
                    icon: "newspaper.fill",
                    title: "Weekly Digest",
                    subtitle: "Sunday morning spending summary",
                    isOn: Binding(
                        get: { profile.weeklyDigestNotif },
                        set: { profile.weeklyDigestNotif = $0; reschedule() }
                    ),
                    color: Theme.teal
                )
            }
        }
    }

    private var frequencyCapNote: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.subheadline)
                .foregroundStyle(Theme.textMuted)
            Text("Push notifications are capped at 3 per day to keep things calm.")
                .font(.caption)
                .foregroundStyle(Theme.textMuted)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.elevated.opacity(0.5), in: .rect(cornerRadius: 12))
    }

    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "text.bubble.fill")
                    .font(.subheadline)
                    .foregroundStyle(Theme.accentGreen)
                Text("Notification Style")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            if let profile {
                Picker("Style", selection: Binding(
                    get: { profile.notificationStyle },
                    set: { profile.notificationStyle = $0; reschedule() }
                )) {
                    Text("Supportive").tag("standard")
                    Text("Minimal").tag("minimal")
                }
                .pickerStyle(.segmented)

                Text(profile.notificationStyle == "minimal"
                     ? "Brief, to-the-point messages"
                     : "Longer, warmer messages with encouragement")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(16)
        .glassCard()
    }

    private func formatHour(_ hour: Int, minute: Int = 0) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let calendar = Calendar.current
        guard let date = calendar.date(from: components) else { return "\(hour):00" }
        return date.formatted(date: .omitted, time: .shortened)
    }
}

private struct NotifSection<Content: View>: View {
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
        .glassCard()
    }
}

private struct NotifToggleRow: View {
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
                    .frame(width: 24)

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

private struct NotifTimePicker: View {
    let label: String
    @Binding var hour: Int
    var minute: Binding<Int>?

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            Spacer()

            HStack(spacing: 4) {
                Picker("Hour", selection: $hour) {
                    ForEach(0..<24, id: \.self) { h in
                        Text(formatHourOnly(h)).tag(h)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.accentGreen)

                if let minute {
                    Text(":")
                        .foregroundStyle(Theme.textSecondary)
                    Picker("Minute", selection: minute) {
                        ForEach([0, 15, 30, 45], id: \.self) { m in
                            Text(String(format: "%02d", m)).tag(m)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Theme.accentGreen)
                }
            }
        }
        .padding(.leading, 36)
    }

    private func formatHourOnly(_ h: Int) -> String {
        var components = DateComponents()
        components.hour = h
        components.minute = 0
        let calendar = Calendar.current
        guard let date = calendar.date(from: components) else { return "\(h)" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
}

private struct BudgetThresholdPill: View {
    let label: String
    let color: Color
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
                .background(isOn ? color : Theme.elevated, in: .capsule)
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.selection, trigger: isOn)
    }
}
