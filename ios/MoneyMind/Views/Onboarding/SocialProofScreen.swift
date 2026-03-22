import SwiftUI

struct SocialProofScreen: View {
    let onNext: () -> Void

    @State private var appeared = false

    private let stats: [(String, String, String)] = [
        ("12,847", "people using MoneyMind", "person.3.fill"),
        ("$2.4M", "saved by our community", "dollarsign.circle.fill"),
        ("89%", "report feeling more in control", "chart.line.uptrend.xyaxis"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 36) {
                VStack(spacing: 8) {
                    Text("You're Not Alone")
                        .font(Theme.headingFont(.title))
                        .foregroundStyle(Theme.textPrimary)

                    Text("Join thousands taking control of\ntheir financial wellbeing")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 16) {
                    ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                        HStack(spacing: 16) {
                            Image(systemName: stat.2)
                                .font(.title2)
                                .foregroundStyle(Theme.accentGreen)
                                .frame(width: 44, height: 44)
                                .background(Theme.accentGreen.opacity(0.12), in: .rect(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(stat.0)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.textPrimary)

                                Text(stat.1)
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(response: 0.5).delay(Double(index) * 0.1), value: appeared)
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            Button {
                onNext()
            } label: {
                Text("Join the Community")
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
        .onAppear {
            withAnimation(.spring(response: 0.5)) {
                appeared = true
            }
        }
    }
}
