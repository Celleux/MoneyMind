import SwiftUI

struct Quest3DRewardSequence: View {
    let reward: QuestReward
    var onOpenVault: (() -> Void)?
    var onDismiss: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: RewardPhase = .anticipation
    @State private var dimOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.3
    @State private var autoTilt: Double = 0
    @State private var glowPulse: Bool = false
    @State private var showTitle: Bool = false
    @State private var showSubtitle: Bool = false
    @State private var dotsPulsing: Bool = false
    @State private var xpCount: Int = 0
    @State private var xpFontSize: CGFloat = 18
    @State private var xpBounce: CGFloat = 1.0
    @State private var showOrbs: Bool = false
    @State private var orbPositions: [OrbState] = []
    @State private var backgroundPulse: Bool = false
    @State private var cardSnap: Bool = false
    @State private var showFlash: Bool = false
    @State private var cardFlip: Double = 0
    @State private var showScratchReward: Bool = false
    @State private var showEssenceReward: Bool = false
    @State private var showBossReward: Bool = false
    @State private var showStreakReward: Bool = false
    @State private var showConfetti: Bool = false
    @State private var showCardZoom: Bool = false
    @State private var cardZoomScale: CGFloat = 0.3
    @State private var showLevelUp: Bool = false
    @State private var levelScale: CGFloat = 0
    @State private var screenShake: CGFloat = 0
    @State private var showShareSection: Bool = false
    @State private var showVaultPrompt: Bool = false
    @State private var showContinue: Bool = false
    @State private var showStreakCards: Bool = false
    @State private var showDoubleXP: Bool = false
    @State private var floatingTexts: [FloatingRewardText] = []

    private enum RewardPhase {
        case anticipation, buildUp, reveal, celebration, social
    }

