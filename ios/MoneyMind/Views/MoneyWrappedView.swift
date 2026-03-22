import SwiftUI
import SwiftData

struct MoneyWrappedView: View {
    let totalSaved: Double
    let purchasesResisted: Int
    let longestStreak: Int
    let characterStage: CharacterStage
    let level: Int
    let startStage: CharacterStage
    let categoryBreakdown: [(String, Int)]
    let isAnnual: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int = 0
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    private let pageCount = 6

    private var periodLabel: String {
        if isAnnual {
            return String(Calendar.current.component(.year, from: Date()))
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                pageIndicator
                    .padding(.top, 8)

                TabView(selection: $currentPage) {
                    wrappedCard1.tag(0)
                    wrappedCard2.tag(1)
                    wrappedCard3.tag(2)
                    wrappedCard4.tag(3)
                    wrappedCard5.tag(4)
                    wrappedCard6.tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: currentPage)

                shareButtons
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle(isAnnual ? "Money Wrapped" : "Monthly Recap")
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

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { i in
                Capsule()
                    .fill(i == currentPage ? Theme.accentGreen : Theme.textSecondary.opacity(0.2))
                    .frame(width: i == currentPage ? 24 : 8, height: 4)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }

    private var shareButtons: some View {
        Button {
            shareCurrentCard()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.body.weight(.semibold))
                Text("Share This Card")
                    .font(.headline)
            }
            .foregroundStyle(Theme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: showShareSheet)
    }

    private func shareCurrentCard() {
        let card: AnyView
        switch currentPage {
        case 0: card = AnyView(WrappedTitleCard(periodLabel: periodLabel, isAnnual: isAnnual))
        case 1: card = AnyView(WrappedSavingsCard(totalSaved: totalSaved))
        case 2: card = AnyView(WrappedResistedCard(count: purchasesResisted, breakdown: categoryBreakdown))
        case 3: card = AnyView(WrappedStreakCard(longestStreak: longestStreak))
        case 4: card = AnyView(WrappedEvolutionCard(from: startStage, to: characterStage, level: level))
        case 5: card = AnyView(WrappedPercentileCard(totalSaved: totalSaved))
        default: return
        }
        shareImage = ShareCardRenderer.render(card)
        if shareImage != nil { showShareSheet = true }
    }

    private var wrappedCard1: some View {
        WrappedTitleCard(periodLabel: periodLabel, isAnnual: isAnnual)
            .wrappedCardFrame()
    }

    private var wrappedCard2: some View {
        WrappedSavingsCard(totalSaved: totalSaved)
            .wrappedCardFrame()
    }

    private var wrappedCard3: some View {
        WrappedResistedCard(count: purchasesResisted, breakdown: categoryBreakdown)
            .wrappedCardFrame()
    }

    private var wrappedCard4: some View {
        WrappedStreakCard(longestStreak: longestStreak)
            .wrappedCardFrame()
    }

    private var wrappedCard5: some View {
        WrappedEvolutionCard(from: startStage, to: characterStage, level: level)
            .wrappedCardFrame()
    }

    private var wrappedCard6: some View {
        WrappedPercentileCard(totalSaved: totalSaved)
            .wrappedCardFrame()
    }
}

private extension View {
    func wrappedCardFrame() -> some View {
        self
            .scaleEffect(0.72)
            .frame(
                width: ShareCardRenderer.viewSize.width * 0.72,
                height: ShareCardRenderer.viewSize.height * 0.72
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WrappedTitleCard: View {
    let periodLabel: String
    let isAnnual: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.accentGradient)

                VStack(spacing: 12) {
                    Text(isAnnual ? "Your Year in" : "Your Month in")
                        .font(.system(.title2, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))

                    Text("MoneyMind")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(periodLabel)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Theme.accentGreen)
                }
            }

            Spacer()

            CardWatermark()
                .padding(.bottom, 40)
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .background(
            ZStack {
                Theme.background
                MeshGradient(
                    width: 3, height: 3,
                    points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                    ],
                    colors: [
                        Theme.accentGreen.opacity(0.15), .clear, Theme.teal.opacity(0.12),
                        .clear, Theme.accentGreen.opacity(0.08), .clear,
                        Theme.teal.opacity(0.1), .clear, Theme.accentGreen.opacity(0.1)
                    ]
                )
            }
        )
        .clipShape(.rect(cornerRadius: 24))
    }
}

