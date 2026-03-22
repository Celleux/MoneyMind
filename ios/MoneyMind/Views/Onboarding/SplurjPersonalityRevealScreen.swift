import SwiftUI

struct SplurjPersonalityRevealScreen: View {
    let personality: MoneyPersonality
    let onNext: () -> Void

    @State private var iconScale: CGFloat = 0
    @State private var titleOpacity: Double = 0
    @State private var card1Offset: CGFloat = 60
    @State private var card1Opacity: Double = 0
    @State private var card2Offset: CGFloat = 60
    @State private var card2Opacity: Double = 0
    @State private var card3Offset: CGFloat = 60
    @State private var card3Opacity: Double = 0
    @State private var ctaOpacity: Double = 0
    @State private var confettiTriggered = false
    @State private var sharePulse = false

    private var watchOutTrait: String {
        switch personality {
        case .saver: "Over-saving can mean missing out on life"
        case .builder: "Analysis paralysis can slow your progress"
        case .hustler: "Impulse buys can eat your hard-earned gains"
        case .minimalist: "Avoiding all spending can mask deeper fears"
        case .generous: "Giving too much can leave you short"
        }
    }

    private var splurjPlan: String {
        switch personality {
        case .saver: "You're great at saving — Splurj will help you enjoy spending without guilt."
        case .builder: "You invest in your future — Splurj will sharpen your strategy with data."
        case .hustler: "You earn hard — Splurj will make sure impulse buys don't eat your hustle."
        case .minimalist: "You value simplicity — Splurj keeps your finances as clean as your lifestyle."
        case .generous: "Your heart is big — Splurj helps you give without going broke."
        }
    }

    var body: some View {
        ZStack {
            personality.color.opacity(0.08)
                .ignoresSafeArea()

            Theme.background.opacity(0.85)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 48)

                    Text("YOUR MONEY PERSONALITY")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                        .tracking(3)
                        .opacity(titleOpacity)

                    Spacer().frame(height: 28)

                    ZStack {
                        confettiBurst

                        Circle()
                            .fill(personality.color.opacity(0.12))
                            .frame(width: 110, height: 110)
                            .scaleEffect(iconScale * 1.1)

                        Image(systemName: personality.icon)
                            .font(.system(size: 52, weight: .medium))
                            .foregroundStyle(personality.color)
                            .scaleEffect(iconScale)
                    }
                    .frame(height: 130)

                    Spacer().frame(height: 20)

                    VStack(spacing: 8) {
                        Text("You're \(personalityArticle) \(personalityName)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(personality.color)
                            .opacity(titleOpacity)

                        Text(personality.description)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 32)
                            .opacity(titleOpacity)
                    }

                    Spacer().frame(height: 28)

                    VStack(spacing: 12) {
                        traitCard(
                            icon: "star.fill",
                            label: "Your Strength",
                            value: personality.traits.first ?? "",
                            color: Theme.accentGreen,
                            opacity: card1Opacity,
                            offset: card1Offset
                        )

                        traitCard(
                            icon: "exclamationmark.triangle.fill",
                            label: "Watch Out For",
                            value: watchOutTrait,
                            color: Theme.warning,
                            opacity: card2Opacity,
                            offset: card2Offset
                        )

                        traitCard(
                            icon: "sparkles",
                            label: "Your Splurj Plan",
                            value: splurjPlan,
                            color: Theme.teal,
                            opacity: card3Opacity,
                            offset: card3Offset
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 28)

                    VStack(spacing: 14) {
                        ShareLink(
                            item: shareText,
                            preview: SharePreview(
                                "My Money Personality",
                                image: Image(systemName: personality.icon)
                            )
                        ) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Share My Result")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(personality.color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(personality.color.opacity(0.12), in: .rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(personality.color.opacity(0.25), lineWidth: 1)
                            )
                            .scaleEffect(sharePulse ? 1.01 : 1.0)
                        }
                        .buttonStyle(PressableButtonStyle())

                        Button(action: onNext) {
                            HStack(spacing: 6) {
                                Text("See What This Costs You")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(Theme.accentGreen, in: .rect(cornerRadius: 14))
                        }
                        .buttonStyle(PressableButtonStyle())
                        .sensoryFeedback(.impact(weight: .medium), trigger: true)
                    }
                    .padding(.horizontal, 24)
                    .opacity(ctaOpacity)

                    Spacer().frame(height: 48)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .onAppear { runEntryAnimations() }
    }

    private var personalityName: String {
        personality.rawValue.replacingOccurrences(of: "The ", with: "")
    }

    private var personalityArticle: String {
        "a"
    }

    private var shareText: String {
        "I'm \(personality.rawValue) \(personalityEmoji)\n\n\(personality.traits.joined(separator: " · "))\n\n\(splurjPlan)\n\nDiscover yours at splurj.app"
    }

    private var personalityEmoji: String {
        switch personality {
        case .saver: "🌿"
        case .builder: "📈"
        case .hustler: "🔥"
        case .minimalist: "✨"
        case .generous: "💛"
        }
    }

    private func traitCard(icon: String, label: String, value: String, color: Color, opacity: Double, offset: CGFloat) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12), in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
                    .tracking(1.5)

                Text(value)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .lineSpacing(1)
            }

            Spacer()
        }
        .padding(16)
        .background(Theme.card, in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(color.opacity(0.15), lineWidth: 0.5)
        )
        .opacity(opacity)
        .offset(x: offset)
    }

    @ViewBuilder
    private var confettiBurst: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                let angle = Double(i) * (360.0 / 12.0)
                let rad = angle * .pi / 180
                let distance: CGFloat = confettiTriggered ? CGFloat.random(in: 50...90) : 0
                let colors: [Color] = [personality.color, Theme.gold, Theme.accentGreen, Theme.teal, Theme.accent]

                Circle()
                    .fill(colors[i % colors.count])
                    .frame(width: CGFloat.random(in: 5...9), height: CGFloat.random(in: 5...9))
                    .offset(
                        x: cos(rad) * distance,
                        y: sin(rad) * distance
                    )
                    .opacity(confettiTriggered ? 0 : 1)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.5).delay(Double(i) * 0.02),
                        value: confettiTriggered
                    )
            }
        }
    }

    private func runEntryAnimations() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            iconScale = 1.0
        }

        confettiTriggered = true

        withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
            titleOpacity = 1
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5)) {
            card1Opacity = 1
            card1Offset = 0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.65)) {
            card2Opacity = 1
            card2Offset = 0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.8)) {
            card3Opacity = 1
            card3Offset = 0
        }

        withAnimation(.easeOut(duration: 0.4).delay(1.0)) {
            ctaOpacity = 1
        }

        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.2)) {
            sharePulse = true
        }
    }
}
