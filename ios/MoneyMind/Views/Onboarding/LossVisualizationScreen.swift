import SwiftUI

struct LossVisualizationScreen: View {
    let personality: MoneyPersonality
    let onNext: () -> Void

    @State private var dailyAmount: Double
    @State private var appeared = false

    init(personality: MoneyPersonality, onNext: @escaping () -> Void) {
        self.personality = personality
        self.onNext = onNext
        let defaultAmount: Double = switch personality {
        case .hustler, .generous: 15
        case .saver, .minimalist: 5
        case .builder: 10
        }
        _dailyAmount = State(initialValue: defaultAmount)
    }

    private var yearlyLoss: Double { dailyAmount * 365 }
    private var fiveYearLoss: Double { dailyAmount * 365 * 5 }

    private var ghostBudgetItem: String {
        switch yearlyLoss {
        case ..<2500: "a weekend getaway"
        case ..<4500: "a new MacBook"
        case ..<8000: "a month in Thailand"
        default: "a used car"
        }
    }

    private var ghostBudgetEmoji: String {
        switch yearlyLoss {
        case ..<2500: "🏖️"
        case ..<4500: "💻"
        case ..<8000: "✈️"
        default: "🚗"
        }
    }

    private var personalityName: String {
        personality.rawValue.replacingOccurrences(of: "The ", with: "")
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Text("Here's what impulse spending\ncosts a \(personalityName)")
                        .font(Theme.headingFont(.title3))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                    Text("Drag the slider to explore")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)

                VStack(spacing: 24) {
                    Text("$\(dailyAmount, specifier: "%.0f")/day")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .contentTransition(.numericText(value: dailyAmount))

                    Slider(value: $dailyAmount, in: 1...100, step: 1)
                        .tint(personality.color)
                        .padding(.horizontal, 24)

                    VStack(spacing: 20) {
                        LossRow(
                            label: "1 Year",
                            amount: yearlyLoss,
                            scale: min(1.0 + (dailyAmount / 100) * 0.4, 1.4)
                        )
                        LossRow(
                            label: "5 Years",
                            amount: fiveYearLoss,
                            scale: min(1.0 + (dailyAmount / 100) * 0.6, 1.6)
                        )
                    }

                    HStack(spacing: 12) {
                        Text(ghostBudgetEmoji)
                            .font(.system(size: 28))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("If you saved this instead...")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                            Text("In 1 year you could buy \(ghostBudgetItem)")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(personality.color)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(personality.color.opacity(0.08), in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(personality.color.opacity(0.2), lineWidth: 0.5)
                    )
                }
                .padding(28)
                .background(Theme.cardSurface, in: .rect(cornerRadius: 20))
                .animation(.spring(response: 0.3), value: dailyAmount)
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                onNext()
            } label: {
                Text("I want to change this")
                    .font(.headline)
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
            .opacity(appeared ? 1 : 0)
            .sensoryFeedback(.impact(weight: .medium), trigger: dailyAmount)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.1)) {
                appeared = true
            }
        }
    }
}

private struct LossRow: View {
    let label: String
    let amount: Double
    let scale: Double

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 60, alignment: .leading)

            Spacer()

            Text("−$\(amount, specifier: "%.0f")")
                .font(.system(size: 36 * scale, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.emergency)
                .contentTransition(.numericText(value: amount))
        }
    }
}
