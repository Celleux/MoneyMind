import SwiftUI

struct AllQuestsCompleteCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.accent)
                .symbolEffect(.pulse)

            Text("All Quests Complete")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Text("You conquered today's challenges. New quests arrive at midnight")
                .font(.system(size: 13))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.accent.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
}
