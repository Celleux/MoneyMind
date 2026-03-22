import AppIntents
import SwiftData
import SwiftUI

struct GamblingUrgeIntent: AppIntent {
    static var title: LocalizedStringResource = "I'm Having an Urge"
    static var description = IntentDescription("Opens the Urge Surf breathing exercise when you feel a gambling or spending urge.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(name: .siriUrgeDetected, object: nil)
        }
        return .result()
    }
}

struct SplurjCheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Daily Check In"
    static var description = IntentDescription("Opens your daily pledge and check-in.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(name: .siriCheckInRequested, object: nil)
        }
        return .result()
    }
}

struct CheckSavingsIntent: AppIntent {
    static var title: LocalizedStringResource = "Check My Savings"
    static var description = IntentDescription("Tells you how much money you've saved with Splurj.")

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let container = try ModelContainer(for: UserProfile.self)
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try context.fetch(descriptor)
        let saved = profiles.first?.totalSaved ?? 0
        let formatted = saved.formatted(.currency(code: "USD").precision(.fractionLength(0)))
        let message = "You've saved \(formatted) with Splurj. Keep going!"
        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }
}

struct SplurjShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GamblingUrgeIntent(),
            phrases: [
                "I want to gamble in \(.applicationName)",
                "I have an urge in \(.applicationName)",
                "Help me with an urge in \(.applicationName)"
            ],
            shortTitle: "Urge Surf",
            systemImageName: "water.waves"
        )
        AppShortcut(
            intent: SplurjCheckInIntent(),
            phrases: [
                "\(.applicationName) check in",
                "Check in with \(.applicationName)",
                "Daily pledge in \(.applicationName)"
            ],
            shortTitle: "Daily Check In",
            systemImageName: "checkmark.circle"
        )
        AppShortcut(
            intent: CheckSavingsIntent(),
            phrases: [
                "Check my savings in \(.applicationName)",
                "How much have I saved in \(.applicationName)",
                "What are my savings in \(.applicationName)"
            ],
            shortTitle: "Check Savings",
            systemImageName: "dollarsign.circle"
        )
    }
}

extension Notification.Name {
    static let siriUrgeDetected = Notification.Name("siriUrgeDetected")
    static let siriCheckInRequested = Notification.Name("siriCheckInRequested")
    static let transactionSaved = Notification.Name("transactionSaved")
}
