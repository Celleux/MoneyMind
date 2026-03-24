import SwiftUI

struct ChallengeDetailSheet: View {
    let challenge: ChallengeGroup
    @Environment(\.dismiss) private var dismiss
    @State private var joinTrigger = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerSection
                statsRow
                progressSection
                descriptionSection
                Spacer()
                actionButton
            }
            .padding(20)
            .navigationTitle(challenge.hashtag)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.accentGreen.opacity(0.12))
                    .frame(width: 64, height: 64)
                Image(systemName: challenge.iconName)
                    .font(Typography.displayMedium)
                    .foregroundStyle(Theme.accentGreen)
            }

            Text(challenge.name)
                .font(Typography.displaySmall)
                .foregroundStyle(Theme.textPrimary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(
                value: "\(challenge.participantCount)",
                label: "Participants",
                icon: "person.2.fill"
            )
            Divider()
                .frame(height: 32)
                .background(Theme.textSecondary.opacity(0.2))
            statItem(
                value: "\(challenge.daysRemaining)",
                label: "Days Left",
                icon: "clock.fill"
            )
            Divider()
                .frame(height: 32)
                .background(Theme.textSecondary.opacity(0.2))
            statItem(
                value: challenge.collectiveSavings.formatted(.currency(code: "USD").precision(.fractionLength(0))),
                label: "Saved",
                icon: "dollarsign.circle.fill"
            )
        }
        .padding(16)
        .splurjCard(.elevated)
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.accentGreen)
            Text(value)
                .font(Typography.headingSmall)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var progressSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Community Progress")
                    .font(Typography.headingSmall)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(Int(challenge.progress * 100))%")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.accentGreen)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.cardSurface)
                        .frame(height: 10)
                    Capsule()
                        .fill(Theme.accentGradient)
                        .frame(width: geo.size.width * challenge.progress, height: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Text("$0")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text(challenge.savingsGoal.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(16)
        .splurjCard(.elevated)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(Typography.headingSmall)
                .foregroundStyle(Theme.textPrimary)
            Text(challenge.groupDescription)
                .font(Typography.bodyMedium)
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButton: some View {
        Group {
            if challenge.isJoined {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("You're In!")
                }
                .font(Typography.headingMedium)
                .foregroundStyle(Theme.accentGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.accentGreen.opacity(0.12), in: .rect(cornerRadius: 12))
            } else {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        challenge.isJoined = true
                        challenge.participantCount += 1
                        joinTrigger += 1
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "flag.fill")
                        Text("Join Challenge")
                    }
                    .font(Typography.headingMedium)
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
                .sensoryFeedback(.impact(weight: .heavy), trigger: joinTrigger)
                .accessibilityLabel("Join \(challenge.name)")
            }
        }
    }
}
