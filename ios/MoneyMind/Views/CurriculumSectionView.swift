import SwiftUI
import SwiftData

struct CurriculumSectionView: View {
    @Query(sort: \CurriculumSession.sessionNumber) private var sessions: [CurriculumSession]

    let dayCount: Int

    private var completedCount: Int {
        sessions.filter(\.isCompleted).count
    }

    private func isUnlocked(_ number: Int) -> Bool {
        if number == 1 { return true }
        return sessions.contains { $0.sessionNumber == number - 1 && $0.isCompleted }
    }

    private func isCompleted(_ number: Int) -> Bool {
        sessions.contains { $0.sessionNumber == number && $0.isCompleted }
    }

    var body: some View {
        if dayCount >= 3 {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundStyle(Theme.teal)
                    Text("Your Splurj Program")
                        .font(Typography.headingMedium)
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("\(completedCount) of 8")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.teal)
                }

                ProgressView(value: Double(completedCount), total: 8)
                    .tint(Theme.teal)
                    .scaleEffect(y: 1.5)
                    .clipShape(.capsule)

                VStack(spacing: 10) {
                    ForEach(CurriculumContent.sessions, id: \.number) { content in
                        let unlocked = isUnlocked(content.number)
                        let completed = isCompleted(content.number)
                        NavigationLink(value: content.number) {
                            CurriculumSessionRow(
                                content: content,
                                isUnlocked: unlocked,
                                isCompleted: completed
                            )
                        }
                        .disabled(!unlocked)
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(content.title), \(completed ? "completed" : unlocked ? "available" : "locked")")
                    }
                }
            }
            .padding(20)
            .splurjCard(.elevated)
        }
    }
}

private struct CurriculumSessionRow: View {
    let content: CurriculumSessionContent
    let isUnlocked: Bool
    let isCompleted: Bool

    private var accentColor: Color {
        switch content.color {
        case "teal": Theme.teal
        case "gold": Theme.gold
        case "green": Theme.accentGreen
        case "emergency": Theme.emergency
        default: Theme.teal
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isCompleted ? accentColor.opacity(0.15) : Theme.cardSurface)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .strokeBorder(isCompleted ? accentColor.opacity(0.3) : Theme.textSecondary.opacity(0.15), lineWidth: 1)
                    )

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(Typography.headingLarge)
                        .foregroundStyle(accentColor)
                } else if isUnlocked {
                    Image(systemName: content.iconName)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(accentColor)
                } else {
                    Image(systemName: "lock.fill")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Session \(content.number)")
                    .font(Typography.labelSmall)
                    .foregroundStyle(isUnlocked ? accentColor : Theme.textSecondary.opacity(0.4))
                Text(content.title)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(isUnlocked ? Theme.textPrimary : Theme.textSecondary.opacity(0.4))
                    .lineLimit(1)
            }

            Spacer()

            Text(content.duration)
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textSecondary.opacity(isUnlocked ? 0.7 : 0.3))

            Image(systemName: "chevron.right")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textSecondary.opacity(isUnlocked ? 0.3 : 0.1))
        }
        .padding(12)
        .background(
            isUnlocked && !isCompleted ? accentColor.opacity(0.03) : Color.clear,
            in: .rect(cornerRadius: 12)
        )
    }
}