    var body: some View {
        ZStack {
            Color.black.opacity(dimOpacity)
                .ignoresSafeArea()

            if backgroundPulse && !reduceMotion {
                RadialGradient(
                    colors: [Theme.accent.opacity(0.12), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                )
                .scaleEffect(backgroundPulse ? 1.4 : 0.6)
                .opacity(backgroundPulse ? 0 : 0.6)
                .animation(.easeOut(duration: 1.8).repeatForever(autoreverses: false), value: backgroundPulse)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }

            if showFlash {
                ScreenFlashView(color: Theme.neonGold, duration: 0.15, trigger: showFlash)
            }

            ConfettiCanvasView(
                active: showConfetti,
                colors: [Theme.accent, Theme.gold, .white, Theme.neonPurple, Theme.neonBlue],
                particleCount: 50
            )

            if !reduceMotion {
                orbLayer
            }

            floatingTextLayer

            VStack(spacing: 16) {
                Spacer()
                anticipationContent
                buildUpContent
                revealContent
                celebrationContent
                Spacer()
                bottomActions
                Spacer().frame(height: 32)
            }
            .offset(x: screenShake)
        }
        .onTapGesture {
            if phase != .social {
                skipToSocial()
            } else {
                dismissSequence()
            }
        }
        .onAppear {
            if reduceMotion {
                runReducedSequence()
            } else {
                runFullSequence()
            }
        }
    }

    // MARK: - Anticipation

    private var anticipationContent: some View {
        VStack(spacing: 10) {
            if showTitle {
                Parallax3DCard(maxRotation: 5, enableHolographic: cardSnap) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.surface)
                            .frame(width: 80, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
                            )

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.accent)
                    }
                }
                .scaleEffect(iconScale)
                .neonGlow(color: Theme.neonGold, radius: glowPulse ? 25 : 10, pulses: true)
                .rotation3DEffect(.degrees(reduceMotion ? 0 : autoTilt), axis: (x: 0, y: 1, z: 0))
                .transition(.scale.combined(with: .opacity))
            }

            if showSubtitle {
                Text("QUEST COMPLETE")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .tracking(4)
                    .transition(.opacity)
            }

            if dotsPulsing {
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Theme.accent.opacity(0.5))
                            .frame(width: 6, height: 6)
                            .scaleEffect(dotsPulsing ? 1.3 : 0.7)
                            .animation(
                                .easeInOut(duration: 0.4).repeatForever(autoreverses: true).delay(Double(i) * 0.12),
                                value: dotsPulsing
                            )
                    }
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Build-Up

    private var buildUpContent: some View {
        Group {
            if xpCount > 0 {
                VStack(spacing: 4) {
                    Text("+\(xpCount)")
                        .font(.system(size: xpFontSize, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.gold, Color(hex: 0xFBBF24)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .contentTransition(.numericText(value: Double(xpCount)))
                        .scaleEffect(xpBounce)
                        .neonGlow(color: Theme.neonEmerald, radius: 16)

                    Text("EXPERIENCE POINTS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(2)

                    if reward.isLucky {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10))
                            Text("LUCKY QUEST BONUS")
                                .font(.system(size: 9, weight: .heavy))
                                .tracking(1)
                        }
                        .foregroundStyle(Theme.gold)
                    }
                }
                .depthPop(intensity: cardSnap ? 1.5 : 0)
                .transition(.scale(scale: 0.6).combined(with: .opacity))
            }
        }
    }

    // MARK: - Reveal

    private var revealContent: some View {
        VStack(spacing: 14) {
            if reward.scratchCard && showScratchReward {
                rewardRow(
                    icon: "creditcard.fill",
                    iconColor: Theme.accent,
                    title: "Scratch Card Earned",
                    subtitle: "Head to The Vault to reveal it"
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            }

            if reward.essence > 0 && showEssenceReward {
                rewardRow(
                    icon: "diamond.fill",
                    iconColor: Theme.neonPurple,
                    title: "+\(reward.essence) Essence",
                    subtitle: "Added to your vault"
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            }

            if reward.bossDamage > 0 && showBossReward {
                rewardRow(
                    icon: "bolt.fill",
                    iconColor: Theme.neonRed,
                    title: "-\(reward.bossDamage) Boss HP",
                    subtitle: "Critical hit!"
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            }

            if showStreakReward {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xFB923C), Color(hex: 0xF87171)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .symbolEffect(.bounce, value: showStreakReward)

                    Text("Quest Streak Active")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: 0xFB923C))
                }
            }
        }
    }

    private func rewardRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(iconColor.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: iconColor.opacity(0.15), radius: 10)
        )
        .padding(.horizontal, 32)
    }

    // MARK: - Celebration

    private var celebrationContent: some View {
        VStack(spacing: 12) {
            if showCardZoom && reward.scratchCard {
                VStack(spacing: 8) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.accent)
                        .scaleEffect(cardZoomScale)
                        .neonGlow(color: Theme.neonEmerald, radius: 24)
                        .depthPop(intensity: 1.5)
                        .rotation3DEffect(.degrees(cardFlip), axis: (x: 0, y: 1, z: 0))

                    Text("A card awaits in The Vault")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.accent)
                }
                .transition(.scale.combined(with: .opacity))
            }

            if reward.didLevelUp && showLevelUp {
                VStack(spacing: 10) {
                    Text("LEVEL UP")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.gold, Color(hex: 0xFB923C), Theme.gold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Theme.gold.opacity(0.6), radius: 30)
                        .scaleEffect(levelScale)
                        .depthPop(intensity: 2.0)

                    Text("Level \(reward.newLevel)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.neonGold)
                        .neonGlow(color: Theme.neonGold, radius: 30)
                }
                .transition(.scale(scale: 0.3).combined(with: .opacity))
            }

            if reward.streakBonusCards > 0 && showStreakCards {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.neonGold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Streak Bonus!")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.neonGold)
                        Text("+\(reward.streakBonusCards) bonus scratch card\(reward.streakBonusCards == 1 ? "" : "s")")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .transition(.scale(scale: 0.7).combined(with: .opacity))
            }

            if reward.hasDoubleXP && showDoubleXP {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.neonGold)
                    Text("2x XP Active")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.neonGold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Theme.neonGold.opacity(0.15), in: Capsule())
                .transition(.scale(scale: 0.7).combined(with: .opacity))
            }
        }
    }

    // MARK: - Orb Layer

    private var orbLayer: some View {
        Canvas { context, size in
            for orb in orbPositions {
                let rect = CGRect(
                    x: orb.x - orb.size / 2,
                    y: orb.y - orb.size / 2,
                    width: orb.size,
                    height: orb.size
                )
                context.opacity = orb.opacity
                context.fill(Circle().path(in: rect), with: .color(orb.color))
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    // MARK: - Floating Text

    private var floatingTextLayer: some View {
        ZStack {
            ForEach(floatingTexts) { ft in
                FloatingTextView(text: ft.text, color: ft.color, fontSize: ft.fontSize)
                    .position(x: ft.x, y: ft.y)
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    // MARK: - Bottom Actions

    private var bottomActions: some View {
        VStack(spacing: 12) {
            if reward.tiktokMoment != nil && showShareSection {
                shareSection
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if reward.scratchCard && showVaultPrompt {
                vaultPromptSection
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if showContinue {
                Button { dismissSequence() } label: {
                    Text("Continue")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)
                .depthPop(intensity: 0.5)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    private var shareSection: some View {
        if let moment = reward.tiktokMoment {
            VStack(spacing: 10) {
                Text(moment)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                ShareLink(item: moment) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .bold))
                        Text("Share your win")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Theme.accent.opacity(0.15)))
                    .overlay(Capsule().stroke(Theme.accent.opacity(0.3), lineWidth: 1))
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.surface)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.accent.opacity(0.2), lineWidth: 0.5))
            )
            .padding(.horizontal, 32)
        }
    }

    private var vaultPromptSection: some View {
        VStack(spacing: 10) {
            Text("You earned a scratch card")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: 12) {
                Button {
                    dismissSequence()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onOpenVault?()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 13))
                        Text("Open Vault")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Theme.accentGradient, in: Capsule())
                    .neonGlow(color: Theme.neonPurple, radius: 8)
                }

                Button {
                    withAnimation { showVaultPrompt = false }
                } label: {
                    Text("Later")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Theme.surface, in: Capsule())
                        .overlay(Capsule().stroke(Theme.border, lineWidth: 0.5))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Theme.elevated)
                .shadow(color: .black.opacity(0.3), radius: 12)
        )
        .padding(.horizontal, 32)
    }

    // MARK: - Full Sequence

    private func runFullSequence() {
        // Phase A: Anticipation (0-1s)
        SplurjHaptics.rewardItemReveal()

        withAnimation(.easeOut(duration: 0.3)) { dimOpacity = 0.7 }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15)) {
            showTitle = true
            iconScale = 1.0
        }

        withAnimation(.easeOut(duration: 0.3).delay(0.35)) { showSubtitle = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { dotsPulsing = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SplurjHaptics.coinCollect()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            SplurjHaptics.coinCollect()
        }

        startAutoTilt()

        // Phase B: Build-Up (1.0-2.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            phase = .buildUp
            dotsPulsing = false
            glowPulse = true
            backgroundPulse = true
            spawnOrbs()
            animateXPCounter()
        }

        // Phase C: Reveal (2.5-3.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            phase = .reveal
            cardSnap = true
            showFlash = true
            SplurjHaptics.bossDamage()

            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                xpBounce = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    xpBounce = 1.0
                }
            }
        }

        var revealDelay: Double = 2.8

        if reward.scratchCard {
            DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
                SplurjHaptics.rewardItemReveal()
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(revealDelay)) {
                showScratchReward = true
            }
            revealDelay += 0.3
        }

        if reward.essence > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
                SplurjHaptics.rewardItemReveal()
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(revealDelay)) {
                showEssenceReward = true
            }
            revealDelay += 0.3
        }

        if reward.bossDamage > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
                SplurjHaptics.bossDamage()
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(revealDelay)) {
                showBossReward = true
            }
            revealDelay += 0.3
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
            SplurjHaptics.streakIncrement()
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(revealDelay)) {
            showStreakReward = true
        }
        revealDelay += 0.4

        // Phase D: Celebration (3.5-5.0s)
        let celebDelay = revealDelay

        DispatchQueue.main.asyncAfter(deadline: .now() + celebDelay) {
            phase = .celebration

            if reward.scratchCard {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showCardZoom = true
                    cardZoomScale = 1.3
                }
                withAnimation(.easeInOut(duration: 0.8)) { cardFlip = 360 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { cardZoomScale = 1.0 }
                }
            }

            showConfetti = true
            spawnFloatingTexts()
        }

        if reward.didLevelUp {
            DispatchQueue.main.asyncAfter(deadline: .now() + celebDelay + 0.5) {
                SplurjHaptics.levelUp()

                withAnimation(.easeInOut(duration: 0.06).repeatCount(8, autoreverses: true)) {
                    screenShake = 3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { screenShake = 0 }

                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showLevelUp = true
                    levelScale = 1.0
                }
            }
        }

        if reward.streakBonusCards > 0 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(celebDelay + 0.8)) {
                showStreakCards = true
            }
        }

        if reward.hasDoubleXP {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(celebDelay + 1.0)) {
                showDoubleXP = true
            }
        }

        // Phase E: Social (5.0s+)
        let socialDelay = celebDelay + 1.5

        DispatchQueue.main.asyncAfter(deadline: .now() + socialDelay) {
            phase = .social

            if reward.tiktokMoment != nil {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showShareSection = true
                }
            }

            if reward.scratchCard && onOpenVault != nil {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
                    showVaultPrompt = true
                }
            }

            withAnimation(.easeOut(duration: 0.3).delay(0.5)) {
                showContinue = true
            }
        }

        // Auto-dismiss timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + socialDelay + 8) {
            if phase == .social { dismissSequence() }
        }
    }

    // MARK: - Reduced

    private func runReducedSequence() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dimOpacity = 0.7
        showTitle = true
        iconScale = 1.0
        showSubtitle = true
        cardSnap = true
        xpCount = reward.xp
        xpFontSize = 32
        phase = .social

        if reward.scratchCard { showScratchReward = true }
        if reward.essence > 0 { showEssenceReward = true }
        if reward.bossDamage > 0 { showBossReward = true }
        showStreakReward = true
        if reward.didLevelUp { showLevelUp = true; levelScale = 1.0 }
        if reward.streakBonusCards > 0 { showStreakCards = true }
        if reward.hasDoubleXP { showDoubleXP = true }
        if reward.tiktokMoment != nil { showShareSection = true }
        if reward.scratchCard && onOpenVault != nil { showVaultPrompt = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showContinue = true }
    }

    // MARK: - Helpers

    private func skipToSocial() {
        phase = .social
        dimOpacity = 0.7
        showTitle = true
        iconScale = 1.0
        showSubtitle = true
        cardSnap = true
        xpCount = reward.xp
        xpFontSize = 32
        dotsPulsing = false

        if reward.scratchCard { showScratchReward = true }
        if reward.essence > 0 { showEssenceReward = true }
        if reward.bossDamage > 0 { showBossReward = true }
        showStreakReward = true
        if reward.didLevelUp { showLevelUp = true; levelScale = 1.0 }
        if reward.streakBonusCards > 0 { showStreakCards = true }
        if reward.hasDoubleXP { showDoubleXP = true }
        if reward.tiktokMoment != nil { showShareSection = true }
        if reward.scratchCard && onOpenVault != nil { showVaultPrompt = true }
        showContinue = true
    }

    private func dismissSequence() {
        withAnimation(.easeOut(duration: 0.3)) {
            dimOpacity = 0
            iconScale = 0.5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SplurjHaptics.cardTap()
            onDismiss?()
            CeremonyOverlayManager.shared.dismiss()
        }
    }

    private func startAutoTilt() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            autoTilt = 5
        }
    }

    private func animateXPCounter() {
        let target = reward.xp
        let steps = 25
        let interval = 0.8 / Double(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                withAnimation(.linear(duration: interval)) {
                    xpCount = Int(Double(target) * Double(i) / Double(steps))
                    xpFontSize = 18 + CGFloat(i) / CGFloat(steps) * 42
                }
                if i % 5 == 0 { SplurjHaptics.coinCollect() }
            }
        }
    }

    private func spawnOrbs() {
        guard !reduceMotion else { return }
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height
        let centerX = screenW / 2
        let centerY = screenH * 0.35

        orbPositions = (0..<8).map { i in
            let edge = Int.random(in: 0...3)
            let startX: CGFloat
            let startY: CGFloat
            switch edge {
            case 0: startX = CGFloat.random(in: 0...screenW); startY = -20
            case 1: startX = screenW + 20; startY = CGFloat.random(in: 0...screenH)
            case 2: startX = CGFloat.random(in: 0...screenW); startY = screenH + 20
            default: startX = -20; startY = CGFloat.random(in: 0...screenH)
            }
            return OrbState(
                x: startX, y: startY,
                targetX: centerX + CGFloat.random(in: -20...20),
                targetY: centerY + CGFloat.random(in: -20...20),
                size: CGFloat.random(in: 6...12),
                color: i % 2 == 0 ? Theme.neonGold : Theme.neonEmerald,
                opacity: 0.8
            )
        }

        for i in orbPositions.indices {
            let delay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard i < orbPositions.count else { return }
                withAnimation(.easeIn(duration: 0.5)) {
                    orbPositions[i].x = orbPositions[i].targetX
                    orbPositions[i].y = orbPositions[i].targetY
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    guard i < orbPositions.count else { return }
                    SplurjHaptics.coinCollect()
                    withAnimation(.easeOut(duration: 0.2)) {
                        orbPositions[i].opacity = 0
                    }
                }
            }
        }
    }

    private func spawnFloatingTexts() {
        let screenW = UIScreen.main.bounds.width
        var texts: [FloatingRewardText] = []

        texts.append(FloatingRewardText(
            text: "+\(reward.xp) XP!",
            color: Theme.neonGold,
            fontSize: 20,
            x: screenW * 0.3,
            y: UIScreen.main.bounds.height * 0.35
        ))

        texts.append(FloatingRewardText(
            text: "QUEST COMPLETE!",
            color: Theme.neonEmerald,
            fontSize: 16,
            x: screenW * 0.65,
            y: UIScreen.main.bounds.height * 0.4
        ))

        floatingTexts = texts
    }
}

private struct OrbState {
    var x: CGFloat
    var y: CGFloat
    let targetX: CGFloat
    let targetY: CGFloat
    let size: CGFloat
    let color: Color
    var opacity: Double
}

private struct FloatingRewardText: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
    let fontSize: CGFloat
    let x: CGFloat
    let y: CGFloat
}