struct WrappedSavingsCard: View {
    let totalSaved: Double

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("YOU SAVED")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.accentGreen)
                    .tracking(4)

                Text(totalSaved, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Theme.accentGradient)
            }

            Spacer()

            CardWatermark()
                .padding(.bottom, 40)
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .background(CardBackground(accentColor: Theme.accentGreen, secondaryColor: .green.opacity(0.6)))
        .clipShape(.rect(cornerRadius: 24))
    }
}

struct WrappedResistedCard: View {
    let count: Int
    let breakdown: [(String, Int)]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("YOU RESISTED")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.teal)
                    .tracking(4)

                VStack(spacing: 4) {
                    Text("\(count)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("purchases")
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }

                if !breakdown.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(breakdown.prefix(5), id: \.0) { category, count in
                            HStack {
                                Text(category)
                                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.7))
                                Spacer()
                                Text("\(count)")
                                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                                    .foregroundStyle(Theme.teal)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 16)
                    .background(.white.opacity(0.04), in: .rect(cornerRadius: 14))
                    .padding(.horizontal, 24)
                }
            }

            Spacer()

            CardWatermark()
                .padding(.bottom, 40)
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .background(CardBackground(accentColor: Theme.teal, secondaryColor: .cyan.opacity(0.5)))
        .clipShape(.rect(cornerRadius: 24))
    }
}

struct WrappedStreakCard: View {
    let longestStreak: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("LONGEST STREAK")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.orange)
                    .tracking(4)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(longestStreak)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("days")
                        .font(.system(.title2, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Image(systemName: "flame.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange, .yellow],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
            }

            Spacer()

            CardWatermark()
                .padding(.bottom, 40)
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .background(CardBackground(accentColor: .orange, secondaryColor: .red.opacity(0.5)))
        .clipShape(.rect(cornerRadius: 24))
    }
}

struct WrappedEvolutionCard: View {
    let from: CharacterStage
    let to: CharacterStage
    let level: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                Text("CHARACTER EVOLUTION")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(to.primaryColor)
                    .tracking(4)

                HStack(spacing: 32) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(from.primaryColor.opacity(0.12))
                                .frame(width: 72, height: 72)
                            Image(systemName: from.bodyIcon)
                                .font(.system(size: 32))
                                .foregroundStyle(from.primaryColor.opacity(0.5))
                        }
                        Text(from.name)
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(to.primaryColor)
                    }

                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(to.primaryColor.opacity(0.15))
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(to.primaryColor.opacity(0.06))
                                .frame(width: 96, height: 96)
                            Image(systemName: to.bodyIcon)
                                .font(.system(size: 36))
                                .foregroundStyle(to.primaryColor)
                        }
                        Text(to.name)
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                Text("Level \(level)")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(to.primaryColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(to.primaryColor.opacity(0.12), in: .capsule)
            }

            Spacer()

            CardWatermark()
                .padding(.bottom, 40)
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .background(CardBackground(accentColor: to.primaryColor, secondaryColor: to.secondaryColor))
        .clipShape(.rect(cornerRadius: 24))
    }
}

struct WrappedPercentileCard: View {
    let totalSaved: Double

    private var percentile: Int {
        switch totalSaved {
        case ..<50: 40
        case 50..<200: 55
        case 200..<500: 68
        case 500..<1_000: 78
        case 1_000..<5_000: 88
        case 5_000..<10_000: 94
        default: 97
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("YOU DID AMAZING")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.gold)
                    .tracking(4)

                VStack(spacing: 8) {
                    Text("You saved more than")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))

                    Text("\(percentile)%")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.goldGradient)

                    Text("of MoneyMind users")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Image(systemName: "star.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.gold)
            }

            Spacer()

            CardWatermark()
                .padding(.bottom, 40)
        }
        .frame(width: ShareCardRenderer.viewSize.width, height: ShareCardRenderer.viewSize.height)
        .background(CardBackground(accentColor: Theme.gold, secondaryColor: .orange))
        .clipShape(.rect(cornerRadius: 24))
    }
}
