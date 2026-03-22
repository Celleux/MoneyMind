import SwiftUI
import SwiftData

struct SiriCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyPledge.date, order: .reverse) private var pledges: [DailyPledge]
    @Query private var profiles: [UserProfile]
    @State private var completed = false
    @State private var checkScale: CGFloat = 0

    private var profile: UserProfile? { profiles.first }

    private var todayPledge: DailyPledge? {
        let today = Calendar.current.startOfDay(for: Date())
        return pledges.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    private let quotes: [String] = [
        "Every mindful moment is a victory.",
        "Progress, not perfection.",
        "You are stronger than any impulse.",
        "Small steps lead to big changes.",
        "Today is a fresh start."
    ]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 32) {
                HStack {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                if todayPledge != nil || completed {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Theme.accentGreen)

                        Text("Already checked in today!")
                            .font(Theme.headingFont(.title2))
                            .foregroundStyle(Theme.textPrimary)

                        Text("Your pledge is active. Keep going!")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else {
                    VStack(spacing: 24) {
                        HStack(spacing: 8) {
                            Image(systemName: "mic.fill")
                                .font(.caption)
                                .foregroundStyle(Theme.teal)
                            Text("Siri Check-In")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Theme.teal)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(Theme.teal.opacity(0.1), in: .capsule)

                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Theme.accentGradient)

                        Text("Daily Pledge")
                            .font(Theme.headingFont(.title2))
                            .foregroundStyle(Theme.textPrimary)

                        Text("\"I pledge to be mindful with my money today.\"")
                            .font(.subheadline.italic())
                            .foregroundStyle(Theme.textPrimary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Text(quotes.randomElement() ?? "")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)

                        Button {
                            completePledge()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                Text("I Pledge")
                                    .font(.headline)
                            }
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
                        }
                        .buttonStyle(PressableButtonStyle())
                        .padding(.horizontal, 32)
                    }
                }

                Spacer()

                if todayPledge != nil || completed {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .sensoryFeedback(.success, trigger: completed)
    }

    private func completePledge() {
        let pledge = DailyPledge()
        modelContext.insert(pledge)

        if let profile {
            profile.xpPoints += 25
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            completed = true
        }
    }
}
