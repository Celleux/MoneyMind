import SwiftUI

struct SocialProofScreen: View {
    let personality: MoneyPersonality
    let onNext: () -> Void

    @State private var appeared = false
    @State private var animatedUsers: Double = 0
    @State private var animatedSaved: Double = 0
    @State private var animatedPercent: Double = 0

    private var personalityName: String {
        personality.rawValue.replacingOccurrences(of: "The ", with: "")
    }

    private var personalityUserCount: String {
        switch personality {
        case .saver: "3,124"
        case .builder: "2,518"
        case .hustler: "2,847"
        case .minimalist: "1,963"
        case .generous: "2,395"
        }
    }

    private let testimonials: [(quote: String, author: String, type: String, emoji: String)] = [
        (
            "I'm a Hustler type and this app finally made me stop impulse buying sneakers. Saved $340 in my first month.",
            "@jordan_k",
            "Hustler",
            "🔥"
        ),
        (
            "The personality quiz was scarily accurate. As a Generous type, I kept giving money I didn't have. Splurj helped me set boundaries.",
            "@maya.r",
            "Generous",
            "💜"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 48)

                VStack(spacing: 8) {
                    Text("You're Not Alone")
                        .font(Theme.headingFont(.title))
                        .foregroundStyle(Theme.textPrimary)

                    Text("Join thousands taking control of\ntheir financial wellbeing")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer().frame(height: 28)

                VStack(spacing: 14) {
                    statRow(
                        value: formatAnimatedNumber(animatedUsers, target: 12847),
                        label: "people using Splurj",
                        icon: "person.3.fill",
                        delay: 0
                    )
                    statRow(
                        value: "$\(formatAnimatedNumber(animatedSaved, target: 2.4, decimal: true))M",
                        label: "saved by our community",
                        icon: "dollarsign.circle.fill",
                        delay: 0.1
                    )
                    statRow(
                        value: "\(formatAnimatedNumber(animatedPercent, target: 89))%",
                        label: "report feeling more in control",
                        icon: "chart.line.uptrend.xyaxis",
                        delay: 0.2
                    )
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 24)

                VStack(spacing: 12) {
                    ForEach(Array(testimonials.enumerated()), id: \.offset) { index, testimonial in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\"\(testimonial.quote)\"")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)
                                .lineSpacing(3)
                                .italic()

                            HStack(spacing: 6) {
                                Text("— \(testimonial.author), \(testimonial.type)")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Theme.textSecondary)
                                Text(testimonial.emoji)
                                    .font(.system(size: 12))
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCard(cornerRadius: 14)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.4 + Double(index) * 0.1), value: appeared)
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 32)

                Button {
                    onNext()
                } label: {
                    Text("Join \(personalityUserCount) \(personalityName)s like you")
                        .font(.headline)
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
            withAnimation(.spring(response: 0.5)) {
                appeared = true
            }
            withAnimation(.easeOut(duration: 1.5)) {
                animatedUsers = 12847
                animatedSaved = 2.4
                animatedPercent = 89
            }
        }
    }

    private func statRow(value: String, label: String, icon: String, delay: Double) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.accentGreen)
                .frame(width: 44, height: 44)
                .background(Theme.accentGreen.opacity(0.12), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .contentTransition(.numericText())

                Text(label)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .glassCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5).delay(delay), value: appeared)
    }

    private func formatAnimatedNumber(_ value: Double, target: Double, decimal: Bool = false) -> String {
        if decimal {
            return String(format: "%.1f", value)
        }
        return "\(Int(value).formatted())"
    }
}
