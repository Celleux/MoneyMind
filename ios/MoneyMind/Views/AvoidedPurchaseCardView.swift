import SwiftUI

struct AvoidedPurchaseCardView: View {
    let amount: Double
    let itemName: String
    let trigger: String
    let hourlyRate: Double

    private var workHours: Double {
        guard hourlyRate > 0 else { return 0 }
        return amount / hourlyRate
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Text("MONEYMIND")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(4)

                VStack(spacing: 8) {
                    Text("I saved")
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))

                    Text(amount, format: .currency(code: "USD").precision(.fractionLength(0)))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("by saying no")
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                if !itemName.isEmpty {
                    Text("\"\(itemName)\"")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .italic()
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                    Text("That's \(workHours, specifier: "%.1f") hours of my work")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                }
                .foregroundStyle(Theme.teal)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Theme.teal.opacity(0.12), in: .capsule)

                if !trigger.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                        Text(trigger)
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                    }
                    .foregroundStyle(Theme.accentGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Theme.accentGreen.opacity(0.12), in: .capsule)
                    .overlay(Capsule().strokeBorder(Theme.accentGreen.opacity(0.2), lineWidth: 1))
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            CardWatermark()
                .padding(.bottom, 40)
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .background(CardBackground(accentColor: Theme.accentGreen, secondaryColor: Theme.teal))
        .clipShape(.rect(cornerRadius: 24))
    }
}

struct ShareWinSheet: View {
    let amount: Double
    let itemName: String
    let trigger: String
    let hourlyRate: Double
    @Environment(\.dismiss) private var dismiss
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                AvoidedPurchaseCardView(
                    amount: amount,
                    itemName: itemName,
                    trigger: trigger,
                    hourlyRate: hourlyRate
                )
                .scaleEffect(0.75)
                .frame(
                    width: ShareCardRenderer.viewSize.width * 0.75,
                    height: ShareCardRenderer.viewSize.height * 0.75
                )
                .shadow(color: Theme.accentGreen.opacity(0.2), radius: 20, y: 10)

                Button {
                    let card = AvoidedPurchaseCardView(
                        amount: amount,
                        itemName: itemName,
                        trigger: trigger,
                        hourlyRate: hourlyRate
                    )
                    shareImage = ShareCardRenderer.render(card)
                    if shareImage != nil {
                        showShareSheet = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body.weight(.semibold))
                        Text("Share Your Win")
                            .font(.headline)
                    }
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, 32)
                .sensoryFeedback(.impact(weight: .medium), trigger: showShareSheet)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Share Your Win")
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
