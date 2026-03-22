import SwiftUI
import ActivityKit

struct CoolingOffLiveActivityCompactView: View {
    let endTime: Date

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Theme.teal)

            Text(timerInterval: Date.now...endTime, countsDown: true)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }
}

struct CoolingOffLiveActivityExpandedView: View {
    let endTime: Date
    let triggerReason: String
    let motivationQuote: String

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundStyle(Theme.teal)
                Text("Cooling Off")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text(timerInterval: Date.now...endTime, countsDown: true)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.accentGreen)
                    .monospacedDigit()
            }

            if !triggerReason.isEmpty {
                Text(triggerReason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text("Stay strong — this urge will pass")
                .font(.caption2)
                .foregroundStyle(Theme.teal)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
    }
}

struct CoolingOffLockScreenView: View {
    let endTime: Date
    let motivationQuote: String

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.title3)
                    .foregroundStyle(Theme.teal)

                Text("Cooling Off Timer")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()
            }

            Text(timerInterval: Date.now...endTime, countsDown: true)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.accentGreen)
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .center)

            Text(motivationQuote)
                .font(.subheadline.italic())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(16)
    }
}

enum CoolingOffActivityManager {
    static func startActivity(endTime: Date, triggerReason: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = CoolingOffAttributes(
            endTime: endTime,
            triggerReason: triggerReason
        )
        let state = CoolingOffAttributes.ContentState(
            motivationQuote: "This urge is temporary. You are permanent."
        )

        do {
            let _ = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: endTime)
            )
        } catch {
            // Activity could not be started
        }
    }

    static func endAllActivities() {
        Task {
            let finalState = CoolingOffAttributes.ContentState(
                motivationQuote: "You made it! The urge has passed."
            )
            for activity in Activity<CoolingOffAttributes>.activities {
                await activity.end(
                    .init(state: finalState, staleDate: nil),
                    dismissalPolicy: .default
                )
            }
        }
    }

    static func updateQuote(_ quote: String) {
        Task {
            let state = CoolingOffAttributes.ContentState(motivationQuote: quote)
            for activity in Activity<CoolingOffAttributes>.activities {
                await activity.update(.init(state: state, staleDate: nil))
            }
        }
    }
}
