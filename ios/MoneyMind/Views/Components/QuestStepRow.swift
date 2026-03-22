import SwiftUI

struct QuestStepRow: View {
    let step: QuestStep
    let stepNumber: Int
    let isCompleted: Bool
    let isCurrent: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Theme.accent : isCurrent ? Theme.accent.opacity(0.2) : Theme.elevated)
                    .frame(width: 28, height: 28)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(stepNumber)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(isCurrent ? Theme.accent : Theme.textMuted)
                }
            }

            Text(step.instruction)
                .font(.system(size: 12))
                .foregroundStyle(isCurrent ? .white : Theme.textSecondary)
                .strikethrough(isCompleted, color: Theme.accent)

            Spacer()

            if isCurrent {
                Text("+\(step.xpReward) XP")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Theme.gold)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isCurrent ? Theme.elevated : Color.clear)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(stepAccessibilityLabel)
    }

    private var stepAccessibilityLabel: String {
        var label = "Step \(stepNumber): \(step.instruction)."
        if isCompleted {
            label += " Completed."
        } else if isCurrent {
            label += " Current step. \(step.xpReward) XP reward."
        } else {
            label += " Locked."
        }
        return label
    }
}
