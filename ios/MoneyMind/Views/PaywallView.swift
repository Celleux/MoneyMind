import SwiftUI
import SwiftData

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var quizResults: [QuizResult]
    @State private var selectedPlan: PlanType = .annual
    @State private var featuresVisible: [Bool] = Array(repeating: false, count: 5)
    @State private var iconPulse: Bool = false
    @State private var ctaTapped: Bool = false
    @State private var planTapped: Bool = false

    private var personality: MoneyPersonality {
        quizResults.first?.personality ?? .builder
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    heroSection
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
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .bold))
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
                    .fill(personality.color.opacity(0.12))
                    .frame(width: 96, height: 96)
                    .scaleEffect(iconPulse ? 1.15 : 1.0)
                    .opacity(iconPulse ? 0.4 : 0.8)

                Circle()
                    .fill(personality.color.opacity(0.2))
                    .frame(width: 72, height: 72)

                Image(systemName: "crown.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(personality.color)
                    .shadow(color: personality.color.opacity(0.5), radius: 8)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    iconPulse = true
                }
            }

            Text("Unlock Your Full\nFinancial Potential")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Text("As \(personality.rawValue), you need these tools")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(personality.color)
        }
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
                    .fill(personality.color.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: feature.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(personality.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(feature.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(personality.color.opacity(0.6))
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
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.leading, 16)
            }

            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.gold)
                }
                Text("4.8")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.gold)
                Text("(2,340 reviews)")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textMuted)
            }

            Text("Join 10,000+ MoneyMind Premium members")
                .font(.system(size: 13, weight: .medium))
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
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.goldGradient, in: .capsule)
                } else {
                    Spacer().frame(height: 22)
                }

                Text(type == .monthly ? "Monthly" : "Annual")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(price)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(period)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textMuted)
                }

                if type == .annual {
                    Text("$3.33/mo")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    Spacer().frame(height: 16)
                }

                if let savingsPill {
                    Text(savingsPill)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.success, in: .capsule)
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
                        isSelected ? personality.color : Theme.border,
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
            .shadow(
                color: isSelected ? personality.color.opacity(0.2) : .clear,
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
            } label: {
                Text("Start 7-Day Free Trial")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(personality.color, in: .rect(cornerRadius: Theme.Radius.button))
                    .shadow(color: personality.color.opacity(0.3), radius: 12, y: 6)
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: ctaTapped)

            Text(selectedPlan == .annual
                 ? "Then $39.99/year. Cancel anytime."
                 : "Then $4.99/month. Cancel anytime.")
                .font(.system(size: 11))
                .foregroundStyle(Theme.textMuted)
        }
    }

    // MARK: - Footer

    private var footerLinks: some View {
        VStack(spacing: 12) {
            Button { } label: {
                Text("Restore Purchases")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textMuted)
            }

            HStack(spacing: 16) {
                Button { } label: {
                    Text("Terms of Use")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textMuted.opacity(0.7))
                }
                Button { } label: {
                    Text("Privacy Policy")
                        .font(.system(size: 11))
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
        Color(hex: 0x6C5CE7),
        Color(hex: 0x00D2FF),
        Color(hex: 0x00E676),
        Color(hex: 0xFF9100),
        Color(hex: 0xFFD700)
    ]

    private let premiumFeatures: [PremiumFeature] = [
        PremiumFeature(icon: "sparkles", name: "Full Money Wrapped", subtitle: "Complete monthly & annual story recaps"),
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
