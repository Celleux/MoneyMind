import SwiftUI
import SwiftData

struct DailyPledgeCard: View {
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

    private var shouldShow: Bool {
        todayPledge == nil && !completed
    }

    private let quote = MotivationalQuotes.quoteForToday()

    var body: some View {
        if shouldShow {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "sun.max.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.gold)
                    Text("Daily Pledge")
                        .font(Theme.headingFont(.headline))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                }

                Text("I pledge to be mindful with my money today.")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)

                Text("\"\(quote)\"")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .italic()
                    .lineSpacing(3)

                Button {
                    completePledge()
                } label: {
                    HStack(spacing: 10) {
                        if completed {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .scaleEffect(checkScale)
                        }
                        Text(completed ? "Pledged!" : "Take the Pledge")
                            .font(.headline)
                    }
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(PressableButtonStyle())
                .sensoryFeedback(.success, trigger: completed)
                .accessibilityLabel("Take the daily pledge")
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Theme.gold.opacity(0.08), Theme.cardSurface],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Theme.gold.opacity(0.15), lineWidth: 1)
            )
        }
    }

    private func completePledge() {
        let pledge = DailyPledge(quoteShown: quote, completed: true)
        modelContext.insert(pledge)

        if let profile {
            profile.xpPoints += XPAction.dailyCheckIn.xpValue
            profile.totalConsciousChoices += 1
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            completed = true
            checkScale = 1.2
        }
        withAnimation(.spring(response: 0.3).delay(0.2)) {
            checkScale = 1.0
        }
    }
}
