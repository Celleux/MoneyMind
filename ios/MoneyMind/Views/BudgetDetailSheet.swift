import SwiftUI
import SwiftData

struct BudgetDetailSheet: View {
    let budget: BudgetCategory
    let spent: Double

    @Query private var profiles: [UserProfile]
    @Environment(\.dismiss) private var dismiss

    private var currencyCode: String { profiles.first?.defaultCurrency ?? "USD" }

    private var progress: Double {
        guard budget.monthlyLimit > 0 else { return 0 }
        return min(spent / budget.monthlyLimit, 1.0)
    }

    private var remaining: Double {
        max(budget.monthlyLimit - spent, 0)
    }

    private var categoryColor: Color {
        Color(hex: UInt(budget.colorHex, radix: 16) ?? 0x64748B)
    }

    var body: some View {
        VStack(spacing: 28) {
            Capsule()
                .fill(Theme.border)
                .frame(width: 36, height: 4)
                .padding(.top, 8)

            ZStack {
                Circle()
                    .stroke(Theme.border, lineWidth: 10)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [categoryColor, categoryColor.opacity(0.6)],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Image(systemName: budget.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(categoryColor)
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text("used")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .frame(width: 140, height: 140)

            Text(budget.name)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(spent, format: .currency(code: currencyCode).precision(.fractionLength(0)))
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(categoryColor)
                }

                Rectangle()
                    .fill(Theme.border)
                    .frame(width: 1, height: 36)

                VStack(spacing: 4) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(budget.monthlyLimit, format: .currency(code: currencyCode).precision(.fractionLength(0)))
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                }

                Rectangle()
                    .fill(Theme.border)
                    .frame(width: 1, height: 36)

                VStack(spacing: 4) {
                    Text("Left")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(remaining, format: .currency(code: currencyCode).precision(.fractionLength(0)))
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(remaining > 0 ? Theme.accentGreen : Theme.danger)
                }
            }

            if progress >= 0.9 {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Theme.warning)
                    Text(progress >= 1.0 ? "Budget exceeded!" : "Almost at your limit")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.warning)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Theme.warning.opacity(0.1), in: .rect(cornerRadius: 12))
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Theme.background.ignoresSafeArea())
    }
}
