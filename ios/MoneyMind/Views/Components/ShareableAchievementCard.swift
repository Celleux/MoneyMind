import SwiftUI

nonisolated enum AchievementCardType: Sendable {
    case streak(days: Int)
    case saved(amount: Double)
    case levelUp(level: Int)
    case quest(name: String)
    case collection(collected: Int, total: Int, setName: String)
    case streakMilestone(days: Int)

    var headline: String {
        switch self {
        case .streak(let days):
            return "I'm on a \(days)-day savings streak on Splurj!"
        case .saved(let amount):
            return "I saved \(amount.formatted(.currency(code: "USD").precision(.fractionLength(0)))) this month with Splurj!"
        case .levelUp(let level):
            return "Just hit Level \(level) on Splurj!"
        case .quest(let name):
            return "Completed \(name)!"
        case .collection(let collected, let total, let setName):
            return "Collected \(collected)/\(total) cards in the \(setName) set!"
        case .streakMilestone(let days):
            return "\(days)-day streak milestone!"
        }
    }

    var emoji: String {
        switch self {
        case .streak: return "🔥"
        case .saved: return "💰"
        case .levelUp: return "⬆️"
        case .quest: return "✅"
        case .collection: return "🃏"
        case .streakMilestone: return "🏆"
        }
    }

    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .saved: return "dollarsign.circle.fill"
        case .levelUp: return "arrow.up.circle.fill"
        case .quest: return "checkmark.seal.fill"
        case .collection: return "rectangle.stack.fill"
        case .streakMilestone: return "trophy.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .streak, .streakMilestone: return Color(hex: 0xFB923C)
        case .saved: return Theme.accent
        case .levelUp: return Theme.neonGold
        case .quest: return Theme.neonEmerald
        case .collection: return Theme.neonPurple
        }
    }
}

struct ShareableAchievementCard: View {
    let type: AchievementCardType
    let level: Int
    let archetypeName: String
    let referralCode: String

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                headerBadge

                achievementIcon

                VStack(spacing: 10) {
                    Text(type.emoji)
                        .font(Typography.displayMedium)

                    Text(type.headline)
                        .font(Typography.displaySmall)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 24)

                statsPill
            }

            Spacer()

            watermark
                .padding(.bottom, 36)
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .background(cardBackground)
        .clipShape(.rect(cornerRadius: 24))
    }

    private var headerBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "leaf.fill")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.accent)
            Text("SPLURJ")
                .font(Typography.labelSmall)
                .foregroundStyle(.white.opacity(0.6))
                .tracking(3)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial.opacity(0.3), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.1), lineWidth: 0.5))
    }

    private var achievementIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [type.accentColor.opacity(0.3), type.accentColor.opacity(0.05)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)

            Circle()
                .fill(type.accentColor.opacity(0.12))
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .strokeBorder(type.accentColor.opacity(0.3), lineWidth: 1)
                )

            Image(systemName: type.icon)
                .font(Typography.displayMedium)
                .foregroundStyle(type.accentColor)
        }
    }

    private var statsPill: some View {
        HStack(spacing: 16) {
            statItem(value: "Lv.\(level)", label: "Level")
            dividerLine
            statItem(value: archetypeName, label: "Archetype")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial.opacity(0.2), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
        )
        .padding(.horizontal, 40)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(Typography.headingSmall)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(Typography.labelSmall)
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(.white.opacity(0.1))
            .frame(width: 1, height: 28)
    }

    private var watermark: some View {
        VStack(spacing: 6) {
            Text("splurj.app/join?ref=\(referralCode)")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(type.accentColor.opacity(0.7))

            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(Theme.accent)
                Text("Download Splurj")
                    .font(Typography.labelMedium)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text("Don't splurge. Splurj.")
                .font(Typography.labelSmall)
                .foregroundStyle(.white.opacity(0.25))
        }
    }

    private var cardBackground: some View {
        ZStack {
            Theme.background

            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    .clear, type.accentColor.opacity(0.12), .clear,
                    Theme.accent.opacity(0.06), .clear, type.accentColor.opacity(0.08),
                    .clear, Theme.neonGold.opacity(0.06), .clear
                ]
            )

            RadialGradient(
                colors: [type.accentColor.opacity(0.15), .clear],
                center: .center,
                startRadius: 30,
                endRadius: 300
            )
        }
    }

    @MainActor
    func renderImage() -> UIImage? {
        ShareCardRenderer.render(self)
    }
}

struct ShareAchievementButton: View {
    let type: AchievementCardType
    let level: Int
    let archetypeName: String
    let referralCode: String
    var style: ShareButtonStyle = .pill

    @AppStorage("totalShares") private var totalShares: Int = 0
    @State private var shareImage: UIImage?
    @State private var showShareSheet: Bool = false

    var body: some View {
        Button {
            let card = ShareableAchievementCard(
                type: type,
                level: level,
                archetypeName: archetypeName,
                referralCode: referralCode
            )
            shareImage = card.renderImage()
            if shareImage != nil {
                totalShares += 1
                showShareSheet = true
            }
        } label: {
            switch style {
            case .pill:
                pillLabel
            case .compact:
                compactLabel
            case .icon:
                iconLabel
            }
        }
        .buttonStyle(SplurjButtonStyle(variant: .secondary, size: .medium))
        .accessibilityLabel("Share achievement")
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }

    private var pillLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "square.and.arrow.up")
                .font(Typography.headingSmall)
            Text("Share")
                .font(Typography.headingSmall)
        }
        .foregroundStyle(Theme.textPrimary)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Theme.elevated, in: .capsule)
        .overlay(Capsule().strokeBorder(type.accentColor.opacity(0.2), lineWidth: 1))
    }

    private var compactLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "square.and.arrow.up")
                .font(Typography.labelMedium)
            Text("Share")
                .font(Typography.labelMedium)
        }
        .foregroundStyle(type.accentColor)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(type.accentColor.opacity(0.12), in: .capsule)
    }

    private var iconLabel: some View {
        Image(systemName: "square.and.arrow.up")
            .font(Typography.headingMedium)
            .foregroundStyle(Theme.textSecondary)
            .frame(width: 36, height: 36)
            .background(Theme.elevated, in: Circle())
    }

    enum ShareButtonStyle {
        case pill, compact, icon
    }
}
