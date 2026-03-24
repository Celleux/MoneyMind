import SwiftUI
import SwiftData

struct ReferralSectionView: View {
    let referralCode: String
    let referralCount: Int
    @State private var copied = false
    @State private var showShareSheet = false

    // TODO: Implement Universal Links with server backend
    private var referralLink: String {
        "https://splurj.app/join?ref=\(referralCode)&utm_source=app&utm_medium=referral&utm_campaign=invite"
    }

    private var shareText: String {
        "Join me on Splurj — build a healthier relationship with money! Use my code: \(referralCode)\n\n\(referralLink)"
    }

    private var nextMilestone: (target: Int, label: String)? {
        if referralCount < 1 {
            return (1, "Invite your first friend")
        } else if referralCount < 5 {
            return (5, "Unlock Connector card set")
        } else if referralCount < 10 {
            return (10, "Unlock 1 month free Premium")
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.badge.plus")
                    .foregroundStyle(Theme.accentGreen)
                Text("Invite Friends")
                    .font(Typography.headingMedium)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                if referralCount > 0 {
                    Text("\(referralCount) invited")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.accentGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.accentGreen.opacity(0.12), in: .capsule)
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Code")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textSecondary)
                    Text(referralCode)
                        .font(Typography.moneyMedium)
                        .foregroundStyle(Theme.textPrimary)
                }

                Spacer()

                Button {
                    UIPasteboard.general.string = referralCode
                    withAnimation(.spring(response: 0.3)) { copied = true }
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation { copied = false }
                    }
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc.fill")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(copied ? Theme.accentGreen : Theme.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(Theme.cardSurface.opacity(0.6), in: .circle)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: copied)
            }
            .padding(14)
            .background(.white.opacity(0.03), in: .rect(cornerRadius: 12))

            if let milestone = nextMilestone {
                referralProgressBar(current: referralCount, target: milestone.target, label: milestone.label)
            }

            Button {
                showShareSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(Typography.headingSmall)
                    Text("Invite a Friend")
                        .font(Typography.headingSmall)
                }
                .foregroundStyle(Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
            .sensoryFeedback(.impact(weight: .medium), trigger: showShareSheet)

            rewardsBreakdown
        }
        .padding(20)
        .splurjCard(.hero)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
    }

    private func referralProgressBar(current: Int, target: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(current)/\(target)")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.accent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.elevated)
                        .frame(height: 6)

                    Capsule()
                        .fill(Theme.accentGradient)
                        .frame(width: geo.size.width * min(1.0, CGFloat(current) / CGFloat(target)), height: 6)
                        .shadow(color: Theme.accent.opacity(0.4), radius: 4)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background(.white.opacity(0.02), in: .rect(cornerRadius: 10))
    }

    private var rewardsBreakdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "gift.fill")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.gold)
                Text("Rewards for each referral")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
            }

            HStack(spacing: 10) {
                ReferralRewardPill(icon: "star.fill", text: "+500 XP", color: Theme.neonPurple)
                ReferralRewardPill(icon: "creditcard.fill", text: "+3 Cards", color: Theme.accent)
                ReferralRewardPill(icon: "crown.fill", text: "+7 Days", color: Theme.gold)
            }

            Text("Your friend also gets 7 days of Premium free!")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textMuted)
        }
    }
}

private struct ReferralRewardPill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(Typography.labelSmall)
                .foregroundStyle(color)
            Text(text)
                .font(Typography.labelSmall)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(color.opacity(0.12), in: .capsule)
    }
}
