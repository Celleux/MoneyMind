import SwiftUI

struct Card3DRevealSequence: View {
    let rarity: CardRarity
    let cardName: String
    let cardTip: String
    let cardSetName: String
    let cardIcon: String
    var isLastInSet: Bool = false
    var onDismiss: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: RevealPhase = .darkness
    @State private var beamScale: CGFloat = 0
    @State private var beamOpacity: Double = 0
    @State private var pulseCount: Int = 0
    @State private var showExplosion: Bool = false
    @State private var cardY: CGFloat = 200
    @State private var cardOpacity: Double = 0
    @State private var cardRotation: Double = 0
    @State private var cardSettled: Bool = false
    @State private var showStars: Bool = false
    @State private var starsRevealed: Int = 0
    @State private var showName: Bool = false
    @State private var showTip: Bool = false
    @State private var showButton: Bool = false
    @State private var bgTint: Double = 0
    @State private var shimmerPasses: Int = 0
    @State private var showSetComplete: Bool = false
    @State private var rainbowRotation: Double = 0
    @State private var floatingStarText: Bool = false
    @State private var showConfetti: Bool = false
    @State private var screenShake: CGFloat = 0

    private let isEpic: Bool
    private let isLegendary: Bool

    init(rarity: CardRarity, cardName: String, cardTip: String, cardSetName: String, cardIcon: String, isLastInSet: Bool = false, onDismiss: (() -> Void)? = nil) {
        self.rarity = rarity
        self.cardName = cardName
        self.cardTip = cardTip
        self.cardSetName = cardSetName
        self.cardIcon = cardIcon
        self.isLastInSet = isLastInSet
        self.onDismiss = onDismiss
        self.isEpic = rarity == .epic
        self.isLegendary = rarity == .legendary
    }

    private var beamColor: Color {
        isLegendary ? Theme.neonGold : Theme.neonPurple
    }

    private var rarityStarCount: Int {
        switch rarity {
        case .common: return 1
        case .uncommon: return 2
        case .rare: return 3
        case .epic: return 4
        case .legendary: return 5
        }
    }

    private enum RevealPhase {
        case darkness, beam, explosion, cardDrift, settle, details
    }

    var body: some View {
        ZStack {
            backgroundLayer

            if showExplosion {
                ParticleBurstView(
                    particleCount: isLegendary ? 60 : 30,
                    colors: isLegendary
                        ? [Theme.neonGold, Color(hex: 0xFFA500), .white, Color(hex: 0xFFEE58)]
                        : [Theme.neonPurple, Color(hex: 0x7C3AED), .white, Theme.neonBlue],
                    duration: 2.0,
                    style: .stars,
                    trigger: showExplosion
                )
                .allowsHitTesting(false)
            }

            ConfettiCanvasView(
                active: showConfetti,
                colors: isLegendary
                    ? [Theme.neonGold, .white, Color(hex: 0xFFA500)]
                    : [Theme.neonPurple, .white, Theme.neonBlue],
                particleCount: 40
            )

            beamLayer
            cardLayer
            detailsLayer

            if showSetComplete {
                setCompleteOverlay
            }
        }
        .offset(x: screenShake)
        .onTapGesture {
            if phase == .details {
                dismissCard()
            } else {
                skipToDetails()
            }
        }
        .onAppear {
            if reduceMotion {
                skipToDetails()
            } else {
                startSequence()
            }
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLegendary {
                Color(hex: 0x1A1500).opacity(bgTint).ignoresSafeArea()
            } else {
                Color(hex: 0x150025).opacity(bgTint).ignoresSafeArea()
            }
        }
    }

    // MARK: - Beam

