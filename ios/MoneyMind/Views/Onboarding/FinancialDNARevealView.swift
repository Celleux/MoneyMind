import SwiftUI

struct FinancialDNARevealView: View {
    let dna: FinancialDNA
    let onComplete: () -> Void

    @State private var phase: Int = 0
    @State private var scrollEnabled = false
    @State private var radarAnimated = false

    private var archetype: FinancialArchetype { dna.primaryArchetype }
    private var secondary: FinancialArchetype { dna.secondaryArchetype }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if scrollEnabled {
                scrollableContent
            } else {
                cinematicReveal
            }
        }
        .onAppear { startRevealSequence() }
    }

    private var cinematicReveal: some View {
        ZStack {
            Circle()
                .fill(Theme.accent.opacity(phase >= 1 ? 0.15 : 0))
                .frame(width: phase >= 1 ? 12 : 4, height: phase >= 1 ? 12 : 4)
                .scaleEffect(phase >= 1 ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: phase)

            if phase >= 1 {
                Text("Your Financial DNA is ready.")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .offset(y: -60)
                    .transition(.opacity)
            }

            if phase >= 2 {
                DNARadarShape(dna: dna, animated: radarAnimated)
                    .frame(width: 200, height: 200)
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
            }

            if phase >= 3 {
                VStack(spacing: 8) {
                    Image(systemName: archetype.icon)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(archetype.color)

                    Text(archetype.rawValue.uppercased())
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .tracking(4)

                    Text(archetype.tagline)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(archetype.color)
                }
                .offset(y: 140)
                .transition(.scale(scale: 0.7).combined(with: .opacity))
            }
        }
    }

    private var scrollableContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                FinancialDNACardView(dna: dna)
                    .padding(.horizontal, 32)

                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle("Your Superpower", icon: "bolt.fill", color: Theme.gold)

                    Text(dna.superpower)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.gold)

                    Text(superpowerDescription)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(4)
                }
                .padding(20)
                .glassCard()
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle("Your Blind Spot", icon: "eye.trianglebadge.exclamationmark.fill", color: Color(hex: 0xFB923C))

                    Text(dna.vulnerability)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0xFB923C))

                    Text("This isn't a flaw — it's the shadow side of your superpower.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                        .italic()
                }
                .padding(20)
                .glassCard()
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle("Your Blend", icon: "person.2.fill", color: archetype.color)

                    HStack(spacing: 16) {
                        archetypePill(archetype, label: "Primary")
                        archetypePill(secondary, label: "Secondary")
                    }

                    Text(blendDescription)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(3)
                }
                .padding(20)
                .glassCard()
                .padding(.horizontal, 24)

                VStack(spacing: 10) {
                    DNAAxisPreviewCard(title: "Spending Style", icon: "shield.lefthalf.filled", color: Color(hex: 0x34D399), value: dna.spendingAxis)
                    DNAAxisPreviewCard(title: "Money Emotions", icon: "brain.head.profile.fill", color: Color(hex: 0x60A5FA), value: dna.emotionalAxis)
                    DNAAxisPreviewCard(title: "Risk Profile", icon: "flame.fill", color: Color(hex: 0xFB923C), value: dna.riskAxis)
                    DNAAxisPreviewCard(title: "Social Money", icon: "person.2.fill", color: Color(hex: 0xF472B6), value: dna.socialAxis)
                }
                .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.accent)

                    Text("How This Personalizes Splurj")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your DNA shapes which quests appear, which challenges suit you, and how the app coaches you. No two Splurj experiences are alike.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(20)
                .glassCard()
                .padding(.horizontal, 24)

                ShareLink(
                    item: "I just discovered my Financial DNA on Splurj! I'm \(archetype.rawValue) with a \(dna.superpower) superpower. Discover yours at splurj.app",
                    preview: SharePreview("My Financial DNA", image: Image(systemName: archetype.icon))
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share My Financial DNA")
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accent.opacity(0.1), in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)

                Button(action: onComplete) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .scrollIndicators(.hidden)
    }

    private func sectionTitle(_ text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
            Text(text.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .tracking(2)
        }
    }

    private func archetypePill(_ type: FinancialArchetype, label: String) -> some View {
        VStack(spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textMuted)
                .tracking(1)

            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(type.color)

                Text(type.rawValue.replacingOccurrences(of: "The ", with: ""))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(type.color.opacity(0.1), in: .rect(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(type.color.opacity(0.25), lineWidth: 1)
            )
        }
    }

    private var superpowerDescription: String {
        switch dna.superpower {
        case "Discipline": "You have an extraordinary ability to delay gratification. Where others give in, you hold the line."
        case "Discovery": "Your openness to new experiences creates a rich, varied financial life."
        case "Logic": "You cut through emotional noise and see money for what it is — data to optimize."
        case "Intuition": "You sense financial danger before the numbers confirm it."
        case "Courage": "You take calculated leaps that others won't. That's how fortunes are built."
        case "Caution": "Your careful approach means you rarely lose. Slow and steady builds real wealth."
        case "Generosity": "Your willingness to share creates a network of trust that money can't buy."
        case "Independence": "You protect your financial autonomy fiercely — and that's a rare strength."
        default: "A balanced approach that adapts to any financial situation."
        }
    }

    private var blendDescription: String {
        let primary = archetype.rawValue.replacingOccurrences(of: "The ", with: "")
        let sec = secondary.rawValue.replacingOccurrences(of: "The ", with: "")
        let primaryPct = Int(max(55, min(80, abs(dna.spendingAxis - 0.5) * 100 + 55)))
        let secPct = 100 - primaryPct
        return "You're \(primaryPct)% \(primary), \(secPct)% \(sec). \(archetype.strengths.first ?? "") meets \(secondary.strengths.last ?? "")."
    }

    private func startRevealSequence() {
        Task {
            try? await Task.sleep(for: .milliseconds(800))
            withAnimation(.spring(response: 0.6)) { phase = 1 }

            try? await Task.sleep(for: .seconds(2))
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { phase = 2 }

            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) { radarAnimated = true }

            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) { phase = 3 }

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            try? await Task.sleep(for: .seconds(2))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { scrollEnabled = true }
        }
    }
}

