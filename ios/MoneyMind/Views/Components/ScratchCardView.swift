import SwiftUI

struct ScratchCardView: View {
    let scratchCard: ScratchCard
    let onRevealed: (CardDefinition) -> Void

    @State private var scratchPoints: [CGPoint] = []
    @State private var isRevealed: Bool = false
    @State private var revealedCard: CardDefinition?
    @State private var scratchPercentage: Double = 0
    @State private var glowPulse: Bool = false

    private let cardWidth: CGFloat = 280
    private let cardHeight: CGFloat = 400
    private let scratchRadius: CGFloat = 28

    var body: some View {
        ZStack {
            if let card = revealedCard {
                CardArtView(card: card)
                    .frame(width: cardWidth, height: cardHeight)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.surface)
                    .frame(width: cardWidth, height: cardHeight)
            }

            if !isRevealed {
                scratchOverlay
                scratchHintText
                rarityHintGlow
            }

            if isRevealed, let card = revealedCard {
                revealedOverlay(card: card)
            }
        }
        .onAppear {
            if let cardID = scratchCard.cardPullID {
                revealedCard = CardDatabase.card(byID: cardID)
            }
        }
        .onChange(of: scratchPercentage) { _, newValue in
            if newValue > 0.55 && !isRevealed {
                revealCard()
            }
        }
    }

    private var scratchOverlay: some View {
        Canvas { context, size in
            let bgPath = RoundedRectangle(cornerRadius: 16).path(in: CGRect(origin: .zero, size: size))
            context.fill(bgPath, with: .linearGradient(
                Gradient(colors: [Color(hex: 0x1E2433), Color(hex: 0x12161F)]),
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: size.height)
            ))

            context.blendMode = .clear
            for point in scratchPoints {
                let rect = CGRect(
                    x: point.x - scratchRadius,
                    y: point.y - scratchRadius,
                    width: scratchRadius * 2,
                    height: scratchRadius * 2
                )
                context.fill(Circle().path(in: rect), with: .color(.black))
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(.rect(cornerRadius: 16))
        .compositingGroup()
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let point = value.location
                    guard point.x >= 0, point.x <= cardWidth,
                          point.y >= 0, point.y <= cardHeight else { return }
                    scratchPoints.append(point)
                    updateScratchPercentage()
                    if scratchPoints.count % 5 == 0 {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
        )
    }

    private var scratchHintText: some View {
        VStack {
            Spacer()
            Text("SCRATCH TO REVEAL")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(Theme.textMuted)
                .padding(.bottom, 24)
        }
        .frame(width: cardWidth, height: cardHeight)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var rarityHintGlow: some View {
        if scratchCard.cardRarity == CardRarity.epic.rawValue || scratchCard.cardRarity == CardRarity.legendary.rawValue {
            let rarityColor = CardRarity(rawValue: scratchCard.cardRarity)?.color ?? Theme.accent
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(rarityColor.opacity(glowPulse ? 0.6 : 0.2), lineWidth: 2)
                .shadow(color: rarityColor.opacity(glowPulse ? 0.4 : 0.1), radius: 12)
                .frame(width: cardWidth, height: cardHeight)
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        glowPulse = true
                    }
                }
        }
    }

    private func revealedOverlay(card: CardDefinition) -> some View {
        CardArtView(card: card)
            .frame(width: cardWidth, height: cardHeight)
            .transition(.scale.combined(with: .opacity))
            .overlay(alignment: .topTrailing) {
                Text("NEW")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.background)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(card.rarity.color, in: .capsule)
                    .padding(10)
            }
    }

    private func updateScratchPercentage() {
        let totalArea = Double(cardWidth * cardHeight)
        let scratchedArea = Double(scratchPoints.count) * .pi * Double(scratchRadius * scratchRadius)
        scratchPercentage = min(scratchedArea / totalArea, 1.0)
    }

    private func revealCard() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isRevealed = true
        }

        if let card = revealedCard {
            onRevealed(card)

            if card.rarity == .epic || card.rarity == .legendary {
                Task {
                    try? await Task.sleep(for: .milliseconds(300))
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
    }
}
