import SwiftUI
import SwiftData

struct FindPartnerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var partners: [AccountabilityPartner]
    @State private var matchingPhase: MatchingPhase = .intro
    @State private var progressValue: Double = 0
    @State private var matchedName = ""
    @State private var matchedStreak = 0

    private var profile: UserProfile? { profiles.first }

    private enum MatchingPhase {
        case intro
        case searching
        case matched
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                switch matchingPhase {
                case .intro:
                    introContent
                case .searching:
                    searchingContent
                case .matched:
                    matchedContent
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Find a Partner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var introContent: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Theme.teal.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.2.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.teal)
            }

            VStack(spacing: 8) {
                Text("Accountability Partner")
                    .font(Theme.headingFont(.title2))
                    .foregroundStyle(Theme.textPrimary)

                Text("We'll match you with someone on a similar journey. Weekly check-ins help you both stay on track.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 12) {
                matchCriteria("Similar financial goal", icon: "target")
                matchCriteria("Compatible streak length", icon: "flame.fill")
                matchCriteria("Weekly structured check-ins", icon: "calendar.badge.checkmark")
                matchCriteria("Fully anonymous & private", icon: "lock.fill")
            }
            .padding(16)
            .glassCard()

            Button {
                startMatching()
            } label: {
                Text("Find My Partner")
                    .font(.headline)
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.teal, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: matchingPhase)
            .accessibilityLabel("Start partner matching")
        }
    }

    private func matchCriteria(_ text: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Theme.teal)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary)
        }
    }

    private var searchingContent: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .strokeBorder(Theme.teal.opacity(0.2), lineWidth: 3)
                    .frame(width: 80, height: 80)
                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(Theme.teal, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.teal)
            }

            VStack(spacing: 8) {
                Text("Finding your partner...")
                    .font(Theme.headingFont(.title3))
                    .foregroundStyle(Theme.textPrimary)
                Text("Matching based on your goals and journey")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    private var matchedContent: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Theme.teal.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.teal)
            }

            VStack(spacing: 8) {
                Text("Partner Found!")
                    .font(Theme.headingFont(.title2))
                    .foregroundStyle(Theme.textPrimary)

                Text("Meet \(matchedName)")
                    .font(.title3)
                    .foregroundStyle(Theme.teal)

                HStack(spacing: 16) {
                    Label("\(matchedStreak)d streak", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.gold)
                    Label(profile?.selectedReason ?? "Wellness", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.accentGreen)
                }
                .padding(.top, 4)
            }

            Text("You'll receive weekly check-in reminders. Support each other through the journey!")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                let partner = AccountabilityPartner(
                    partnerName: matchedName,
                    selectedReason: profile?.selectedReason ?? "spend",
                    streakLength: matchedStreak
                )
                modelContext.insert(partner)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "hand.wave.fill")
                    Text("Say Hello")
                }
                .font(.headline)
                .foregroundStyle(Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.teal, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.success, trigger: matchedName)
            .accessibilityLabel("Accept partner match")
        }
    }

    private func startMatching() {
        withAnimation(.spring(response: 0.4)) {
            matchingPhase = .searching
        }

        matchedName = CommunityContent.generateAnonymousName()
        matchedStreak = Int.random(in: 3...45)

        withAnimation(.easeInOut(duration: 2.5)) {
            progressValue = 1.0
        }

        Task {
            try? await Task.sleep(for: .seconds(2.8))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                matchingPhase = .matched
            }
        }
    }
}