struct DNARadarShape: View {
    let dna: FinancialDNA
    let animated: Bool

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let maxR = min(size.width, size.height) / 2 * 0.85

            let values = animated
                ? [dna.spendingAxis, dna.emotionalAxis, dna.riskAxis, dna.socialAxis]
                : [0.0, 0.0, 0.0, 0.0]

            for ring in stride(from: 0.25, through: 1.0, by: 0.25) {
                var ringPath = Path()
                for i in 0..<4 {
                    let angle = Double(i) * (.pi / 2) - .pi / 2
                    let x = center.x + cos(angle) * maxR * ring
                    let y = center.y + sin(angle) * maxR * ring
                    if i == 0 { ringPath.move(to: CGPoint(x: x, y: y)) }
                    else { ringPath.addLine(to: CGPoint(x: x, y: y)) }
                }
                ringPath.closeSubpath()
                context.stroke(ringPath, with: .color(Theme.elevated), lineWidth: 0.5)
            }

            for i in 0..<4 {
                let angle = Double(i) * (.pi / 2) - .pi / 2
                var line = Path()
                line.move(to: center)
                line.addLine(to: CGPoint(
                    x: center.x + cos(angle) * maxR,
                    y: center.y + sin(angle) * maxR
                ))
                context.stroke(line, with: .color(Theme.elevated.opacity(0.5)), lineWidth: 0.5)
            }

            var shape = Path()
            for i in 0..<4 {
                let angle = Double(i) * (.pi / 2) - .pi / 2
                let r = maxR * max(0.1, values[i])
                let point = CGPoint(
                    x: center.x + cos(angle) * r,
                    y: center.y + sin(angle) * r
                )
                if i == 0 { shape.move(to: point) }
                else { shape.addLine(to: point) }
            }
            shape.closeSubpath()

            let archColor = dna.primaryArchetype.color
            context.fill(shape, with: .color(archColor.opacity(0.2)))
            context.stroke(shape, with: .color(archColor.opacity(0.8)), lineWidth: 2)

            for i in 0..<4 {
                let angle = Double(i) * (.pi / 2) - .pi / 2
                let r = maxR * max(0.1, values[i])
                let point = CGPoint(
                    x: center.x + cos(angle) * r,
                    y: center.y + sin(angle) * r
                )
                var dot = Path()
                dot.addEllipse(in: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8))
                context.fill(dot, with: .color(archColor))
            }
        }
        .animation(.spring(response: 1.2, dampingFraction: 0.6), value: animated)
    }
}
