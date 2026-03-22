import SwiftUI

struct QuestCard: View {
    let quest: QuestDefinition
    let isLucky: Bool
    let isExpanded: Bool
    let progress: QuestProgress?
    let onTap: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(quest.category.color.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Circle()
                        .stroke(quest.category.color.opacity(0.4), lineWidth: 2)
                        .frame(width: 48, height: 48)

                    Image(systemName: quest.category.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(quest.category.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(quest.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        if isLucky {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.gold)
                                .symbolEffect(.pulse)
                        }
                    }

                    Text(quest.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(quest.difficulty.rawValue)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(quest.difficulty.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(quest.difficulty.color.opacity(0.15))
                            )

                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                            Text("+\(quest.baseXP) XP")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(Theme.gold)

                        if !quest.estimatedImpact.isEmpty {
                            Text(quest.estimatedImpact)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Theme.accent)
                        }

                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .font(.system(size: 8))
                            Text(quest.estimatedTime)
                                .font(.system(size: 9))
                        }
                        .foregroundStyle(Theme.textMuted)
                    }
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.textMuted)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .padding(16)

            if isExpanded {
                VStack(spacing: 12) {
                    Divider().background(Theme.elevated)

                    Text(quest.description)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 16)

                    if quest.steps.count > 1 {
                        let currentStep = progress?.currentStepIndex ?? 0
                        let completions = progress?.stepCompletions ?? [:]

                        VStack(spacing: 8) {
                            ForEach(Array(quest.steps.enumerated()), id: \.element.id) { index, step in
                                QuestStepRow(
                                    step: step,
                                    stepNumber: index + 1,
                                    isCompleted: completions[step.id] == true,
                                    isCurrent: index == currentStep
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    HStack(spacing: 16) {
                        RewardChip(icon: "star.fill", text: "+\(quest.baseXP) XP", color: Theme.gold)

                        if quest.scratchCardChance >= 1.0 {
                            RewardChip(icon: "creditcard.fill", text: "Card", color: Theme.accent)
                        } else if quest.scratchCardChance > 0 {
                            RewardChip(icon: "creditcard.fill", text: "\(Int(quest.scratchCardChance * 100))%", color: Theme.accent.opacity(0.7))
                        }

                        if quest.essenceReward > 0 {
                            RewardChip(icon: "diamond.fill", text: "+\(quest.essenceReward)", color: Color(hex: 0xA78BFA))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    Button {
                        onComplete()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("Complete Quest")
                                .font(.system(size: 16, weight: .black))
                        }
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Theme.accent, Theme.accent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Theme.accent.opacity(0.4), radius: 12, y: 4)
                    }
                    .sensoryFeedback(.impact(weight: .medium), trigger: UUID())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.surface)
                .shadow(color: isLucky ? Theme.gold.opacity(0.3) : .clear, radius: isLucky ? 12 : 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isLucky
                    ? AnyShapeStyle(LinearGradient(colors: [Theme.gold, Theme.gold.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    : AnyShapeStyle(Theme.elevated.opacity(0.5)),
                    lineWidth: isLucky ? 1.5 : 0.5
                )
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .sensoryFeedback(.impact(weight: .light), trigger: isExpanded)
    }
}
