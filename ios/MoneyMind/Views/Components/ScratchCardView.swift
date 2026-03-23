import SwiftUI

struct ScratchCardView: View {
    let scratchCard: ScratchCard
    let onRevealed: (CardDefinition) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scratchPoints: [CGPoint] = []
    @State private var isRevealed: Bool = false
    @State private var revealedCard: CardDefinition?
    @State private var scratchPercentage: Double = 0
    @State private var glowPulse: Bool = false
    @State private var showRevealSequence: Bool = false
    @State private var revealPhase: Int = 0
    @State private var lastHapticDistance: CGFloat = 0
    @State private var dragPosition: CGPoint = .init(x: 140, y: 200)
    @State private var criticalScratchBonus: CriticalScratchBonus?
    @State private var showCriticalBonus: Bool = false
    @State private var vibrateOnAppear: Bool = false

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
                holographicScratchOverlay
                scratchHintText
                rarityHintGlow
            }

            if showRevealSequence, let card = revealedCard {
                revealSequenceOverlay(card: card)
            }

            if showCriticalBonus, let bonus = criticalScratchBonus {
                criticalBonusBadge(bonus: bonus)
            }
        }
        .onAppear {
            if let cardID = scratchCard.cardPullID {
                revealedCard = CardDatabase.card(byID: cardID)
            }
            if scratchCard.cardRarity == CardRarity.legendary.rawValue {
                vibrateOnAppear = true
                SplurjHaptics.epicReveal()
            }
        }
        .onChange(of: scratchPercentage) { _, newValue in
            if newValue > 0.55 && !isRevealed {
                revealCard()
            }
        }
    }

    private var holographicScratchOverlay: some View {
        Canvas { context, size in
            let bgPath = RoundedRectangle(cornerRadius: 16).path(in: CGRect(origin: .zero, size: size))

            let holoColors: [Color] = [
                Color(hex: 0x7B2FBE),
                Color(hex: 0x2563EB),
                Color(hex: 0x059669),
                Color(hex: 0xD97706),
                Color(hex: 0x7B2FBE)
            ]

            let normalizedX = dragPosition.x / size.width
            let normalizedY = dragPosition.y / size.height
            let startPt = CGPoint(
                x: size.width * max(0, normalizedX - 0.3),
                y: size.height * max(0, normalizedY - 0.3)
            )
            let endPt = CGPoint(
                x: size.width * min(1, normalizedX + 0.3),
                y: size.height * min(1, normalizedY + 0.3)
            )

            context.fill(bgPath, with: .linearGradient(
                Gradient(colors: holoColors),
                startPoint: startPt,
                endPoint: endPt
            ))

            context.fill(bgPath, with: .linearGradient(
                Gradient(colors: [Color.white.opacity(0.08), Color.clear, Color.white.opacity(0.05)]),
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
                    dragPosition = point
                    updateScratchPercentage()

                    let distance = hypot(
                        point.x - (scratchPoints.dropLast().last?.x ?? point.x),
                        point.y - (scratchPoints.dropLast().last?.y ?? point.y)
                    )
                    lastHapticDistance += distance
                    if lastHapticDistance >= 20 {
                        SplurjHaptics.scratchContinuous()
                        lastHapticDistance = 0
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
                .foregroundStyle(Color.white.opacity(0.6))
                .padding(.bottom, 24)
        }
        .frame(width: cardWidth, height: cardHeight)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var rarityHintGlow: some View {
        let rarity = CardRarity(rawValue: scratchCard.cardRarity)
        if rarity == .rare {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(hex: 0x60A5FA).opacity(glowPulse ? 0.5 : 0.15), lineWidth: 2)
                .shadow(color: Color(hex: 0x60A5FA).opacity(glowPulse ? 0.3 : 0.08), radius: 10)
                .frame(width: cardWidth, height: cardHeight)
                .allowsHitTesting(false)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        glowPulse = true
                    }
                }
        } else if rarity == .epic {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(hex: 0xA78BFA).opacity(glowPulse ? 0.6 : 0.2), lineWidth: 2.5)
                .shadow(color: Color(hex: 0xA78BFA).opacity(glowPulse ? 0.45 : 0.1), radius: 14)
                .frame(width: cardWidth, height: cardHeight)
                .allowsHitTesting(false)
                .modifier(SubtleShakeModifier(active: vibrateOnAppear))
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        glowPulse = true
                    }
                }
        } else if rarity == .legendary {
            ZStack {
                TimelineView(.animation) { timeline in
                    let elapsed = timeline.date.timeIntervalSinceReferenceDate
                    let angle = elapsed.truncatingRemainder(dividingBy: 4.0) / 4.0 * 360
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            AngularGradient(
                                colors: [Theme.gold, Color(hex: 0xFFA500), Theme.gold, Color(hex: 0xFFEE58), Theme.gold],
                                center: .center,
                                startAngle: .degrees(angle),
                                endAngle: .degrees(angle + 360)
                            ),
                            lineWidth: 3
                        )
                        .shadow(color: Theme.gold.opacity(0.5), radius: 16)
                }
                .frame(width: cardWidth, height: cardHeight)

                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.gold.opacity(glowPulse ? 0.06 : 0.02))
                    .frame(width: cardWidth, height: cardHeight)
            }
            .allowsHitTesting(false)
            .modifier(SubtleShakeModifier(active: vibrateOnAppear))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
        }
    }

    private func revealSequenceOverlay(card: CardDefinition) -> some View {
        ZStack {
            if revealPhase >= 1 {
                CardArtView(card: card)
                    .frame(width: cardWidth, height: cardHeight)
                    .brightness(revealPhase == 1 ? 0.4 : 0)
                    .animation(.easeOut(duration: 0.4), value: revealPhase)
            }

            if revealPhase >= 2 {
                VStack {
                    Spacer()
                    Text(card.rarity.label)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(card.rarity.color)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    Text(card.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .transition(.opacity)
                    Text(card.tip)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                        .transition(.opacity)
                }
                .frame(width: cardWidth, height: cardHeight)
            }

            if revealPhase >= 2 {
                VStack {
                    HStack {
                        Spacer()
                        Text("NEW")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.background)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(card.rarity.color, in: .capsule)
                            .padding(10)
                    }
                    Spacer()
                }
                .frame(width: cardWidth, height: cardHeight)
            }
        }
    }

    private func criticalBonusBadge(bonus: CriticalScratchBonus) -> some View {
        VStack {
            Text("CRITICAL SCRATCH!")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(Theme.neonGold)
                .tracking(1)
            Text(bonus.description)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.elevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.neonGold.opacity(0.5), lineWidth: 1.5)
                )
                .shadow(color: Theme.neonGold.opacity(0.3), radius: 12)
        )
        .offset(y: -(cardHeight / 2 + 40))
        .transition(.scale.combined(with: .opacity))
    }

    private func updateScratchPercentage() {
        let totalArea = Double(cardWidth * cardHeight)
        let scratchedArea = Double(scratchPoints.count) * .pi * Double(scratchRadius * scratchRadius)
        scratchPercentage = min(scratchedArea / totalArea, 1.0)
    }

    private func revealCard() {
        SplurjHaptics.scratchReveal()
        isRevealed = true

        guard let card = revealedCard else { return }

        let hasCritical = rollCriticalScratch()

        if reduceMotion {
            showRevealSequence = true
            revealPhase = 2
            onRevealed(card)
            if hasCritical {
                showCriticalBonus = true
            }
            return
        }

        showRevealSequence = true
        revealPhase = 1

        Task {
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                revealPhase = 2
            }
            onRevealed(card)

            if card.rarity == .epic {
                try? await Task.sleep(for: .milliseconds(200))
                SplurjHaptics.epicReveal()
            } else if card.rarity == .legendary {
                try? await Task.sleep(for: .milliseconds(200))
                SplurjHaptics.legendaryReveal()
            }

            if hasCritical {
                try? await Task.sleep(for: .milliseconds(600))
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showCriticalBonus = true
                }
                SplurjHaptics.levelUp()
            }
        }
    }

    private func rollCriticalScratch() -> Bool {
        let roll = Double.random(in: 0...1)
        guard roll < 0.10 else { return false }
        let bonuses: [CriticalScratchBonus] = [
            .bonusEssence(50),
            .extraScratchCard,
            .doubleXP
        ]
        criticalScratchBonus = bonuses.randomElement()
        return true
    }
}

nonisolated enum CriticalScratchBonus: Sendable {
    case bonusEssence(Int)
    case extraScratchCard
    case doubleXP

    var description: String {
        switch self {
        case .bonusEssence(let amount): return "+\(amount) Bonus Essence"
        case .extraScratchCard: return "+1 Extra Scratch Card"
        case .doubleXP: return "2x XP on Next Quest"
        }
    }
}

private struct SubtleShakeModifier: ViewModifier {
    let active: Bool
    @State private var shakeOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onAppear {
                guard active else { return }
                Task {
                    for _ in 0..<3 {
                        try? await Task.sleep(for: .milliseconds(60))
                        withAnimation(.linear(duration: 0.06)) { shakeOffset = 2 }
                        try? await Task.sleep(for: .milliseconds(60))
                        withAnimation(.linear(duration: 0.06)) { shakeOffset = -2 }
                    }
                    withAnimation(.linear(duration: 0.06)) { shakeOffset = 0 }
                }
            }
    }
}
