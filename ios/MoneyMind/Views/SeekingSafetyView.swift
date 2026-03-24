import SwiftUI
import SwiftData

struct SeekingSafetyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTopic: SeekingSafetyTopic?

    private let purple = Color(red: 0.6, green: 0.3, blue: 0.9)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(Typography.displayMedium)
                            .foregroundStyle(purple)

                        Text("Seeking Safety")
                            .font(Typography.displaySmall)
                            .foregroundStyle(Theme.textPrimary)

                        Text("Trauma-informed exercises for building safety and resilience in recovery.")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 12)

                    ForEach(SeekingSafetyContent.topics) { topic in
                        Button {
                            selectedTopic = topic
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: topic.icon)
                                    .font(Typography.displaySmall)
                                    .foregroundStyle(purple)
                                    .frame(width: 48, height: 48)
                                    .background(purple.opacity(0.12), in: .rect(cornerRadius: 12))

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(topic.title)
                                        .font(Typography.headingSmall)
                                        .foregroundStyle(Theme.textPrimary)
                                    Text(topic.intro.prefix(60) + "...")
                                        .font(Typography.labelSmall)
                                        .foregroundStyle(Theme.textSecondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(Typography.labelSmall)
                                    .foregroundStyle(Theme.textSecondary.opacity(0.4))
                            }
                            .padding(16)
                            .splurjCard(.interactive)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(topic.title)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(Typography.headingLarge)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(item: $selectedTopic) { topic in
                SeekingSafetyTopicFlowView(topic: topic)
            }
        }
    }
}

extension SeekingSafetyTopic: @retroactive Equatable {
    static func == (lhs: SeekingSafetyTopic, rhs: SeekingSafetyTopic) -> Bool {
        lhs.id == rhs.id
    }
}

extension SeekingSafetyTopic: @retroactive Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SeekingSafetyTopicFlowView: View {
    let topic: SeekingSafetyTopic
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep: Int = 0
    @State private var reflectionAnswers: [String] = []
    @State private var currentInput: String = ""
    @State private var journalText: String = ""
    @State private var completed = false

    private let purple = Color(red: 0.6, green: 0.3, blue: 0.9)

    private var totalSteps: Int {
        2 + topic.reflectionPrompts.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if completed {
                    completionView
                } else {
                    stepContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(topic.title)
                        .font(Typography.headingMedium)
                        .foregroundStyle(Theme.textPrimary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(Typography.headingLarge)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var stepContent: some View {
        VStack(spacing: 0) {
            progressBar

            ScrollView {
                VStack(spacing: 24) {
                    if currentStep == 0 {
                        introStep
                    } else if currentStep <= topic.reflectionPrompts.count {
                        reflectionStep(index: currentStep - 1)
                    } else {
                        journalStep
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }

            Spacer(minLength: 0)

            navigationButtons
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Theme.cardSurface)
                    .frame(height: 3)

                Rectangle()
                    .fill(purple)
                    .frame(width: geo.size.width * (Double(currentStep + 1) / Double(totalSteps)), height: 3)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
        .frame(height: 3)
    }

    private var introStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image(systemName: topic.icon)
                .font(Typography.displayLarge)
                .foregroundStyle(purple)
                .frame(maxWidth: .infinity)

            Text(topic.intro)
                .font(Typography.bodyLarge)
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(5)

            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(purple.opacity(0.7))
                Text("Take your time with each reflection. There are no wrong answers.")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(12)
            .background(purple.opacity(0.06), in: .rect(cornerRadius: 12))
        }
    }

    private func reflectionStep(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Reflection \(index + 1) of \(topic.reflectionPrompts.count)")
                .font(Typography.labelSmall)
                .foregroundStyle(purple)

            Text(topic.reflectionPrompts[index])
                .font(Typography.headingLarge)
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(4)

            TextField("Take your time...", text: $currentInput, axis: .vertical)
                .lineLimit(4...8)
                .font(Typography.bodyMedium)
                .padding(14)
                .splurjCard(.outlined)
                .foregroundStyle(Theme.textPrimary)
                .tint(purple)
        }
    }

    private var journalStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Takeaway")
                    .font(Typography.labelSmall)
                    .foregroundStyle(purple)

                Text(topic.keyTakeaway)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Theme.textPrimary)
                    .lineSpacing(3)
                    .padding(14)
                    .background(purple.opacity(0.06), in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(purple.opacity(0.15), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Journal")
                    .font(Typography.labelSmall)
                    .foregroundStyle(purple)

                Text(topic.journalPrompt)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Theme.textSecondary)

                TextField("Write freely...", text: $journalText, axis: .vertical)
                    .lineLimit(5...10)
                    .font(Typography.bodyMedium)
                    .padding(14)
                    .splurjCard(.outlined)
                    .foregroundStyle(Theme.textPrimary)
                    .tint(purple)
            }
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        currentStep -= 1
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .splurjCard(.outlined)
                }
                .buttonStyle(SplurjButtonStyle(variant: .ghost, size: .medium))
            }

            Spacer()

            let isLast = currentStep >= totalSteps - 1
            Button {
                if !currentInput.isEmpty {
                    reflectionAnswers.append(currentInput)
                    currentInput = ""
                }

                if isLast {
                    saveEntry()
                    withAnimation(.spring(response: 0.4)) {
                        completed = true
                    }
                } else {
                    withAnimation(.spring(response: 0.3)) {
                        currentStep += 1
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(isLast ? "Complete" : "Next")
                    Image(systemName: isLast ? "checkmark" : "chevron.right")
                }
                .font(Typography.headingSmall)
                .foregroundStyle(Theme.background)
                .padding(.vertical, 14)
                .padding(.horizontal, 28)
                .background(purple, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
            .sensoryFeedback(.impact(weight: .light), trigger: currentStep)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Theme.background)
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(purple.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.shield.fill")
                    .font(Typography.displayLarge)
                    .foregroundStyle(purple)
            }

            Text("Topic Complete")
                .font(Typography.displaySmall)
                .foregroundStyle(Theme.textPrimary)

            Text("You've explored \"\(topic.title)\" — an important step in building safety and resilience.")
                .font(Typography.bodyMedium)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(Typography.headingMedium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(purple, in: .rect(cornerRadius: 14))
            }
            .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func saveEntry() {
        let entry = SeekingSafetyEntry(
            topicID: topic.id,
            reflections: reflectionAnswers,
            journalEntry: journalText
        )
        modelContext.insert(entry)
    }
}
