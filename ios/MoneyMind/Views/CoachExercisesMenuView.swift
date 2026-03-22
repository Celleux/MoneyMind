import SwiftUI

struct CoachExercisesMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showACT = false
    @State private var showSeekingSafety = false

    private let purple = Color(red: 0.6, green: 0.3, blue: 0.9)

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Guided Exercises")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.top, 8)

                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showACT = true
                    }
                } label: {
                    ExerciseMenuRow(
                        icon: "leaf.fill",
                        title: "ACT Exercises",
                        subtitle: "Values, defusion & willingness",
                        color: Theme.teal
                    )
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("ACT Exercises")

                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showSeekingSafety = true
                    }
                } label: {
                    ExerciseMenuRow(
                        icon: "shield.lefthalf.filled",
                        title: "Seeking Safety",
                        subtitle: "Trauma-informed recovery topics",
                        color: purple
                    )
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Seeking Safety")

                Spacer()
            }
            .padding(.horizontal)
            .background(Theme.background.ignoresSafeArea())
            .fullScreenCover(isPresented: $showACT) {
                ACTExercisesView()
            }
            .fullScreenCover(isPresented: $showSeekingSafety) {
                SeekingSafetyView()
            }
        }
    }
}

private struct ExerciseMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.12), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.textSecondary.opacity(0.4))
        }
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.1), lineWidth: 1)
        )
    }
}
