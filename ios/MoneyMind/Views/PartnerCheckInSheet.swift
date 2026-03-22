import SwiftUI
import SwiftData

struct PartnerCheckInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var weekRating: Int = 3
    @State private var biggestWin: String = ""
    @State private var biggestChallenge: String = ""
    @State private var nextGoal: String = ""
    @State private var submitTrigger = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    ratingSection
                    textFieldSection("Biggest win this week", text: $biggestWin, icon: "trophy.fill", color: Theme.gold)
                    textFieldSection("Biggest challenge", text: $biggestChallenge, icon: "exclamationmark.triangle.fill", color: Theme.emergency)
                    textFieldSection("Goal for next week", text: $nextGoal, icon: "target", color: Theme.accentGreen)
                    submitButton
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Weekly Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Theme.teal.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: "checkmark.message.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.teal)
            }

            Text("How was your week?")
                .font(Theme.headingFont(.title3))
                .foregroundStyle(Theme.textPrimary)

            Text("Your partner will see this and share theirs too")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var ratingSection: some View {
        VStack(spacing: 12) {
            Text("Rate your week")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            weekRating = star
                        }
                    } label: {
                        Image(systemName: star <= weekRating ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle(star <= weekRating ? Theme.gold : Theme.textSecondary.opacity(0.3))
                            .scaleEffect(star <= weekRating ? 1.1 : 1.0)
                    }
                    .sensoryFeedback(.selection, trigger: weekRating)
                    .accessibilityLabel("\(star) star\(star > 1 ? "s" : "")")
                }
            }
        }
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
    }

    private func textFieldSection(_ title: String, text: Binding<String>, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            TextField(title, text: text, axis: .vertical)
                .lineLimit(3...5)
                .padding(12)
                .background(Theme.cardSurface, in: .rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.textSecondary.opacity(0.1), lineWidth: 1)
                )
        }
    }

    private var submitButton: some View {
        Button {
            let checkIn = PartnerCheckIn(
                weekRating: weekRating,
                biggestWin: biggestWin,
                biggestChallenge: biggestChallenge,
                nextGoal: nextGoal
            )
            modelContext.insert(checkIn)
            submitTrigger += 1
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                Text("Send Check-In")
                    .font(.headline)
            }
            .foregroundStyle(Theme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.teal, in: .rect(cornerRadius: 12))
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.success, trigger: submitTrigger)
        .accessibilityLabel("Send weekly check-in")
    }
}
