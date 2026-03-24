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
                    .font(Typography.labelSmall)
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(4)

                VStack(spacing: 8) {
                    Text("I saved")
                        .font(Typography.headingLarge)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(amount, format: .currency(code: "USD").precision(.fractionLength(0)))
                        .font(Typography.displayLarge)
                        .foregroundStyle(.white)

                    Text("by saying no")
                        .font(Typography.headingLarge)
                        .foregroundStyle(.white.opacity(0.7))
                }

                if !itemName.isEmpty {
                    Text("\"\(itemName)\"")
                        .font(Typography.bodyLarge)
                        .foregroundStyle(.white.opacity(0.6))
                        .italic()
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(Typography.labelSmall)
                    Text("That's \(workHours, specifier: "%.1f") hours of my work")
                        .font(Typography.bodyMedium)
                }
                .foregroundStyle(Theme.teal)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Theme.teal.opacity(0.12), in: .capsule)

                if !trigger.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(Typography.labelSmall)
                        Text(trigger)
                            .font(Typography.labelSmall)
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
                            .font(Typography.headingMedium)
                        Text("Share Your Win")
                            .font(Typography.headingMedium)
                    }
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
                }
                .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
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
