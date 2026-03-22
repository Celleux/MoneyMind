import SwiftUI
import SwiftData

struct DailyQuestStack: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<DailyQuestSlot> { $0.cadence == "daily" },
           sort: \DailyQuestSlot.offeredDate, order: .reverse)
    private var allDailySlots: [DailyQuestSlot]

    @State private var expandedQuestID: String?
    @State private var showRewardCelebration: Bool = false
    @State private var lastReward: QuestReward?

    private var todaysSlots: [DailyQuestSlot] {
        let today = Calendar.current.startOfDay(for: Date())
        return allDailySlots.filter { $0.offeredDate >= today }
    }

    private var todaysQuests: [(slot: DailyQuestSlot, quest: QuestDefinition)] {
        todaysSlots.compactMap { slot in
            guard let quest = QuestDatabase.quest(byID: slot.questID) else { return nil }
            return (slot, quest)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(Theme.gold)
                Text("Today's Quests")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                Spacer()
                Text("Resets at midnight")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(.horizontal, 20)

            if todaysQuests.isEmpty {
                AllQuestsCompleteCard()
                    .padding(.horizontal, 16)
            } else {
                ForEach(todaysQuests, id: \.quest.id) { item in
                    let engine = QuestEngine(modelContext: modelContext)
                    let progress = engine.questProgress(for: item.quest.id)
                    let isCompleted = progress?.questStatus == .completed || progress?.questStatus == .claimed

                    if !isCompleted {
                        QuestCard(
                            quest: item.quest,
                            isLucky: item.slot.isLuckyQuest,
                            isExpanded: expandedQuestID == item.quest.id,
                            progress: progress,
                            onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    expandedQuestID = expandedQuestID == item.quest.id ? nil : item.quest.id
                                }
                            },
                            onComplete: {
                                completeQuest(item.quest.id)
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }

                let completedCount = todaysQuests.filter { item in
                    let engine = QuestEngine(modelContext: modelContext)
                    return engine.isQuestCompleted(item.quest.id)
                }.count

                if completedCount == todaysQuests.count && !todaysQuests.isEmpty {
                    AllQuestsCompleteCard()
                        .padding(.horizontal, 16)
                }
            }
        }
        .fullScreenCover(isPresented: $showRewardCelebration) {
            if let reward = lastReward {
                QuestRewardCelebration(reward: reward)
            }
        }
    }

    private func completeQuest(_ questID: String) {
        let engine = QuestEngine(modelContext: modelContext)
        let playerDescriptor = FetchDescriptor<PlayerProfile>()
        guard let player = try? modelContext.fetch(playerDescriptor).first else { return }

        let quest = QuestDatabase.quest(byID: questID)

        if let quest, quest.steps.count > 1 {
            let allDone = engine.advanceQuestStep(questID)
            if !allDone { return }
        }

        let reward = engine.completeQuest(questID, player: player)
        lastReward = reward

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            expandedQuestID = nil
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showRewardCelebration = true
        }
    }
}
