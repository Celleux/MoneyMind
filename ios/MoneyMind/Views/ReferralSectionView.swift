import SwiftUI
import SwiftData

struct ReferralSectionView: View {
    let referralCode: String
    let referralCount: Int
    @State private var copied = false
    @State private var showShareSheet = false

    private var shareText: String {
        "Join me on Splurj — build a healthier relationship with money! Use my code: \(referralCode)\n\nhttps://splurj.app/invite/\(referralCode)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.badge.plus")
                    .foregroundStyle(Theme.accentGreen)
                Text("Invite Friends")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                if referralCount > 0 {
                    Text("\(referralCount) invited")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.accentGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.accentGreen.opacity(0.12), in: .capsule)
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Code")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(referralCode)
                        .font(.system(.title3, design: .monospaced, weight: .bold))
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
                        .font(.subheadline)
                        .foregroundStyle(copied ? Theme.accentGreen : Theme.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(Theme.cardSurface.opacity(0.6), in: .circle)
                }
                .buttonStyle(PressableButtonStyle())
                .sensoryFeedback(.selection, trigger: copied)
            }
            .padding(14)
            .background(.white.opacity(0.03), in: .rect(cornerRadius: 12))

            Button {
                showShareSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                    Text("Invite a Friend")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: showShareSheet)

            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.gold)
                Text("Friends get 7 days of Premium free. You earn the Connector badge + 500 XP!")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(20)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Theme.accentGreen.opacity(0.1), lineWidth: 1)
        )
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
    }
}
