import SwiftUI

struct CardArtView: View {
    let card: CardDefinition
    @State private var holoPulse: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            card.rarity.color.opacity(0.3),
                            Theme.surface,
                            Theme.background
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if card.rarity != .common {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(card.rarity.color, lineWidth: card.rarity == .legendary ? 2.5 : 1.5)
                    .shadow(color: card.rarity.color.opacity(card.rarity.glowOpacity), radius: 8)
                    .shadow(color: card.rarity.color.opacity(card.rarity.glowOpacity * 0.5), radius: 16)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.glassBorder, lineWidth: 0.5)
            }

            VStack(spacing: 10) {
                Spacer()

                Image(systemName: card.set.icon)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(card.rarity.color)
                    .shadow(color: card.rarity.color.opacity(card.rarity == .legendary ? 0.6 : 0.3), radius: card.rarity == .legendary ? 12 : 4)

                Text(card.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)

                Text(card.rarity.label)
                    .font(.system(size: 11))
                    .foregroundStyle(card.rarity.color)

                Text(card.tip)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 10)

                Spacer()

                Text(card.set.rawValue)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(card.set.accentColor.opacity(0.6))
                    .padding(.bottom, 10)
            }
            .padding(.vertical, 8)

            if card.rarity == .legendary {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                Theme.gold.opacity(holoPulse ? 0.12 : 0.06),
                                .clear,
                                Theme.accent.opacity(holoPulse ? 0.1 : 0.04),
                                .clear
                            ]),
                            center: .center
                        )
                    )
                    .blendMode(.overlay)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            holoPulse = true
                        }
                    }
            }

            if card.rarity == .epic {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        card.rarity.color.opacity(holoPulse ? 0.5 : 0.2),
                        lineWidth: 1.5
                    )
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            holoPulse = true
                        }
                    }
            }
        }
        .clipShape(.rect(cornerRadius: 12))
    }
}
