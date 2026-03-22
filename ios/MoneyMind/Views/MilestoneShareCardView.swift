import SwiftUI

struct MilestoneShareCardView: View {
    let milestoneAmount: Double

    private var milestoneLabel: String {
        switch milestoneAmount {
        case 100: "First Hundred"
        case 500: "Half a Grand"
        case 1_000: "The $1K Club"
        case 5_000: "Major Milestone"
        case 10_000: "Five Figures"
        case 25_000: "Life Changing"
        default: "Milestone"
        }
    }

    private var milestoneIcon: String {
        switch milestoneAmount {
        case 100: "star.fill"
        case 500: "trophy.fill"
        case 1_000: "crown.fill"
        case 5_000: "medal.fill"
        case 10_000: "medal.star.fill"
        case 25_000: "sparkles"
        default: "star.fill"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(Theme.gold.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Circle()
                        .fill(Theme.gold.opacity(0.06))
                        .frame(width: 120, height: 120)
                    Image(systemName: milestoneIcon)
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.goldGradient)
                }

                VStack(spacing: 8) {
                    Text(milestoneLabel.uppercased())
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.gold)
                        .tracking(3)

                    Text(milestoneAmount, format: .currency(code: "USD").precision(.fractionLength(0)))
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("saved with Splurj")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }

                VStack(spacing: 4) {
                    Text("Can you beat my savings?")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Download Splurj and find out")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 32)

            Spacer()

            CardWatermark()
                .padding(.bottom, 40)
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .background(CardBackground(accentColor: Theme.gold, secondaryColor: Color(red: 1, green: 0.6, blue: 0)))
        .clipShape(.rect(cornerRadius: 24))
    }
}

struct MilestoneShareSheet: View {
    let milestoneAmount: Double
    @Environment(\.dismiss) private var dismiss
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                MilestoneShareCardView(milestoneAmount: milestoneAmount)
                    .scaleEffect(0.75)
                    .frame(
                        width: ShareCardRenderer.viewSize.width * 0.75,
                        height: ShareCardRenderer.viewSize.height * 0.75
                    )
                    .shadow(color: Theme.gold.opacity(0.25), radius: 20, y: 10)

                VStack(spacing: 12) {
                    Button {
                        let card = MilestoneShareCardView(milestoneAmount: milestoneAmount)
                        shareImage = ShareCardRenderer.render(card)
                        if shareImage != nil { showShareSheet = true }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.body.weight(.semibold))
                            Text("Share Milestone")
                                .font(.headline)
                        }
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.goldGradient, in: .rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button {
                        let card = MilestoneShareCardView(milestoneAmount: milestoneAmount)
                        shareImage = ShareCardRenderer.render(card)
                        if shareImage != nil { showShareSheet = true }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "person.2.fill")
                                .font(.subheadline)
                            Text("Challenge a Friend")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(Theme.gold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.gold.opacity(0.12), in: .rect(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Theme.gold.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal, 32)
                .sensoryFeedback(.impact(weight: .heavy), trigger: showShareSheet)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Milestone!")
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