    private var beamLayer: some View {
        Group {
            if beamOpacity > 0 {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [beamColor.opacity(0.8), beamColor.opacity(0.3), .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 60, height: UIScreen.main.bounds.height)
                    .scaleEffect(y: beamScale, anchor: .bottom)
                    .opacity(beamOpacity)
                    .blur(radius: 8)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Card

    private var cardLayer: some View {
        Group {
            if cardOpacity > 0 {
                cardContent
                    .offset(y: cardY)
                    .opacity(cardOpacity)
                    .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
                    .scaleEffect(cardSettled ? 1.0 : 0.8)
            }
        }
    }

    private var cardContent: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Theme.surface, Theme.elevated],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 240, height: 340)

                if isLegendary && !reduceMotion {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Theme.neonGold, Theme.neonEmerald,
                                    Theme.neonPurple, Theme.neonBlue, Theme.neonGold
                                ],
                                center: .center,
                                startAngle: .degrees(rainbowRotation),
                                endAngle: .degrees(rainbowRotation + 360)
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 240, height: 340)
                        .shadow(color: Theme.neonGold.opacity(0.5), radius: 16)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(beamColor.opacity(0.6), lineWidth: 2)
                        .frame(width: 240, height: 340)
                        .shadow(color: beamColor.opacity(0.3), radius: 8)
                }

                VStack(spacing: 16) {
                    Image(systemName: cardIcon)
                        .font(Typography.displayLarge)
                        .foregroundStyle(rarity.color)
                        .shadow(color: rarity.color.opacity(0.5), radius: 12)

                    Text(cardSetName.uppercased())
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textMuted)
                        .tracking(2)
                }
            }
            .holographicSheen(isActive: cardSettled && !reduceMotion)
        }
    }

    // MARK: - Details

    private var detailsLayer: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                if showStars {
                    HStack(spacing: 4) {
                        ForEach(0..<rarityStarCount, id: \.self) { i in
                            Image(systemName: "star.fill")
                                .font(Typography.bodyLarge)
                                .foregroundStyle(rarity.color)
                                .opacity(i < starsRevealed ? 1 : 0)
                                .scaleEffect(i < starsRevealed ? 1 : 0.3)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(Double(i) * 0.15), value: starsRevealed)
                        }
                    }
                    .neonGlow(color: rarity.color, radius: 12)
                }

                if showName {
                    Text(cardName)
                        .font(Typography.displaySmall)
                        .foregroundStyle(rarity.color)
                        .transition(.scale.combined(with: .opacity))
                }

                if showTip {
                    Text(cardTip)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity)
                }

                if isLegendary && floatingStarText {
                    Text("★ LEGENDARY ★")
                        .font(Typography.headingSmall)
                        .foregroundStyle(Theme.neonGold)
                        .neonGlow(color: Theme.neonGold, radius: 20)
                        .floatingAnimation(amplitude: 3, duration: 1.5)
                }

                if showButton {
                    Button {
                        dismissCard()
                    } label: {
                        Text("Add to Collection")
                            .font(Typography.headingMedium)
                            .foregroundStyle(Theme.background)
                            .frame(width: 220)
                            .padding(.vertical, 14)
                            .background(rarity.color)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .depthPop(intensity: 0.8)
                    .padding(.top, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.bottom, 80)
        }
    }

    // MARK: - Set Complete

    private var setCompleteOverlay: some View {
        VStack(spacing: 12) {
            Text("SET COMPLETE!")
                .font(Typography.displayMedium)
                .foregroundStyle(Theme.neonGold)
                .neonGlow(color: Theme.neonGold, radius: 20)
                .depthPop(intensity: 2.0)

            Text(cardSetName)
                .font(Typography.headingMedium)
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                Label("+200 Essence", systemImage: "diamond.fill")
                    .font(Typography.labelMedium)
                    .foregroundStyle(Theme.neonPurple)

                Label("Badge Earned", systemImage: "shield.checkered")
                    .font(Typography.labelMedium)
                    .foregroundStyle(Theme.neonGold)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.elevated.opacity(0.95))
                .shadow(color: Theme.neonGold.opacity(0.3), radius: 20)
        )
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Sequence

    private func startSequence() {
        if isLegendary {
            startLegendarySequence()
        } else {
            startEpicSequence()
        }
    }

    private func startEpicSequence() {
        // Beam shoots up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                beamScale = 2.0
                beamOpacity = 1.0
            }
            SplurjHaptics.epicReveal()
        }

        // Beam fades, explosion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            phase = .explosion
            showExplosion = true
            withAnimation(.easeOut(duration: 0.5)) { beamOpacity = 0 }
            withAnimation(.easeOut(duration: 0.8)) { bgTint = 0.3 }
        }

        // Card drifts in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            phase = .cardDrift
            withAnimation(.easeOut(duration: 0.6)) {
                cardOpacity = 1
                cardY = 0
            }
            withAnimation(.easeInOut(duration: 1.0)) {
                cardRotation = 360
            }
        }

        // Card settles
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            phase = .settle
            SplurjHaptics.rewardItemReveal()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                cardSettled = true
            }
        }

        // Details
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            showDetails()
        }
    }

    private func startLegendarySequence() {
        // Rainbow border rotation
        startRainbowRotation()

        // Shimmer fake-outs
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.4) {
                SplurjHaptics.coinCollect()
                withAnimation(.easeInOut(duration: 0.3)) {
                    beamOpacity = 0.5
                    beamScale = CGFloat(i + 1) * 0.5
                }
                withAnimation(.easeInOut(duration: 0.2).delay(0.15)) {
                    beamOpacity = 0
                    beamScale = 0
                }
            }
        }

        // Full beam
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            SplurjHaptics.legendaryReveal()
            withAnimation(.easeOut(duration: 0.6)) {
                beamScale = 2.5
                beamOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 1.0)) { bgTint = 0.4 }
        }

        // Explosion
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            phase = .explosion
            showExplosion = true
            showConfetti = true
            withAnimation(.easeOut(duration: 0.5)) { beamOpacity = 0 }

            withAnimation(.easeInOut(duration: 0.06).repeatCount(6, autoreverses: true)) {
                screenShake = 4
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { screenShake = 0 }
        }

        // Card enters with dramatic tilt
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            phase = .cardDrift
            withAnimation(.easeOut(duration: 0.8)) {
                cardOpacity = 1
                cardY = -20
            }
            withAnimation(.easeInOut(duration: 1.2)) {
                cardRotation = 360
            }
        }

        // Settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            phase = .settle
            SplurjHaptics.bossDamage()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                cardSettled = true
                cardY = 0
            }
        }

        // Details
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.3) {
            showDetails()
            floatingStarText = true
        }
    }

    private func showDetails() {
        phase = .details
        withAnimation(.easeOut(duration: 0.3)) { showStars = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                starsRevealed = rarityStarCount
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(rarityStarCount) * 0.15) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showName = true }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + Double(rarityStarCount) * 0.15) {
            withAnimation(.easeOut(duration: 0.3)) { showTip = true }
        }

        let buttonDelay = 1.5 + Double(rarityStarCount) * 0.15
        DispatchQueue.main.asyncAfter(deadline: .now() + buttonDelay) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showButton = true }
        }

        if isLastInSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + buttonDelay + 0.5) {
                SplurjHaptics.levelUp()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showSetComplete = true }
            }
        }

        // Auto-dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            if phase == .details && showButton { /* allow manual dismiss */ }
        }
    }

    private func skipToDetails() {
        phase = .details
        cardOpacity = 1
        cardY = 0
        cardSettled = true
        cardRotation = 0
        bgTint = isLegendary ? 0.4 : 0.3
        showStars = true
        starsRevealed = rarityStarCount
        showName = true
        showTip = true
        showButton = true
        if isLegendary { floatingStarText = true }
        if isLastInSet { showSetComplete = true }
    }

    private func dismissCard() {
        withAnimation(.easeOut(duration: 0.3)) {
            cardOpacity = 0
            cardY = 100
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SplurjHaptics.cardTap()
            onDismiss?()
            CeremonyOverlayManager.shared.dismiss()
        }
    }

    private func startRainbowRotation() {
        guard !reduceMotion else { return }
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rainbowRotation = 360
        }
    }
}
