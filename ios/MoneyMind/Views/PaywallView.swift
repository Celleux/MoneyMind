import SwiftUI
import SwiftData
import PhosphorSwift

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PremiumManager.self) private var premiumManager
    @Query private var quizResults: [QuizResult]
    @Query private var profiles: [UserProfile]
    @Query private var impulseLogs: [ImpulseLog]
    @State private var selectedPlan: PlanType = .annual
    @State private var featuresVisible: [Bool] = Array(repeating: false, count: 5)
    @State private var iconPulse: Bool = false
    @State private var ctaTapped: Bool = false
    @State private var planTapped: Bool = false

    private var personality: MoneyPersonality {
        quizResults.first?.personality ?? .builder
    }

    private var profile: UserProfile? { profiles.first }

    private var totalSaved: Double {
        impulseLogs.reduce(0) { $0 + $1.amount }
    }

    private var totalWins: Int {
        impulseLogs.count
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    heroSection
                    trialStatsCard
                    featureList
                    socialProof
                    pricingCards
                    ctaSection
                    footerLinks
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)

            closeButton
        }
        .interactiveDismissDisabled()
        .onAppear { animateFeatures() }
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            PhIcon.x
                .frame(width: 16, height: 16)
                .foregroundStyle(Theme.textMuted)
                .frame(width: 32, height: 32)
                .background(Theme.elevated, in: .circle)
        }
        .padding(.top, 12)
        .padding(.trailing, 20)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 96, height: 96)
                    .scaleEffect(iconPulse ? 1.15 : 1.0)
                    .opacity(iconPulse ? 0.4 : 0.8)

                Circle()
                    .fill(Theme.accent.opacity(0.2))
                    .frame(width: 72, height: 72)

                PhIcon.crownFill
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Theme.accent)
                    .shadow(color: Theme.accent.opacity(0.5), radius: 8)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    iconPulse = true
                }
            }

            Text("Your 3-Day Trial\nHas Ended")
                .font(Typography.displayMedium)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Text("Keep all the tools that are helping you save")
                .font(Typography.bodyMedium)
                .foregroundStyle(Theme.accent)
        }
    }

    // MARK: - Trial Stats

    private var trialStatsCard: some View {
        VStack(spacing: 12) {
            let currencySymbol = profile?.currencySymbol ?? "$"
            Text("In 3 days, you've saved \(currencySymbol)\(String(format: "%.0f", totalSaved)) and logged \(totalWins) win\(totalWins == 1 ? "" : "s").")
                .font(Typography.headingSmall)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Don't lose your momentum.")
                .font(Typography.bodySmall)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .splurjCard(.hero)
    }

    // MARK: - Features

    private var featureList: some View {
        VStack(spacing: 0) {
            ForEach(Array(premiumFeatures.enumerated()), id: \.offset) { index, feature in
                featureRow(feature, visible: featuresVisible[index])
            }
        }
    }

    private func featureRow(_ feature: PremiumFeature, visible: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: feature.icon)
                    .font(Typography.headingMedium)
                    .foregroundStyle(Theme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.name)
                    .font(Typography.headingMedium)
                    .foregroundStyle(.white)

                Text(feature.subtitle)
                    .font(Typography.bodySmall)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            PhIcon.checkCircleFill
                .frame(width: 20, height: 20)
                .foregroundStyle(Theme.accent.opacity(0.6))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .offset(x: visible ? 0 : -40)
        .opacity(visible ? 1 : 0)
    }

    // MARK: - Social Proof

    private var socialProof: some View {
        VStack(spacing: 12) {
            HStack(spacing: -10) {
                ForEach(avatarColors.indices, id: \.self) { i in
                    Circle()
                        .fill(avatarColors[i])
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle().strokeBorder(.white.opacity(0.2), lineWidth: 1.5)
                        )
                        .zIndex(Double(5 - i))
                }

                Text("+10,000")
                    .font(Typography.labelMedium)
                    .foregroundStyle(.white)
                    .padding(.leading, 16)
            }

            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { _ in
                    PhIcon.starFill
                        .frame(width: 14, height: 14)
                        .foregroundStyle(Theme.gold)
                }
                Text("4.8")
                    .font(Typography.labelMedium)
                    .foregroundStyle(Theme.gold)
                Text("(2,340 reviews)")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Theme.textMuted)
            }

            Text("Join 10,000+ Splurj Premium members")
                .font(Typography.bodySmall)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Pricing

    private var pricingCards: some View {
        HStack(spacing: 12) {
            planCard(
                type: .monthly,
                price: "$4.99",
                period: "/month",
                badge: nil,
                savingsPill: nil
            )

            planCard(
                type: .annual,
                price: "$39.99",
                period: "/year",
                badge: "BEST VALUE",
                savingsPill: "Save 33%"
            )
        }
        .sensoryFeedback(.selection, trigger: planTapped)
    }

    private func planCard(
        type: PlanType,
        price: String,
        period: String,
        badge: String?,
        savingsPill: String?
    ) -> some View {
        let isSelected = selectedPlan == type

        return Button {
            withAnimation(Theme.spring) { selectedPlan = type }
            planTapped.toggle()
        } label: {
            VStack(spacing: 10) {
                if let badge {
                    Text(badge)
                        .font(Typography.labelSmall)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.goldGradient, in: .capsule)
                } else {
                    Spacer().frame(height: 22)
                }

                Text(type == .monthly ? "Monthly" : "Annual")
                    .font(Typography.headingSmall)
                    .foregroundStyle(Theme.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(price)
                        .font(Typography.displaySmall)
                        .foregroundStyle(.white)
                    Text(period)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Theme.textMuted)
                }

                if type == .annual {
                    Text("$3.33/mo")
                        .font(Typography.bodySmall)
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    Spacer().frame(height: 16)
                }

                if let savingsPill {
                    Text(savingsPill)
                        .font(Typography.labelSmall)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.accent, in: .capsule)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .fill(Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(
                        isSelected ? Theme.accent : Theme.border,
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
            .shadow(
                color: isSelected ? Theme.accent.opacity(0.2) : .clear,
                radius: 12, y: 4
            )
            .scaleEffect(isSelected && type == .annual ? 1.02 : 1.0)
            .animation(Theme.spring, value: isSelected)
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: 10) {
            Button {
                ctaTapped.toggle()
                premiumManager.unlock()
            } label: {
                Text("Continue My Journey")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
            .sensoryFeedback(.impact(weight: .medium), trigger: ctaTapped)

            Text(selectedPlan == .annual
                 ? "$39.99/year. Cancel anytime."
                 : "$4.99/month. Cancel anytime.")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textMuted)
        }
    }

    // MARK: - Footer

    private var footerLinks: some View {
        VStack(spacing: 12) {
            Button {
                premiumManager.restore()
            } label: {
                Text("Restore Purchases")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Theme.textMuted)
            }

            HStack(spacing: 16) {
                Button { } label: {
                    Text("Terms of Use")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textMuted.opacity(0.7))
                }
                Button { } label: {
                    Text("Privacy Policy")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textMuted.opacity(0.7))
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Animation

    private func animateFeatures() {
        for i in 0..<premiumFeatures.count {
            withAnimation(Theme.spring.delay(Double(i) * 0.15 + 0.3)) {
                featuresVisible[i] = true
            }
        }
    }

    // MARK: - Data

    private let avatarColors: [Color] = [
        Theme.accent.opacity(0.8),
        Theme.accent.opacity(0.6),
        Theme.accent.opacity(0.4),
        Theme.gold.opacity(0.6),
        Theme.gold.opacity(0.4)
    ]

    private let premiumFeatures: [PremiumFeature] = [
        PremiumFeature(icon: "sparkles", name: "Full Splurj Wrapped", subtitle: "Complete monthly & annual story recaps"),
        PremiumFeature(icon: "eye.slash.fill", name: "Ghost Budget", subtitle: "Hidden budgets only you can see"),
        PremiumFeature(icon: "trophy.fill", name: "Unlimited Challenges", subtitle: "Access every savings challenge"),
        PremiumFeature(icon: "chart.bar.xaxis.ascending", name: "Premium Analytics", subtitle: "Deep spending insights & trends"),
        PremiumFeature(icon: "person.2.fill", name: "Couple Mode", subtitle: "Shared budgets & goals with a partner")
    ]
}

nonisolated enum PlanType: Sendable {
    case monthly, annual
}

private struct PremiumFeature {
    let icon: String
    let name: String
    let subtitle: String
}
