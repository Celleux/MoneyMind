import SwiftUI
import SwiftData

struct QuestHubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var playerProfiles: [PlayerProfile]
    @State private var selectedTab: QuestHubTab = .dailies
    @State private var showBossBattle: Bool = false
    @Namespace private var animation

    private var player: PlayerProfile {
        playerProfiles.first ?? PlayerProfile()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                QuestHeroHeader(player: player)
                    .padding(.bottom, 16)

                ZoneBanner(zone: player.currentQuestZone)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                QuestTabBar(selectedTab: $selectedTab, namespace: animation)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                switch selectedTab {
                case .dailies:
                    DailyQuestStack()
                case .weekly:
                    WeeklyQuestStack()
                case .chains:
                    QuestChainGrid()
                case .boss:
                    BossBattleCard(
                        zone: player.currentQuestZone,
                        damageDealt: player.currentBossDamageDealt,
                        onFight: {
                            showBossBattle = true
                        }
                    )
                }

                Spacer(minLength: 100)
            }
        }
        .background(
            LinearGradient(
                colors: player.currentQuestZone.gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Quests")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            ensurePlayerAndQuests()
        }
        .fullScreenCover(isPresented: $showBossBattle) {
            BossBattleSheet(player: player, zone: player.currentQuestZone)
        }
    }

    private func ensurePlayerAndQuests() {
        let engine = QuestEngine(modelContext: modelContext)
        let player = engine.getOrCreatePlayer()
        engine.refreshDailyQuests(player: player)
        engine.refreshWeeklyQuests(player: player)
    }
}

private struct BossBattleSheet: View {
    let player: PlayerProfile
    let zone: QuestZone
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var defeated: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.background, Color(hex: 0x1A0A0A)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Theme.textMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                if defeated {
                    VStack(spacing: 16) {
                        Text("BOSS DEFEATED")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.gold, Color(hex: 0xFB923C)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Theme.gold.opacity(0.5), radius: 20)

                        Text("You defeated \(zone.bossName)")
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.textSecondary)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Theme.gold)
                            .symbolEffect(.bounce)

                        Text("Scratch card and 100 essence earned")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.accent)

                        Button {
                            dismiss()
                        } label: {
                            Text("Continue")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Theme.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 40)
                    }
                } else {
                    Text(zone.bossName.uppercased())
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(Color(hex: 0xF87171))
                        .tracking(3)

                    Image(systemName: bossIcon(for: zone))
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: 0xF87171), Color(hex: 0x991B1B)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(hex: 0xF87171).opacity(0.6), radius: 30)

                    if player.currentBossDamageDealt >= zone.bossHP {
                        Button {
                            let engine = QuestEngine(modelContext: modelContext)
                            let success = engine.defeatBoss(player: player, zone: zone)
                            if success {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    defeated = true
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("DELIVER FINAL BLOW")
                                    .font(.system(size: 16, weight: .black))
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Theme.gold, Color(hex: 0xFB923C)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Theme.gold.opacity(0.5), radius: 20)
                        }
                        .padding(.horizontal, 40)
                    } else {
                        Text("Deal more damage by completing quests")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textMuted)
                    }
                }

                Spacer()
            }
        }
    }

    private func bossIcon(for zone: QuestZone) -> String {
        switch zone {
        case .awakening: return "eye.trianglebadge.exclamationmark.fill"
        case .budgetForge: return "flame.circle.fill"
        case .savingsCitadel: return "building.columns.circle.fill"
        case .incomeFrontier: return "lizard.fill"
        case .legacy: return "crown.fill"
        }
    }
}
