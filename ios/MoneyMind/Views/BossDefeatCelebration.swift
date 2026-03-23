import SwiftUI

struct BossDefeatCelebration: View {
    let zone: QuestZone
    let player: PlayerProfile
    var onDismiss: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var phase: DefeatPhase = .shake
    @State private var bossShakeOffset: CGFloat = 0
    @State private var crackOpacity: Double = 0
    @State private var showFlash: Bool = false
    @State private var showShatter: Bool = false
    @State private var shatterFragments: [ShatterFragment] = []
    @State private var darkness: Double = 0
    @State private var showDefeatedText: Bool = false
    @State private var defeatedScale: CGFloat = 0.3
    @State private var screenShake: CGFloat = 0
    @State private var showLoot: Bool = false
    @State private var lootItems: [BossLootItem] = []
    @State private var lootRevealed: Int = 0
    @State private var showZoneProgress: Bool = false
    @State private var zoneProgress: CGFloat = 0
    @State private var showNextZone: Bool = false
    @State private var showContinue: Bool = false
    @State private var showConfetti: Bool = false

    private enum DefeatPhase {
        case shake, crack, flash, shatter, darkness, victory, loot, zone
    }

    private var nextZone: QuestZone? {
        let all = QuestZone.allCases
        guard let idx = all.firstIndex(of: zone), idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }

    private var isFinalBoss: Bool { zone == .legacy }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if showFlash {
                ScreenFlashView(color: .white, duration: 0.2, trigger: showFlash)
            }

            Color.black.opacity(darkness).ignoresSafeArea().allowsHitTesting(false)

            shatterLayer

            ConfettiCanvasView(
                active: showConfetti,
                colors: [Theme.accent, Theme.gold, .white, Theme.neonPurple, Color(hex: 0xFB923C)],
                particleCount: 60
            )

