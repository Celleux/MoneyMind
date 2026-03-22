import SwiftUI

struct WeeklySummaryCardView: View {
    let totalSaved: Double
    let purchasesResisted: Int
    let streak: Int
    let characterStage: CharacterStage
    let level: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                Text("WEEKLY SUMMARY")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(4)

                VStack(spacing: 4) {
                    Text(weekRangeString())
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(Theme.teal)

                    Text("My Week in Splurj")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                HStack(spacing: 16) {
                    summaryStatBlock(
                        value: totalSaved.formatted(.currency(code: "USD").precision(.fractionLength(0))),
                        label: "Saved",
                        icon: "dollarsign.circle.fill",
                        color: Theme.accentGreen
                    )
                    summaryStatBlock(
                        value: "\(purchasesResisted)",
                        label: "Resisted",
                        icon: "hand.raised.fill",
                        color: Theme.teal
                    )
                }

                HStack(spacing: 16) {
                    summaryStatBlock(
                        value: "\(streak)",
                        label: "Day Streak",
                        icon: "flame.fill",
                        color: .orange
                    )
                    summaryStatBlock(
                        value: characterStage.name,
                        label: "Level \(level)",
                        icon: characterStage.bodyIcon,
                        color: characterStage.primaryColor
                    )
                }
            }
            .padding(.horizontal, 28)

            Spacer()

            CardWatermark()
                .padding(.bottom, 40)
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .background(CardBackground(accentColor: Theme.teal, secondaryColor: Theme.accentGreen))
        .clipShape(.rect(cornerRadius: 24))
    }

    private func summaryStatBlock(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(.white.opacity(0.05), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
    }

    private func weekRangeString() -> String {
        let calendar = Calendar.current
        let end = Date()
        let start = calendar.date(byAdding: .day, value: -6, to: end) ?? end
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
    }
}

struct WeeklySummarySheet: View {
    let totalSaved: Double
    let purchasesResisted: Int
    let streak: Int
    let characterStage: CharacterStage
    let level: Int
    @Environment(\.dismiss) private var dismiss
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                WeeklySummaryCardView(
                    totalSaved: totalSaved,
                    purchasesResisted: purchasesResisted,
                    streak: streak,
                    characterStage: characterStage,
                    level: level
                )
                .scaleEffect(0.75)
                .frame(
                    width: ShareCardRenderer.viewSize.width * 0.75,
                    height: ShareCardRenderer.viewSize.height * 0.75
                )
                .shadow(color: Theme.teal.opacity(0.2), radius: 20, y: 10)

                Button {
                    let card = WeeklySummaryCardView(
                        totalSaved: totalSaved,
                        purchasesResisted: purchasesResisted,
                        streak: streak,
                        characterStage: characterStage,
                        level: level
                    )
                    shareImage = ShareCardRenderer.render(card)
                    if shareImage != nil { showShareSheet = true }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body.weight(.semibold))
                        Text("Share Weekly Summary")
                            .font(.headline)
                    }
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [Theme.teal, Theme.accentGreen], startPoint: .leading, endPoint: .trailing),
                        in: .rect(cornerRadius: 14)
                    )
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, 32)
                .sensoryFeedback(.impact(weight: .medium), trigger: showShareSheet)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Weekly Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = shareImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }
}
