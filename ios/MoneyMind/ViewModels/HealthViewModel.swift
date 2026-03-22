import SwiftUI
import SwiftData

nonisolated struct JITAISuggestion: Sendable, Identifiable {
    let id = UUID()
    let toolType: JITAIToolType
    let icon: String
    let title: String
    let message: String
    let color: Color

    init(toolType: JITAIToolType, icon: String, title: String, message: String, color: Color) {
        self.icon = icon
        self.title = title
        self.message = message
        self.color = color
        self.toolType = toolType
    }
}

nonisolated enum HRVTrend: Sendable {
    case improving
    case stable
    case declining
    case unknown

    var icon: String {
        switch self {
        case .improving: "arrow.up.right"
        case .stable: "arrow.right"
        case .declining: "arrow.down.right"
        case .unknown: "minus"
        }
    }

    var color: Color {
        switch self {
        case .improving: Color(red: 0, green: 230/255, blue: 118/255)
        case .stable: Color(red: 0, green: 230/255, blue: 118/255)
        case .declining: Color(red: 1, green: 179/255, blue: 0)
        case .unknown: Color(white: 0.6)
        }
    }

    var label: String {
        switch self {
        case .improving: "Improving"
        case .stable: "Stable"
        case .declining: "Declining"
        case .unknown: "No Data"
        }
    }
}

@Observable
class HealthViewModel {
    var hrvData: [HRVDataPoint] = []
    var hrvTrend: HRVTrend = .unknown
    var isStressDetected: Bool = false
    var todayHRV: Double = 0
    var weekAvgHRV: Double = 0
    var isAuthorized: Bool = false
    var hasRequestedAuth: Bool = false
    var jitaiSuggestions: [JITAISuggestion] = []

    private let healthService = HealthKitService()

    func requestAuthAndLoad() async {
        guard !hasRequestedAuth else { return }
        hasRequestedAuth = true

        let authorized = await healthService.requestAuthorization()
        isAuthorized = authorized

        if authorized && healthService.isHealthDataAvailable {
            let data = await healthService.fetchHRVData(days: 7)
            if data.isEmpty {
                loadDemoData()
            } else {
                hrvData = data
                analyzeHRV()
            }
        } else {
            loadDemoData()
        }
    }

    func loadDemoData() {
        hrvData = HealthKitService.generateDemoData(days: 7)
        analyzeHRV()
    }

    private func analyzeHRV() {
        guard !hrvData.isEmpty else {
            hrvTrend = .unknown
            return
        }

        let values = hrvData.map(\.value)
        weekAvgHRV = values.reduce(0, +) / Double(values.count)

        if let lastValue = values.last {
            todayHRV = lastValue
            let dropPercent = (weekAvgHRV - lastValue) / weekAvgHRV
            isStressDetected = dropPercent >= 0.20
        }

        if values.count >= 3 {
            let recentHalf = Array(values.suffix(values.count / 2 + 1))
            let olderHalf = Array(values.prefix(values.count / 2 + 1))
            let recentAvg = recentHalf.reduce(0, +) / Double(recentHalf.count)
            let olderAvg = olderHalf.reduce(0, +) / Double(olderHalf.count)
            let diff = (recentAvg - olderAvg) / olderAvg

            if diff > 0.05 {
                hrvTrend = .improving
            } else if diff < -0.05 {
                hrvTrend = .declining
            } else {
                hrvTrend = .stable
            }
        } else {
            hrvTrend = .stable
        }
    }

