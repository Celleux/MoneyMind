import SwiftUI

struct QuestHeroHeader: View {
    let player: PlayerProfile
    @State private var xpAnimating: Bool = false
    @State private var avatarGlow: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: player.currentQuestZone.gradientColors + [player.currentQuestZone.gradientColors.first ?? Theme.accent],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 72, height: 72)
                        .blur(radius: avatarGlow ? 6 : 2)
                        .animation(.easeInOut(duration: 2).repeatForever(), value: avatarGlow)

                    Image(systemName: avatarIcon(stage: player.avatarStage))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.accent, Theme.gold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .background(Theme.elevated)
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(player.activeTitle)
                        .font(.caption)
                        .foregroundStyle(Theme.accent)
                        .tracking(1.5)
                        .textCase(.uppercase)

                    Text("Level \(player.level)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Theme.elevated)
                                .frame(height: 12)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.accent, Theme.accent.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * player.xpProgressFraction, height: 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [.clear, .white.opacity(0.3), .clear],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .offset(x: xpAnimating ? geo.size.width : -geo.size.width)
                                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: xpAnimating)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            Text("\(player.xpProgressInCurrentLevel) / \(player.xpForCurrentLevel) XP")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.9))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 12)
                }

                Spacer()

                VStack(spacing: 2) {
                    Image(systemName: player.questStreak > 0 ? "flame.fill" : "flame")
                        .font(.system(size: 24))
                        .foregroundStyle(player.questStreak > 0 ? Color(hex: 0xFB923C) : Theme.textMuted)
                        .symbolEffect(.pulse, isActive: player.questStreak >= 7)

                    Text("\(player.questStreak)")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("streak")
                        .font(.system(size: 8))
                        .foregroundStyle(Theme.textMuted)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
        .onAppear {
            xpAnimating = true
            avatarGlow = true
        }
    }

    private func avatarIcon(stage: Int) -> String {
        switch stage {
        case 0: return "shield.fill"
        case 1: return "bolt.shield.fill"
        case 2: return "building.columns.fill"
        case 3: return "crown.fill"
        default: return "star.fill"
        }
    }
}