            VStack(spacing: 0) {
                Spacer()

                if phase == .shake || phase == .crack {
                    bossSection
                }

                if showDefeatedText {
                    defeatedTextSection
                        .transition(.scale(scale: 0.3).combined(with: .opacity))
                        .depthPop(intensity: 2.5)
                }

                if showLoot {
                    lootSection
                        .padding(.top, 24)
                }

                if showZoneProgress {
                    zoneProgressSection
                        .padding(.top, 20)
                        .transition(.scale.combined(with: .opacity))
                }

                if showNextZone {
                    nextZoneSection
                        .padding(.top, 16)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                if showContinue {
                    Button {
                        performDismiss()
                    } label: {
                        Text("Continue")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                isFinalBoss
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [Theme.gold, Color(hex: 0xFB923C)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                : AnyShapeStyle(Theme.accent)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 40)
                    .neonGlow(color: isFinalBoss ? Theme.neonGold : Theme.neonEmerald, radius: 10, pulses: true)
                    .padding(.bottom, 48)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .offset(x: screenShake)
        }
        .onTapGesture {
            if showContinue {
                performDismiss()
            }
        }
        .onAppear {
            if reduceMotion {
                startReducedSequence()
            } else {
                startFullSequence()
            }
        }
    }

    // MARK: - Boss Section

    private var bossSection: some View {
        ZStack {
            Image(systemName: bossIcon)
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(Theme.neonRed)
                .neonGlow(color: Theme.neonRed, radius: 20)
                .offset(x: bossShakeOffset)

            if crackOpacity > 0 {
                crackOverlay
                    .opacity(crackOpacity)
            }
        }
        .transition(.scale.combined(with: .opacity))
    }

    private var crackOverlay: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                Rectangle()
                    .fill(Theme.neonRed.opacity(0.6))
                    .frame(width: 2, height: 40 + CGFloat(i) * 10)
                    .rotationEffect(.degrees(Double(i) * 45 + 22))
            }
        }
        .frame(width: 80, height: 80)
    }

    // MARK: - Shatter Layer

    private var shatterLayer: some View {
        Canvas { context, size in
            for frag in shatterFragments {
                let rect = CGRect(
                    x: frag.x - frag.size / 2,
                    y: frag.y - frag.size / 2,
                    width: frag.size,
                    height: frag.size * 0.6
                )
                context.opacity = frag.opacity
                context.translateBy(x: frag.x, y: frag.y)
                context.rotate(by: .radians(frag.rotation))
                context.translateBy(x: -frag.x, y: -frag.y)
                context.fill(
                    RoundedRectangle(cornerRadius: 2).path(in: rect),
                    with: .color(frag.color)
                )
                context.translateBy(x: frag.x, y: frag.y)
                context.rotate(by: .radians(-frag.rotation))
                context.translateBy(x: -frag.x, y: -frag.y)
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    // MARK: - Defeated Text

    private var defeatedTextSection: some View {
        VStack(spacing: 12) {
            if isFinalBoss {
                Text("FINANCIAL FREEDOM")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.gold)
                    .tracking(4)
            }

            Text("BOSS DEFEATED")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.gold, Color(hex: 0xFB923C)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .scaleEffect(defeatedScale)
                .neonGlow(color: Theme.neonGold, radius: 30)

            Text("You defeated \(zone.bossName)")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textSecondary)

            Image(systemName: "trophy.fill")
                .font(.system(size: 52))
                .foregroundStyle(Theme.gold)
                .symbolEffect(.bounce, value: showDefeatedText)
                .shadow(color: Theme.gold.opacity(0.4), radius: 20)
                .padding(.top, 8)
                .holographicSheen(isActive: !reduceMotion)
        }
    }

    // MARK: - Loot Section

    private var lootSection: some View {
        VStack(spacing: 10) {
            ForEach(Array(lootItems.enumerated()), id: \.element.id) { index, item in
                if index < lootRevealed {
                    Parallax3DCard(maxRotation: 8) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(item.color.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: item.icon)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(item.color)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(item.subtitle)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Theme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(item.color.opacity(0.2), lineWidth: 0.5)
                                )
                        )
                    }
                    .padding(.horizontal, 32)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
        }
    }

    // MARK: - Zone Progress

    private var zoneProgressSection: some View {
        VStack(spacing: 8) {
            Text("ZONE PROGRESS")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(Theme.textMuted)
                .tracking(2)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.surface)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.accentGradient)
                        .frame(width: geo.size.width * zoneProgress)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Next Zone

    private var nextZoneSection: some View {
        Group {
            if let next = nextZone {
                VStack(spacing: 8) {
                    Text("NEW ZONE UNLOCKED")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.accent)
                        .tracking(3)

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.accent.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: next.sfSymbol)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Theme.accent)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(next.rawValue)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Levels \(next.levelRange.lowerBound)-\(next.levelRange.upperBound)")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .depthPop(intensity: 0.8)
                }
                .padding(.horizontal, 32)
            } else {
                VStack(spacing: 8) {
                    Text("ALL ZONES COMPLETE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.gold)
                        .tracking(3)
                    Text("You have achieved financial mastery")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    // MARK: - Full Sequence

    private func startFullSequence() {
        // Phase 1: Boss shakes (0-0.5s)
        SplurjHaptics.bossDefeated()

        withAnimation(.easeInOut(duration: 0.05).repeatCount(10, autoreverses: true)) {
            bossShakeOffset = 5
        }

        // Phase 2: Cracks appear (0.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            phase = .crack
            bossShakeOffset = 0
            withAnimation(.easeOut(duration: 0.3)) { crackOpacity = 1.0 }
        }

        // Phase 3: Flash (1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            phase = .flash
            showFlash = true
            SplurjHaptics.bossDamage()
        }

        // Phase 4: Shatter (1.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            phase = .shatter
            crackOpacity = 0
            spawnShatterFragments()
        }

        // Phase 5: Darkness pause (1.7s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            phase = .darkness
            withAnimation(.easeIn(duration: 0.3)) { darkness = 0.5 }
        }

        // Phase 6: Victory text slams in (2.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            phase = .victory
            SplurjHaptics.bossDefeated()
            showConfetti = true

            withAnimation(.easeIn(duration: 0.3)) { darkness = 0 }

            withAnimation(.easeInOut(duration: 0.06).repeatCount(8, autoreverses: true)) {
                screenShake = 4
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { screenShake = 0 }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showDefeatedText = true
                defeatedScale = 1.0
            }
        }

        // Phase 7: Loot cascade (3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            phase = .loot
            buildLootItems()
            showLoot = true

            for i in lootItems.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                    SplurjHaptics.rewardItemReveal()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        lootRevealed = i + 1
                    }
                }
            }
        }

        // Zone progress + next zone (4.5s)
        let zoneDelay = 3.0 + Double(4) * 0.5 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + zoneDelay) {
            phase = .zone
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showZoneProgress = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                zoneProgress = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + zoneDelay + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showNextZone = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + zoneDelay + 1.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showContinue = true
            }
        }
    }

    private func startReducedSequence() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        phase = .victory
        showDefeatedText = true
        defeatedScale = 1.0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            buildLootItems()
            showLoot = true
            lootRevealed = lootItems.count
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showZoneProgress = true
            zoneProgress = 1.0
            showNextZone = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            showContinue = true
        }
    }

    private func spawnShatterFragments() {
        let cx = UIScreen.main.bounds.width / 2
        let cy = UIScreen.main.bounds.height * 0.4
        let colors: [Color] = [Theme.neonRed, Color(hex: 0xF87171), Theme.gold, .white]

        shatterFragments = (0..<20).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 200...500)
            return ShatterFragment(
                x: cx, y: cy,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed - 100,
                size: CGFloat.random(in: 6...14),
                rotation: Double.random(in: 0...(2 * .pi)),
                rotationSpeed: Double.random(in: -10...10),
                color: colors.randomElement() ?? .white,
                opacity: 1.0
            )
        }

        let timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { t in
            for i in shatterFragments.indices {
                shatterFragments[i].x += shatterFragments[i].velocityX / 60
                shatterFragments[i].y += shatterFragments[i].velocityY / 60
                shatterFragments[i].velocityY += 600 / 60
                shatterFragments[i].rotation += shatterFragments[i].rotationSpeed / 60
                shatterFragments[i].opacity = max(0, shatterFragments[i].opacity - 0.015)
            }

            if shatterFragments.allSatisfy({ $0.opacity <= 0 }) {
                t.invalidate()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { timer.invalidate() }
    }

    private func buildLootItems() {
        lootItems = [
            BossLootItem(icon: "star.fill", title: "+500 XP", subtitle: "Boss defeat bonus", color: Theme.gold),
            BossLootItem(icon: "creditcard.fill", title: "3 Scratch Cards", subtitle: "Boss loot drop", color: Theme.accent),
            BossLootItem(icon: "diamond.fill", title: "+100 Essence", subtitle: "Rare boss materials", color: Theme.neonPurple),
            BossLootItem(icon: "shield.checkered", title: "Boss Slayer Badge", subtitle: "Defeated \(zone.bossName)", color: Theme.neonRed)
        ]
    }

    private func performDismiss() {
        SplurjHaptics.cardTap()
        onDismiss?()
        dismiss()
        CeremonyOverlayManager.shared.dismiss()
    }

    private var bossIcon: String {
        switch zone {
        case .awakening: return "eye.trianglebadge.exclamationmark.fill"
        case .budgetForge: return "flame.circle.fill"
        case .savingsCitadel: return "building.columns.circle.fill"
        case .incomeFrontier: return "lizard.fill"
        case .legacy: return "crown.fill"
        }
    }
}

private struct ShatterFragment {
    var x: CGFloat
    var y: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var size: CGFloat
    var rotation: Double
    var rotationSpeed: Double
    var color: Color
    var opacity: Double
}

private struct BossLootItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}
