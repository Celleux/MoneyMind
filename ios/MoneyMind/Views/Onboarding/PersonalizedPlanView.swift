import SwiftUI

struct PersonalizedPlanView: View {
    let dna: FinancialDNA
    let onComplete: () -> Void

    @State private var appeared = false

    private var archetype: FinancialArchetype { dna.primaryArchetype }

    private var insights: [(icon: String, text: String)] {
        switch archetype {
        case .guardian:
            return [
                ("shield.lefthalf.filled", "Your quests will focus on building your safety net — emergency fund, insurance audit, bill negotiation"),
                ("party.popper.fill", "We'll celebrate your saves, not push you to spend more"),
                ("hand.raised.fill", "Impulse defense tools are front and center for you"),
            ]
        case .strategist:
            return [
                ("chart.bar.fill", "Your quests will leverage your analytical strengths — statement archaeology, subscription audits, optimization challenges"),
                ("brain.head.profile.fill", "We'll give you the data and systems you crave"),
                ("heart.fill", "We'll gently remind you to enjoy what you've built"),
            ]
        case .adventurer:
            return [
                ("dollarsign.arrow.circlepath", "Your quests will channel your energy into income growth — sell unused items, negotiate raises, find side hustles"),
                ("sparkles", "We'll help you build a fun fund so you can adventure without guilt"),
                ("gamecontroller.fill", "Your gacha cards will reward smart risks, not reckless ones"),
            ]
        case .empath:
            return [
                ("person.2.fill", "Your quests will include social missions — accountability buddies, group challenges, teaching others"),
                ("lock.shield.fill", "We'll protect you from over-lending with gentle boundary quests"),
                ("bubble.left.and.bubble.right.fill", "Community features are highlighted in your experience"),
            ]
        case .visionary:
            return [
                ("arrow.up.right", "Your quests will focus on income growth and strategic investments — salary research, skill building, opportunity scouting"),
                ("chart.line.uptrend.xyaxis", "We'll help you balance bold bets with a solid foundation"),
                ("lightbulb.fill", "Side hustle and entrepreneurial quests are prioritized for you"),
            ]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 32)

            VStack(spacing: 8) {
                Image(systemName: archetype.icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(archetype.color)
                    .opacity(appeared ? 1 : 0)

                Text("Your Personalized Plan")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(appeared ? 1 : 0)

                Text("How Splurj adapts to your \(archetype.rawValue) DNA")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)
            }

            Spacer().frame(height: 28)

            VStack(spacing: 14) {
                ForEach(Array(insights.enumerated()), id: \.offset) { index, insight in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: insight.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(archetype.color)
                            .frame(width: 40, height: 40)
                            .background(archetype.color.opacity(0.1), in: .rect(cornerRadius: 10))

                        Text(insight.text)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard(cornerRadius: 14)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(0.3 + Double(index) * 0.12),
                        value: appeared
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()

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
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.8), value: appeared)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5)) {
                appeared = true
            }
        }
    }
}
