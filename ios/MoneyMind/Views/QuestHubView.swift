import SwiftUI
import SwiftData
import PhosphorSwift

struct QuestHubView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var playerProfiles: [PlayerProfile]
    @State private var selectedTab: QuestHubTab = .dailies
    @State private var showBossBattle: Bool = false
    @State private var showQuestMap: Bool = false
    @State private var showBuddy: Bool = false
    @State private var showSplurjiBubble: Bool = false
    @State private var splurjiEngine = SplurjiMoodEngine()
    @Namespace private var animation

    private var player: PlayerProfile {
        playerProfiles.first ?? PlayerProfile()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Spacer()
                    VStack(spacing: 2) {
                        if showSplurjiBubble {
                            SpeechBubble(message: splurjiEngine.moodMessage) {
                                showSplurjiBubble = false
                            }
                            .frame(maxWidth: 180)
                            .transition(.scale.combined(with: .opacity))
                        }
                        SplurjiCharacterView(mood: splurjiEngine.currentMood, size: 60)
                            .onTapGesture {
                                splurjiEngine.showRandomMessage()
                                showSplurjiBubble = true
                                Task { @MainActor in
                                    try? await Task.sleep(for: .seconds(4))
                                    withAnimation { showSplurjiBubble = false }
                                }
                            }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSplurjiBubble)
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showBuddy = true } label: {
                    PhIcon.usersFill
                        .frame(width: 18, height: 18)
                        .foregroundStyle(Theme.accent)
                }
            }
        }
        .navigationDestination(isPresented: $showBuddy) {
            AccountabilityBuddyView()
        }
        .onAppear {
            ensurePlayerAndQuests()
            splurjiEngine.setContext(.quests)
            splurjiEngine.update(
                streakDays: player.questStreak,
                questCompletedRecently: false,
                leveledUpRecently: false,
                streakJustBroken: false
            )
            showSplurjiBubble = true
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(4))
                withAnimation { showSplurjiBubble = false }
            }
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
