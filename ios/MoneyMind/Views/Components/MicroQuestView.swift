import SwiftUI
import SwiftData

struct MicroQuestView: View {
    let quests: [QuestDefinition]
    let onComplete: (String) -> Void

    @State private var expandedID: String?
    @State private var completedIDs: Set<String> = []
    @State private var miniConfettiTrigger: Bool = false
    @State private var allDoneCelebration: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var completedCount: Int { completedIDs.count }
    private var allDone: Bool { completedCount >= quests.count }

    var body: some View {
        VStack(spacing: 12) {
            sectionHeader

            ForEach(Array(quests.enumerated()), id: \.element.id) { index, quest in
                microQuestPill(quest: quest, index: index)
            }

            if allDone && allDoneCelebration {
                allCompleteCard
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Header

    private var sectionHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.neonEmerald)

            Text("BONUS ROUND")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.neonEmerald)
                .tracking(2)

            Spacer()

            Text("\(completedCount)/\(quests.count)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)

            if completedCount > 0 && completedCount < quests.count {
                ProgressView(value: Double(completedCount), total: Double(quests.count))
                    .progressViewStyle(.linear)
                    .tint(Theme.neonEmerald)
                    .frame(width: 40)
            }
        }
    }

    // MARK: - Pill

    private func microQuestPill(quest: QuestDefinition, index: Int) -> some View {
        let isCompleted = completedIDs.contains(quest.id)
        let isExpanded = expandedID == quest.id
        let isNext = !isCompleted && expandedID == nil && completedIDs.count == index

        return VStack(spacing: 0) {
            Button {
                guard !isCompleted else { return }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedID = isExpanded ? nil : quest.id
                }
                SplurjHaptics.cardTap()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Theme.accent : quest.category.color.opacity(0.3))
                            .frame(width: 24, height: 24)

                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Circle()
                                .fill(quest.category.color)
                                .frame(width: 8, height: 8)
                        }
                    }

                    Text(quest.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isCompleted ? Theme.textMuted : .white)
                        .lineLimit(1)
                        .strikethrough(isCompleted, color: Theme.textMuted)

                    Spacer()

                    if !isCompleted {
                        Text("+\(quest.baseXP) XP")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.gold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(Theme.gold.opacity(0.12))
                            )
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if isExpanded && !isCompleted {
                expandedSection(quest: quest)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCompleted ? Theme.accent.opacity(0.06) : Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isNext && !reduceMotion
                            ? Theme.accent.opacity(0.4)
                            : Theme.elevated.opacity(isCompleted ? 0.3 : 0.5),
                            lineWidth: isNext ? 1 : 0.5
                        )
                )
        )
        .opacity(isCompleted ? 0.7 : 1.0)
    }

    // MARK: - Expanded

    private func expandedSection(quest: QuestDefinition) -> some View {
        VStack(spacing: 10) {
            Divider().background(Theme.elevated)

            Text(quest.description)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, 14)

            Button {
                completeMicroQuest(quest)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("Done")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
    }

    // MARK: - All Complete

    private var allCompleteCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "bolt.shield.fill")
                .font(.system(size: 32))
                .foregroundStyle(Theme.neonEmerald)
                .symbolEffect(.bounce)

            Text("BONUS ROUND COMPLETE")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(Theme.neonEmerald)
                .tracking(2)

            Text("+\(quests.reduce(0) { $0 + $1.baseXP }) XP earned")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.gold)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.neonEmerald.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Theme.neonEmerald.opacity(0.15), radius: 12)
        )
    }

    // MARK: - Actions

    private func completeMicroQuest(_ quest: QuestDefinition) {
        SplurjHaptics.microQuestDone()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            completedIDs.insert(quest.id)
            expandedID = nil
        }

        onComplete(quest.id)

        if completedIDs.count >= quests.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                SplurjHaptics.questComplete()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    allDoneCelebration = true
                }
            }
        }
    }
}