    func analyzePatterns(
        haltCheckIns: [HALTCheckIn],
        reflections: [EveningReflection],
        urgeSessions: [UrgeSurfSession],
        profile: UserProfile?,
        modelContext: ModelContext
    ) {
        var suggestions: [JITAISuggestion] = []
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentWeekday = calendar.component(.weekday, from: now)

        if isStressDetected {
            suggestions.append(JITAISuggestion(
                toolType: .urgeSurf,
                icon: "water.waves",
                title: "Stress Detected",
                message: "Your HRV dropped \(Int(((weekAvgHRV - todayHRV) / weekAvgHRV) * 100))% below average. Try surfing the urge.",
                color: Color(red: 0, green: 191/255, blue: 165/255)
            ))
        }

        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        let recentHALT = haltCheckIns.filter { $0.date >= thirtyDaysAgo }

        if !recentHALT.isEmpty {
            let avgLonely = Double(recentHALT.map(\.lonelyScore).reduce(0, +)) / Double(recentHALT.count)
            let avgTired = Double(recentHALT.map(\.tiredScore).reduce(0, +)) / Double(recentHALT.count)

            if avgLonely > 5 && avgTired > 5 {
                suggestions.append(JITAISuggestion(
                    toolType: .haltCheck,
                    icon: "hand.raised.fill",
                    title: "Check In With Yourself",
                    message: "You've been feeling lonely and tired lately. A HALT check might help.",
                    color: Color(red: 1, green: 215/255, blue: 64/255)
                ))
            }

            detectHighRiskPatterns(haltCheckIns: recentHALT, modelContext: modelContext)
        }

        let recentReflections = reflections.filter { $0.date >= thirtyDaysAgo }
        if !recentReflections.isEmpty {
            var weekdayTriggerCounts: [Int: Int] = [:]
            for r in recentReflections where !r.triggers.isEmpty {
                let wd = calendar.component(.weekday, from: r.date)
                weekdayTriggerCounts[wd, default: 0] += 1
            }
            if let (peakDay, count) = weekdayTriggerCounts.max(by: { $0.value < $1.value }), count >= 3 {
                if currentWeekday == peakDay {
                    let dayName = calendar.weekdaySymbols[peakDay - 1]
                    suggestions.append(JITAISuggestion(
                        toolType: .eveningReflection,
                        icon: "moon.stars.fill",
                        title: "\(dayName)s Are Tough",
                        message: "You tend to get triggered on \(dayName)s. Start your reflection early tonight.",
                        color: Color(red: 0.4, green: 0.5, blue: 0.9)
                    ))
                }
            }
        }

        if currentHour >= 17 && currentHour <= 22 {
            let hasBoredomTriggers = recentReflections.contains { $0.triggers.contains("Boredom") }
            if hasBoredomTriggers {
                suggestions.append(JITAISuggestion(
                    toolType: .coolingOff,
                    icon: "timer",
                    title: "Evening Boredom Alert",
                    message: "Evenings + boredom is your pattern. Set a cooling-off timer before any purchases.",
                    color: Color(red: 0, green: 191/255, blue: 165/255)
                ))
            }
        }

        if let reason = profile?.selectedReason, reason.lowercased().contains("gambl") {
            if currentWeekday == 6 || currentWeekday == 7 {
                suggestions.append(JITAISuggestion(
                    toolType: .breathing,
                    icon: "wind",
                    title: "Weekend Guard",
                    message: "Weekends are high-risk for gambling urges. Breathing exercises are ready.",
                    color: Color(red: 0.4, green: 0.6, blue: 1.0)
                ))
            }
        }

        jitaiSuggestions = Array(suggestions.prefix(3))
    }

    private func detectHighRiskPatterns(haltCheckIns: [HALTCheckIn], modelContext: ModelContext) {
        let calendar = Calendar.current
        var patternMap: [String: (day: Int, hour: Int, trigger: String, count: Int)] = [:]

        for checkIn in haltCheckIns {
            let day = calendar.component(.weekday, from: checkIn.date)
            let hour = calendar.component(.hour, from: checkIn.date)
            let maxScore = max(checkIn.hungryScore, checkIn.angryScore, checkIn.lonelyScore, checkIn.tiredScore)
            guard maxScore > 5 else { continue }

            let trigger: String
            if checkIn.hungryScore == maxScore { trigger = "Hungry" }
            else if checkIn.angryScore == maxScore { trigger = "Angry" }
            else if checkIn.lonelyScore == maxScore { trigger = "Lonely" }
            else { trigger = "Tired" }

            let key = "\(day)-\(hour)-\(trigger)"
            if let existing = patternMap[key] {
                patternMap[key] = (day, hour, trigger, existing.count + 1)
            } else {
                patternMap[key] = (day, hour, trigger, 1)
            }
        }

        for (_, pattern) in patternMap where pattern.count >= 2 {
            let p = HighRiskPattern(
                dayOfWeek: pattern.day,
                hourOfDay: pattern.hour,
                triggerType: pattern.trigger,
                frequency: pattern.count
            )
            modelContext.insert(p)
        }
    }

    func collectDailyCrisisData(
        haltCheckIns: [HALTCheckIn],
        urgeSessions: [UrgeSurfSession],
        profile: UserProfile?,
        modelContext: ModelContext
    ) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let todayHALT = haltCheckIns.filter { calendar.isDate($0.date, inSameDayAs: today) }
        let todayUrges = urgeSessions.filter { calendar.isDate($0.date, inSameDayAs: today) }

        let avgHungry = todayHALT.isEmpty ? 0 : todayHALT.map(\.hungryScore).reduce(0, +) / todayHALT.count
        let avgAngry = todayHALT.isEmpty ? 0 : todayHALT.map(\.angryScore).reduce(0, +) / todayHALT.count
        let avgLonely = todayHALT.isEmpty ? 0 : todayHALT.map(\.lonelyScore).reduce(0, +) / todayHALT.count
        let avgTired = todayHALT.isEmpty ? 0 : todayHALT.map(\.tiredScore).reduce(0, +) / todayHALT.count

        let dataPoint = CrisisRiskDataPoint(
            date: today,
            hrvAvg: weekAvgHRV,
            urgeFrequency: todayUrges.count,
            haltHungryScore: avgHungry,
            haltAngryScore: avgAngry,
            haltLonelyScore: avgLonely,
            haltTiredScore: avgTired,
            sleepHours: 0,
            streakActive: (profile?.currentStreak ?? 0) > 0,
            socialActivityCount: 0
        )
        modelContext.insert(dataPoint)
    }

    func saveStateOfMind(starRating: Int) async {
        let valence = HealthKitService.mapStarRatingToValence(starRating)
        if #available(iOS 18.0, *) {
            await healthService.saveStateOfMind(valence: valence)
        }
    }
}
