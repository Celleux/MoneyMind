import SwiftUI
import SwiftData

struct SpendingAutopsySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var trigger: String = ""
    @State private var selectedEmotion: String = ""
    @State private var amount: String = ""
    @State private var reflection: String = ""
    @State private var saved = false

    private let emotions = [
        ("Anxious", "bolt.heart.fill"),
        ("Guilty", "heart.slash.fill"),
        ("Relieved", "wind"),
        ("Numb", "cloud.fill"),
        ("Frustrated", "flame.fill"),
        ("Lonely", "person.fill.questionmark"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "heart.text.clipboard.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Theme.teal)

                        Text("No judgment here")
                            .font(Theme.headingFont(.title3))
                            .foregroundStyle(Theme.textPrimary)

                        Text("Reflecting on slip-ups builds self-awareness. That takes real courage.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("How much?")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)

                        HStack(spacing: 2) {
                            Text(CurrencyHelper.symbol(for: "USD"))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                            TextField("0", text: $amount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)
                                .tint(Theme.teal)
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 12)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("What happened?")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)

                        TextField("What triggered the spending?", text: $trigger, axis: .vertical)
                            .font(.body)
                            .foregroundStyle(Theme.textPrimary)
                            .tint(Theme.teal)
                            .lineLimit(2...4)
                            .padding(16)
                            .glassCard(cornerRadius: 12)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("How did you feel?")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)

                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 100), spacing: 8)
                        ], spacing: 8) {
                            ForEach(emotions, id: \.0) { emotion, icon in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedEmotion = selectedEmotion == emotion ? "" : emotion
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: icon)
                                            .font(.caption)
                                        Text(emotion)
                                            .font(.caption.weight(.medium))
                                    }
                                    .foregroundStyle(selectedEmotion == emotion ? Theme.background : Theme.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        selectedEmotion == emotion ? Theme.teal : Theme.cardSurface,
                                        in: .capsule
                                    )
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(
                                                selectedEmotion == emotion ? Theme.teal : Theme.textSecondary.opacity(0.15),
                                                lineWidth: 1
                                            )
                                    )
                                }
                                .buttonStyle(PressableButtonStyle())
                                .sensoryFeedback(.selection, trigger: selectedEmotion)
                                .accessibilityLabel("Emotion: \(emotion)")
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("What could you do next time?")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)

                        TextField("A thought for your future self...", text: $reflection, axis: .vertical)
                            .font(.body)
                            .foregroundStyle(Theme.textPrimary)
                            .tint(Theme.teal)
                            .lineLimit(2...4)
                            .padding(16)
                            .glassCard(cornerRadius: 12)
                    }

                    Button {
                        saveAutopsy()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.body)
                            Text("Log & Reflect")
                                .font(.headline)
                        }
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.teal, in: .rect(cornerRadius: 12))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(amount.isEmpty)
                    .opacity(amount.isEmpty ? 0.5 : 1)
                    .accessibilityLabel("Log reflection")

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(Theme.gold)
                        Text("+10 XP for your honesty")
                            .font(.caption)
                            .foregroundStyle(Theme.gold)
                    }
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Reflect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private func saveAutopsy() {
        guard let value = Double(amount), value > 0 else { return }

        let autopsy = SpendingAutopsy(
            trigger: trigger,
            emotion: selectedEmotion,
            amount: value,
            reflection: reflection
        )
        modelContext.insert(autopsy)

        let log = ImpulseLog(amount: value, note: trigger, resisted: false, emotionalTrigger: selectedEmotion)
        modelContext.insert(log)

        if let profile = profiles.first {
            profile.xpPoints += 10
        }

        dismiss()
    }
}
