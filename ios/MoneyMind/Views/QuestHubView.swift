import SwiftUI
import SwiftData

struct QuestHubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var playerProfiles: [PlayerProfile]
    @State private var selectedTab: QuestHubTab = .dailies
    @State private var showBossBattle: Bool = false
    @State private var showQuestMap: Bool = false
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
                    .onTapGesture { showQuestMap = true }
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
            BossBattleView(player: player, zone: player.currentQuestZone)
        }
        .fullScreenCover(isPresented: $showQuestMap) {
            QuestMapView(player: player)
        }
    }

    private func ensurePlayerAndQuests() {
        let engine = QuestEngine(modelContext: modelContext)
        let player = engine.getOrCreatePlayer()
        engine.refreshDailyQuests(player: player)
        engine.refreshWeeklyQuests(player: player)
    }
}
