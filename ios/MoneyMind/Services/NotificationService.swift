import Foundation
import UserNotifications

@Observable
class NotificationService {
    static let shared = NotificationService()

    var isAuthorized: Bool = false

    private let center = UNUserNotificationCenter.current()
    private let milestones: [Double] = [100, 500, 1_000, 5_000, 10_000, 25_000, 50_000, 100_000]

    private init() {
        Task { await checkAuthorizationStatus() }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    func scheduleAllNotifications(profile: UserProfile, patterns: [HighRiskPattern] = [], nextIncompleteSession: Int? = nil, lastSessionCompletionDate: Date? = nil) {
        guard profile.notificationsEnabled else {
            center.removeAllPendingNotificationRequests()
            return
        }

        center.removeAllPendingNotificationRequests()

        let isGentle = profile.gentleViewMode
        let isSupportive = profile.notificationStyle != "minimal"

        if profile.morningPledgeNotif {
            scheduleDailyNotification(
                id: "morning_pledge",
                hour: profile.dailyPledgeTime,
                minute: 0,
                title: isSupportive ? "Good Morning" : "Daily Pledge",
                body: isSupportive ? "Start your day with intention. Your pledge is waiting." : "Time for your daily pledge.",
                profile: profile
            )
        }

        if profile.eveningReflectionNotif {
            scheduleDailyNotification(
                id: "evening_reflection",
                hour: profile.eveningReflectionTime,
                minute: 0,
                title: isSupportive ? "Evening Check-In" : "Reflection Time",
                body: isSupportive ? "How was your day? Take a moment to reflect on your journey." : "Time for your evening reflection.",
                profile: profile
            )
        }

        if profile.weeklyPaycheckNotif {
            scheduleWeeklyPaycheck(profile: profile, isGentle: isGentle, isSupportive: isSupportive)
        }

        if profile.streakMaintenanceNotif {
            scheduleStreakMaintenance(profile: profile, isSupportive: isSupportive)
        }

        if profile.milestoneApproachingNotif {
            scheduleMilestoneApproaching(profile: profile, isGentle: isGentle, isSupportive: isSupportive)
        }

        if profile.emaMorningNotif {
            scheduleDailyNotification(
                id: "ema_morning",
                hour: profile.emaMorningTime,
                minute: 0,
                title: "Quick Check-In",
                body: isSupportive ? "How's your urge level right now? Just a quick tap." : "Morning urge check.",
                profile: profile
            )
        }

        if profile.emaAfternoonNotif {
            scheduleDailyNotification(
                id: "ema_afternoon",
                hour: profile.emaAfternoonTime,
                minute: 0,
                title: "Spending Intention",
                body: isSupportive ? "Any purchases planned today? Set your intention." : "Afternoon spending check.",
                profile: profile
            )
        }

        if profile.emaEveningNotif {
            scheduleDailyNotification(
                id: "ema_evening",
                hour: profile.emaEveningTime,
                minute: 0,
                title: "End of Day",
                body: isSupportive ? "Did you stick to your intention today? Quick check." : "Evening intention check.",
                profile: profile
            )
        }

        if profile.midDayIntentionNotif {
            scheduleDailyNotification(
                id: "midday_intention",
                hour: profile.midDayIntentionTime,
                minute: profile.midDayIntentionMinute,
                title: isSupportive ? "Spending Intention" : "Intention Check",
                body: isSupportive ? "Any spending planned? Set your intention and stay mindful." : "Set your spending intention.",
                profile: profile
            )
        }

        if profile.jitaiAdaptiveNotif {
            scheduleJITAINotifications(patterns: patterns, profile: profile, isSupportive: isSupportive)
        }

        if profile.curriculumReminderNotif, let nextSession = nextIncompleteSession {
            scheduleCurriculumReminder(
                nextSession: nextSession,
                lastCompletionDate: lastSessionCompletionDate,
                profile: profile,
                isSupportive: isSupportive
            )
        }

        if profile.reEngagementNotif {
            scheduleReEngagementCampaign(profile: profile, isSupportive: isSupportive)
        }
    }

    private func scheduleDailyNotification(id: String, hour: Int, minute: Int, title: String, body: String, profile: UserProfile) {
        guard !isInQuietHours(hour: hour, minute: minute, profile: profile) else { return }

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    private func scheduleWeeklyPaycheck(profile: UserProfile, isGentle: Bool, isSupportive: Bool) {
        guard !isInQuietHours(hour: 10, minute: 0, profile: profile) else { return }

        var dateComponents = DateComponents()
        dateComponents.weekday = 1
        dateComponents.hour = 10
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = isSupportive ? "Your Weekly Paycheck" : "Weekly Summary"

        if isGentle {
            content.body = isSupportive ? "Great week! You stayed mindful and saved real money." : "Great week of mindful choices!"
        } else {
            let saved = profile.totalSaved
            let formatted = saved.formatted(.currency(code: "USD").precision(.fractionLength(0)))
            content.body = isSupportive ? "You earned \(formatted) this week by staying mindful. Real money." : "Saved \(formatted) this week."
        }
        content.sound = .default

        let request = UNNotificationRequest(identifier: "weekly_paycheck", content: content, trigger: trigger)
        center.add(request)
    }

    private func scheduleStreakMaintenance(profile: UserProfile, isSupportive: Bool) {
        guard profile.currentStreak > 0 else { return }
        guard !isInQuietHours(hour: 18, minute: 0, profile: profile) else { return }

        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = isSupportive ? "Streak Check" : "Streak"
        content.body = isSupportive
            ? "Your \(profile.currentStreak)-day streak is still going strong. Keep it alive!"
            : "\(profile.currentStreak)-day streak active."
        content.sound = .default

        let request = UNNotificationRequest(identifier: "streak_maintenance", content: content, trigger: trigger)
        center.add(request)
    }

    private func scheduleMilestoneApproaching(profile: UserProfile, isGentle: Bool, isSupportive: Bool) {
        let nextMilestone = milestones.first { $0 > profile.totalSaved }
        guard let milestone = nextMilestone else { return }

        let remaining = milestone - profile.totalSaved
        guard remaining <= 50 && remaining > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = isSupportive ? "Almost There!" : "Milestone"

        if isGentle {
            content.body = isSupportive ? "You're so close to your next savings milestone!" : "Next milestone approaching."
        } else {
            let formatted = milestone.formatted(.currency(code: "USD").precision(.fractionLength(0)))
            let remainFormatted = remaining.formatted(.currency(code: "USD").precision(.fractionLength(0)))
            content.body = isSupportive
                ? "You're just \(remainFormatted) away from \(formatted). Keep going!"
                : "\(remainFormatted) to \(formatted)."
        }
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "milestone_approaching", content: content, trigger: trigger)
        center.add(request)
    }

    private func scheduleJITAINotifications(patterns: [HighRiskPattern], profile: UserProfile, isSupportive: Bool) {
        let topPatterns = patterns
            .sorted { $0.frequency > $1.frequency }
            .prefix(5)

        for (index, pattern) in topPatterns.enumerated() {
            var notifHour = pattern.hourOfDay
            var notifMinute = 45

            if pattern.hourOfDay > 0 {
                notifHour = pattern.hourOfDay - 1
            } else {
                notifHour = 23
            }

            guard !isInQuietHours(hour: notifHour, minute: notifMinute, profile: profile) else { continue }

            var dateComponents = DateComponents()
            dateComponents.weekday = pattern.dayOfWeek
            dateComponents.hour = notifHour
            dateComponents.minute = notifMinute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let content = UNMutableNotificationContent()

            let calendar = Calendar.current
            let dayName = calendar.weekdaySymbols[max(0, min(6, pattern.dayOfWeek - 1))]

            content.title = isSupportive ? "Heads Up" : "Alert"
            content.body = isSupportive
                ? "\(dayName) evening. Usually a tough time for you. Urge surf is one tap away."
                : "\(dayName) pattern detected. Tools ready."
            content.sound = .default

            let request = UNNotificationRequest(identifier: "jitai_\(index)", content: content, trigger: trigger)
            center.add(request)
        }
    }

    private func scheduleCurriculumReminder(nextSession: Int, lastCompletionDate: Date?, profile: UserProfile, isSupportive: Bool) {
        let daysSinceCompletion: Int
        if let lastDate = lastCompletionDate {
            daysSinceCompletion = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        } else {
            daysSinceCompletion = Calendar.current.dateComponents([.day], from: profile.startDate, to: Date()).day ?? 0
        }

        guard daysSinceCompletion >= 10 else { return }
        guard !isInQuietHours(hour: 11, minute: 0, profile: profile) else { return }

        let sessionTitles = [
            1: "Understanding Your Money Brain",
            2: "Catching Irrational Thoughts",
            3: "Building Your Coping Toolkit",
            4: "Problem-Solving High-Risk Situations",
            5: "Your Support Network",
            6: "Financial Consequences Audit",
            7: "Building Alternative Behaviors",
            8: "Your Relapse Prevention Plan"
        ]
        let title = sessionTitles[nextSession] ?? "Your Next Session"

        let content = UNMutableNotificationContent()
        content.title = isSupportive ? "Continue Your Program" : "Session \(nextSession)"
        content.body = isSupportive
            ? "Session \(nextSession) is waiting: \(title). 15 minutes that could change your week."
            : "Session \(nextSession): \(title). Ready when you are."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
        let request = UNNotificationRequest(identifier: "curriculum_reminder", content: content, trigger: trigger)
        center.add(request)
    }

    func scheduleReEngagementCampaign(profile: UserProfile, isSupportive: Bool) {
        let characterName = CharacterStage.from(xp: profile.xpPoints).name

        let campaigns: [(days: Int, title: String, supportiveBody: String, minimalBody: String)] = [
            (3, "We Miss You",
             "Your character misses you. \(characterName) is waiting.",
             "\(characterName) is waiting for you."),
            (7, "So Close",
             profile.gentleViewMode
                ? "You're close to your next milestone. Come claim it."
                : "You're $\(Int(nextMilestoneGap(profile))) from your next milestone. Come claim it.",
             "Milestone approaching. Open to check."),
            (14, "Community Update",
             "327 members surfed urges today. Your community is here.",
             "Your community is active. Join them."),
            (21, "Fresh Start",
             "Your streak is waiting. Day 1 is the bravest day.",
             "Ready for Day 1?")
        ]

        for campaign in campaigns {
            guard let fireDate = Calendar.current.date(byAdding: .day, value: campaign.days, to: Date()) else { continue }
            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
            dateComponents.hour = 10
            dateComponents.minute = 0

            guard !isInQuietHours(hour: 10, minute: 0, profile: profile) else { continue }

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let content = UNMutableNotificationContent()
            content.title = campaign.title
            content.body = isSupportive ? campaign.supportiveBody : campaign.minimalBody
            content.sound = .default

            let request = UNNotificationRequest(identifier: "reengagement_day\(campaign.days)", content: content, trigger: trigger)
            center.add(request)
        }
    }

    private func nextMilestoneGap(_ profile: UserProfile) -> Double {
        let next = milestones.first { $0 > profile.totalSaved } ?? 100
        return next - profile.totalSaved
    }

    private func isInQuietHours(hour: Int, minute: Int, profile: UserProfile) -> Bool {
        guard profile.quietHoursEnabled else { return false }

        let timeValue = hour * 60 + minute
        let startValue = profile.quietHoursStart * 60
        let endValue = profile.quietHoursEnd * 60

        if startValue <= endValue {
            return timeValue >= startValue && timeValue < endValue
        } else {
            return timeValue >= startValue || timeValue < endValue
        }
    }
}
