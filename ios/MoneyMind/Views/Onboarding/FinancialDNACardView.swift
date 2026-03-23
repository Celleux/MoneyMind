import SwiftUI

struct FinancialDNACardView: View {
    let dna: FinancialDNA

    private var archetype: FinancialArchetype { dna.primaryArchetype }
    private var secondary: FinancialArchetype { dna.secondaryArchetype }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text("FINANCIAL DNA")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
                    .tracking(3)
                Spacer()
            }

            DNARadarShape(dna: dna, animated: true)
                .frame(width: 140, height: 140)

            VStack(spacing: 6) {
                Image(systemName: archetype.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(archetype.color)

                Text(archetype.rawValue.uppercased())
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(3)

                if secondary != archetype {
                    Text("with \(secondary.rawValue) tendencies")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }

                Text(archetype.tagline)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(archetype.color)
                    .padding(.top, 2)
            }

            HStack(spacing: 16) {
                axisMini("SPD", value: dna.spendingAxis, color: Color(hex: 0x34D399))
                axisMini("EMO", value: dna.emotionalAxis, color: Color(hex: 0x60A5FA))
                axisMini("RSK", value: dna.riskAxis, color: Color(hex: 0xFB923C))
                axisMini("SOC", value: dna.socialAxis, color: Color(hex: 0xF472B6))
            }

            Text("Discover yours at splurj.app")
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textMuted)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Theme.surface, Theme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(archetype.color.opacity(0.2), lineWidth: 1)
        )
    }

    private func axisMini(_ label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textMuted)
                .tracking(1)

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Theme.elevated)
                    .frame(width: 6, height: 32)

                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: 6, height: 32 * max(0.08, value))
            }

            Text("\(Int(value * 100))")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
    }
}
