import SwiftUI

struct LossVisualizationScreen: View {
    let onNext: () -> Void

    @State private var dailyAmount: Double = 5
    @State private var appeared = false

    private var yearlyLoss: Double { dailyAmount * 365 }
    private var fiveYearLoss: Double { dailyAmount * 365 * 5 }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("Drag to see the real cost")
                        .font(Theme.headingFont(.title2))
                        .foregroundStyle(Theme.textPrimary)
                    Text("of daily impulse spending")
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
                        .tint(Theme.emergency)
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
                Text("That's eye-opening")
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
