import SwiftUI

struct GhostBudgetShareCard: View {
    let savings: Double
    let timeframe: String
    let topHabit: String
    let personalityColor: Color
    let personalityIcon: String

    var body: some View {
        ZStack {
            CardBackground(accentColor: Theme.success, secondaryColor: personalityColor)

            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "leaf.fill")
                            .foregroundStyle(Theme.success)
                        Text("MoneyMind")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                    Text("👻 Ghost Budget")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 24) {
                    Text("If I stopped spending on")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))

                    Text(topHabit)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(personalityColor)

                    VStack(spacing: 8) {
                        Text("I'd have")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))

                        Text("$\(Int(savings))")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.success)

                        Text("more in \(timeframe)")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.success.opacity(0.7))
                    }
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Theme.card)
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Theme.success.opacity(0.2), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal, 24)

                    ZStack {
                        Circle()
                            .fill(personalityColor.opacity(0.1))
                            .frame(width: 64, height: 64)
                        Image(systemName: personalityIcon)
                            .font(.system(size: 28))
                            .foregroundStyle(personalityColor)
                    }
                }

                Spacer()

                VStack(spacing: 8) {
                    Text("Discover your parallel financial timeline")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.3))
                    CardWatermark()
                }
                .padding(.bottom, 50)
            }
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .preferredColorScheme(.dark)
    }
}
